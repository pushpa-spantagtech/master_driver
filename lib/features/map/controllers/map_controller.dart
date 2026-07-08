import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:collection';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

enum RideState {
  initial,
  pending,
  accepted,
  ongoing,
  acceptingRider,
  end,
  completed,
  fareCalculating
}

class RiderMapController extends GetxController implements GetxService {
  final bool _showCancelTripButton = false;

  bool get showCancelTripButton => _showCancelTripButton;

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool isRefresh = false;

  bool _checkIsRideAccept = false;

  bool get checkIsRideAccept => _checkIsRideAccept;
  bool isTrafficEnable = false;

  Set<Marker> markers = HashSet<Marker>();
  final List<MarkerData> _customMarkers = [];

  List<MarkerData> get customMarkers => _customMarkers;
  PolylinePoints polylinePoints = PolylinePoints();
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinateList = [];

  GoogleMapController? mapController;

  bool profileOnline = true;

  void toggleProfileStatus() {
    profileOnline = !profileOnline;
    update();
  }

  bool clickedAssistant = false;

  void toggleAssistant() {
    clickedAssistant = !clickedAssistant;
    update();
  }

  double panelHeightOpen = 0;

  RideState currentRideState = RideState.initial;

  void setRideCurrentState(RideState newState, {bool notify = true}) {
    currentRideState = newState;
    if (currentRideState == RideState.initial) {
      initializeData();
    }
    if (notify) {
      update();
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  final double _distance = 0;

  double get distance => _distance;
  late Position _position;

  Position get position => _position;
  LatLng _initialPosition = const LatLng(23.83721, 90.363715);

  LatLng get initialPosition => _initialPosition;

  final LatLng _customerPosition = const LatLng(12, 12);
  late LatLng _destinationPosition = const LatLng(23.83721, 90.363715);

  LatLng get customerInitialPosition => _customerPosition;

  LatLng get destinationPosition => _destinationPosition;

  @override
  void onInit() {
    initializeData();
    super.onInit();
  }

  void initializeData() {
    Get.find<RideController>().polyline = '';
    markers = {};
    polylines = {};
    _isLoading = false;
  }

  void acceptedRideRequest() {
    _checkIsRideAccept = !_checkIsRideAccept;
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
    update();
  }

  double sheetHeight = 0;

  void setSheetHeight(double height, bool notify) {
    sheetHeight = height;
    if (notify) {
      update();
    }
  }

  void getPickupToDestinationPolyline({bool updateLiveLocation = false}) async {
    List<LatLng> polylineCoordinates = [];
    if (Get.find<RideController>().polyline != '') {
      List<PointLatLng> result =
          polylinePoints.decodePolyline(Get.find<RideController>().polyline);
      if (kDebugMode) {
        print(
            'here is latlng initial==> ${result.length},${result[0].latitude}-/${result[result.length - 1].latitude},/${result[result.length - 1].longitude}');
      }
      if (result.isNotEmpty) {
        for (var point in result) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        _initialPosition = LatLng(result[0].latitude, result[0].longitude);
        _destinationPosition = LatLng(result[result.length - 1].latitude,
            result[result.length - 1].longitude);
      }
      _addPolyLine(polylineCoordinates);

      polylineCoordinateList = polylineCoordinates;
      updateMarkerAndCircle(Get.find<LocationController>().initialPosition);

      setFromToMarker(_initialPosition, _destinationPosition,
          updateLiveLocation: updateLiveLocation);
    }
    update();
  }

  bool isBound = true;

  void getDriverToPickupOrDestinationPolyline(String lines,
      {bool mapBound = false}) async {
    List<LatLng> polylineCoordinates = [];
    if (lines != '') {
      List<PointLatLng> result = polylinePoints.decodePolyline(lines);
      if (kDebugMode) {
        print(
            'here is latlng ==> ${result.length},${result[0].latitude}-/${result[result.length - 1].latitude},/${result[result.length - 1].longitude}');
      }
      if (result.isNotEmpty) {
        for (var point in result) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
        _initialPosition = LatLng(result[0].latitude, result[0].longitude);
        _destinationPosition = LatLng(result[result.length - 1].latitude,
            result[result.length - 1].longitude);
      }
      _addPolyLine(polylineCoordinates);

      polylineCoordinateList = polylineCoordinates;

      // Use driver's live GPS position for marker and destination-radius check.
      // Earlier this was checking route start vs route end, so the app could show
      // distance 0.0 but still block trip completion.
      final LatLng currentDriverPosition =
          Get.find<LocationController>().initialPosition;
      updateMarkerAndCircle(currentDriverPosition);

      isInsideCircle(
          currentDriverPosition.latitude,
          currentDriverPosition.longitude,
          _destinationPosition.latitude,
          _destinationPosition.longitude,
          Get.find<SplashController>().config!.completionRadius!);
      if (mapBound) {
        boundMapScreen(_initialPosition, _destinationPosition);
      }
    }
    update();
  }

  _addPolyLine(List<LatLng> polylineCoordinates) {
    polylines.clear();
    Polyline polyline = Polyline(
      polylineId: const PolylineId('poly'),
      points: polylineCoordinates,
      width: 4,
      color: const Color(0xB2FF0000),
      geodesic: true,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
    polylines.add(polyline);
    update();
  }

  void setFromToMarker(LatLng from, LatLng to,
      {bool updateLiveLocation = false}) async {
    markers = HashSet();
    Uint8List fromMarker =
        await convertAssetToUnit8List(Images.mapIcon, width: 25);
    Uint8List toMarker =
        await convertAssetToUnit8List(Images.mapLocationIcon, width: 25);

    markers.add(Marker(
      markerId: const MarkerId('pickup'),
      position: from,
      anchor: const Offset(0.5, 0.5),
      infoWindow: InfoWindow(
        title: 'Pickup Location',
        snippet: Get.find<RideController>().tripDetail?.pickupAddress ?? '',
      ),
      icon: BitmapDescriptor.bytes(fromMarker),
    ));

    markers.add(Marker(
      markerId: const MarkerId('destination'),
      position: to,
      anchor: const Offset(0.5, 0.5),
      infoWindow: InfoWindow(
        title: 'Destination',
        snippet:
            Get.find<RideController>().tripDetail?.destinationAddress ?? '',
      ),
      icon: BitmapDescriptor.bytes(toMarker),
    ));

    try {
      LatLngBounds? bounds;
      if (mapController != null) {
        if (from.latitude < to.latitude) {
          bounds = LatLngBounds(southwest: from, northeast: to);
        } else {
          bounds = LatLngBounds(southwest: to, northeast: from);
        }
      }
      LatLng centerBounds = LatLng(
        (bounds!.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );
      double bearing = Geolocator.bearingBetween(
          from.latitude, from.longitude, to.latitude, to.longitude);
      mapController!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: bearing,
        target: centerBounds,
        zoom: 16,
      )));
      setMapPosition(mapController, bounds, centerBounds, bearing,
          padding: 0.5);
    } catch (e) {
      // debugPrint('jhkygutyv' + e.toString());
    }

    update();
  }

  void updateMarkerAndCircle(LatLng? latLong) async {
    if (latLong == null) return;

    markers.removeWhere((marker) => marker.markerId.value == "home");

    if (currentRideState.name == "initial") {
      update();
      return;
    }

    // final Uint8List car = await convertAssetToUnit8List(
    //   Get.find<ProfileController>().profileInfo?.vehicle?.category?.type == 'car'
    //       ? Images.carIconTop
    //       : Images.bike,
    //   width: 28,
    // );

    double bearing = 0;
    if (polylineCoordinateList.length > 1) {
      LatLng targetPoint = polylineCoordinateList.last;

      // Find the next point on the route nearest to the driver's live position.
      double nearestDistance = double.infinity;
      int nearestIndex = 0;

      for (int i = 0; i < polylineCoordinateList.length; i++) {
        final double distance = distanceBetween(
          latLong.latitude,
          latLong.longitude,
          polylineCoordinateList[i].latitude,
          polylineCoordinateList[i].longitude,
        );

        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestIndex = i;
        }
      }

      if (nearestIndex < polylineCoordinateList.length - 1) {
        targetPoint = polylineCoordinateList[nearestIndex + 1];
      }

      bearing = _calculateBearing(latLong, targetPoint);
    }

    // markers.add(Marker(
    //   markerId: const MarkerId("home"),
    //   position: latLong,
    //   rotation: bearing,
    //   draggable: false,
    //   zIndexInt: 10,
    //   flat: true,
    //   anchor: const Offset(0.5, 0.5),
    //   icon: BitmapDescriptor.bytes(car),
    // ));

    // Keep destination reach status based on actual driver GPS.
    if (_destinationPosition.latitude != 23.83721 ||
        _destinationPosition.longitude != 90.363715) {
      isInsideCircle(
        latLong.latitude,
        latLong.longitude,
        _destinationPosition.latitude,
        _destinationPosition.longitude,
        Get.find<SplashController>().config?.completionRadius ?? 100,
      );
    }

    // Follow the driver's live location while the ride is active.
    // This keeps the map moving along with the vehicle instead of only updating the marker.
    if (mapController != null &&
        (currentRideState == RideState.accepted ||
            currentRideState == RideState.ongoing)) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLong,
            zoom: 17,
            bearing: bearing,
          ),
        ),
      );
    }

    update();
  }

  // Add markers for pending trip requests
  void addPendingTripRequestMarkers(List<dynamic> pendingTrips) async {
    markers
        .removeWhere((marker) => marker.markerId.value.startsWith("request_"));
    update();
  }

  double _calculateBearing(LatLng startPoint, LatLng endPoint) {
    final double startLat = _toRadians(startPoint.latitude);
    final double startLng = _toRadians(startPoint.longitude);
    final double endLat = _toRadians(endPoint.latitude);
    final double endLng = _toRadians(endPoint.longitude);

    final double deltaLng = endLng - startLng;

    final double y = math.sin(deltaLng) * math.cos(endLat);
    final double x = math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(deltaLng);

    final double bearing = math.atan2(y, x);

    return (_toDegrees(bearing) + 360) % 360;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180.0);

  double _toDegrees(double radians) => radians * (180.0 / math.pi);

  Future<Uint8List> convertAssetToUnit8List(String imagePath,
      {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> setMapPosition(GoogleMapController? controller,
      LatLngBounds? bounds, LatLng centerBounds, double bearing,
      {double padding = 0.5}) async {
    if (controller != null && bounds != null) {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 120),
      );
    }

    update();
  }

  void boundMapScreen(LatLng startingPoint, LatLng endingPoint) {
    double distance = Geolocator.distanceBetween(
      startingPoint.latitude,
      startingPoint.longitude,
      endingPoint.latitude,
      endingPoint.longitude,
    );

    if (distance < 20) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: startingPoint,
            zoom: 18,
          ),
        ),
      );
      return;
    }

    try {
      final bounds = LatLngBounds(
        southwest: LatLng(
          startingPoint.latitude < endingPoint.latitude
              ? startingPoint.latitude
              : endingPoint.latitude,
          startingPoint.longitude < endingPoint.longitude
              ? startingPoint.longitude
              : endingPoint.longitude,
        ),
        northeast: LatLng(
          startingPoint.latitude > endingPoint.latitude
              ? startingPoint.latitude
              : endingPoint.latitude,
          startingPoint.longitude > endingPoint.longitude
              ? startingPoint.longitude
              : endingPoint.longitude,
        ),
      );

      mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 250),
      );
    } catch (e) {
      if (kDebugMode) {
        print("BOUND ERROR => $e");
      }
    }
  }

  // void boundMapScreen(LatLng startingPoint, LatLng endingPoint) {
  //   try {
  //     LatLngBounds? bounds;
  //     if (mapController != null) {
  //       if (startingPoint.latitude < endingPoint.latitude) {
  //         bounds =
  //             LatLngBounds(southwest: startingPoint, northeast: endingPoint);
  //       } else {
  //         bounds =
  //             LatLngBounds(southwest: endingPoint, northeast: startingPoint);
  //       }
  //     }
  //     LatLng centerBounds = LatLng(
  //       (bounds!.northeast.latitude + bounds.southwest.latitude) / 2,
  //       (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
  //     );
  //     double bearing = Geolocator.bearingBetween(startingPoint.latitude,
  //         startingPoint.longitude, endingPoint.latitude, endingPoint.longitude);
  //     mapController!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //       bearing: bearing,
  //       target: centerBounds,
  //       zoom: 16,
  //     )));
  //     setMapPosition(mapController, bounds, centerBounds, bearing,
  //         padding: 0.5);
  //   } catch (e) {
  //     // debugPrint('jhkygutyv' + e.toString());
  //   }
  // }

  bool _isInside = false;

  bool get isInside => _isInside;

  void isInsideCircle(double lat, double lng, double latCenter,
      double lngCenter, double radius) {
    double distance = distanceBetween(lat, lng, latCenter, lngCenter);

    print('======================');
    print('Driver Lat : $lat');
    print('Driver Lng : $lng');

    print('Drop Lat   : $latCenter');
    print('Drop Lng   : $lngCenter');
    print('Distance   : $distance');
    print('Radius     : $radius');
    _isInside = distance <= radius;
    print('Inside Radius : $_isInside');
    print('======================');

    update();
  }

  // void isInsideCircle(double lat, double lng, double latCenter,
  //     double lngCenter, double radius) {
  //   // Calculate the distance between two points using Haversine formula
  //   double distance = distanceBetween(lat, lng, latCenter, lngCenter);
  //   // Check if the distance is less than or equal to the radius
  //   _isInside = (distance <= radius) ? true : false;
  //   update();
  // }

  double distanceBetween(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    double distance = Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
    return distance; // Distance in meters
  }

  void setMarkersInitialPosition() {
    if (Get.find<RideController>().polyline != '') {
      List<PointLatLng> result =
          polylinePoints.decodePolyline(Get.find<RideController>().polyline);

      _initialPosition = LatLng(result[0].latitude, result[0].longitude);
      _destinationPosition = LatLng(result[result.length - 1].latitude,
          result[result.length - 1].longitude);

      setFromToMarker(_initialPosition, _destinationPosition,
          updateLiveLocation: false);
    }
  }

  void isRefreshLoader() {
    isRefresh = true;
    update();
    Future.delayed(const Duration(seconds: 2)).then((vale) {
      isRefresh = false;
      update();
    });
  }

  void toggleTrafficView() {
    isTrafficEnable = !isTrafficEnable;
    update();
  }
}
