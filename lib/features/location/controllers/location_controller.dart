import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/confirmation_dialog_widget.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/location/domain/models/zone_response.dart';
import 'package:ride_sharing_user_app/features/location/domain/services/location_service_interface.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationController extends GetxController implements GetxService {
  final LocationServiceInterface locationServiceInterface;

  LocationController({required this.locationServiceInterface});

  Future<bool> _showLocationDisclosure() async {
    final bool? agreed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Location access'),
        content: const Text(
          'SevenTaxi Driver collects location data to enable ride requests, '
          'navigation, live trip tracking, and sharing the driver’s location '
          'with the customer, even when the app is closed or not in use.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Agree'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return agreed == true;
  }

  Position _position = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1,
      altitudeAccuracy: 1,
      headingAccuracy: 1);

  String _address = '';
  bool _isLoading = false;
  GoogleMapController? _mapController;

  bool get isLoading => _isLoading;

  Position get position => _position;

  String get address => _address;

  GoogleMapController get mapController => _mapController!;
  LatLng _initialPosition = const LatLng(23.83721, 90.363715);

  LatLng get initialPosition => _initialPosition;
  StreamSubscription? get locationSubscription => _locationSubscription;

  StreamSubscription? _locationSubscription;

  Function? _pendingPermissionCallback;

  Future<Position> getCurrentLocation({
    bool isAnimate = true,
    GoogleMapController? mapController,
    bool callZone = true,
  }) async {
    final bool isSuccess = await checkPermission(() {});
    if (!isSuccess) {
      return _position;
    }

    try {
      await _locationSubscription?.cancel();
      _locationSubscription = null;

      final Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _position = currentPosition;
      _initialPosition = LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      );
      _mapController = mapController ?? _mapController;

      Get.find<RiderMapController>().updateMarkerAndCircle(_initialPosition);

      if (callZone) {
        await getZone(
          currentPosition.latitude.toString(),
          currentPosition.longitude.toString(),
          false,
        );
        await getAddressFromGeocode(_initialPosition);
      } else if (Get.find<AuthController>().isLoggedIn()) {
        await updateLastLocation(
          currentPosition.latitude.toString(),
          currentPosition.longitude.toString(),
        );
      }

      if (isAnimate && mapController != null) {
        await mapController.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _initialPosition, zoom: 16),
          ),
        );
      }

      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen(
        (Position livePosition) async {
          _position = livePosition;
          _initialPosition = LatLng(
            livePosition.latitude,
            livePosition.longitude,
          );

          Get.find<RiderMapController>()
              .updateMarkerAndCircle(_initialPosition);

          if (mapController != null) {
            await mapController.moveCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _initialPosition,
                  zoom: 16,
                ),
              ),
            );
          }

          if (Get.find<AuthController>().isLoggedIn()) {
            await updateLastLocation(
              livePosition.latitude.toString(),
              livePosition.longitude.toString(),
            );
          }

          update();
        },
        onError: (Object error) {
          if (kDebugMode) {
            print('LIVE LOCATION STREAM ERROR: $error');
          }
        },
      );

      update();
    } catch (e) {
      if (kDebugMode) {
        print('GET CURRENT LOCATION ERROR: $e');
      }
      _position = (await Geolocator.getLastKnownPosition()) ?? _position;
      _initialPosition = LatLng(_position.latitude, _position.longitude);
      update();
    }

    return _position;
  }

  String zoneID = '';

  Future<ZoneResponseModel> getZone(
      String lat, String long, bool markerLoad) async {
    _isLoading = true;
    update();
    ZoneResponseModel responseModel;
    Response response = await locationServiceInterface.getZone(lat, long);
    if (response.statusCode == 200) {
      zoneID = response.body['data']['id'];
      if (Get.find<AuthController>().isLoggedIn()) {
        storeLastLocationApi(lat, long, zoneID);
      }
      responseModel = ZoneResponseModel(true, '', zoneID);
      if (kDebugMode) {
        print('Here is your zoneId==> $zoneID');
      }
      if (zoneID != '') {
        setUserZoneId(zoneID);
        Get.find<AuthController>().updateZoneId(zoneID);
      }
    } else {
      responseModel = ZoneResponseModel(false, response.statusText, '');
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> setUserZoneId(String zoneId) async {
    locationServiceInterface.saveUserZoneId(zoneId);
  }

  Future<void> updateLastLocation(String lat, String lng) async {
    storeLastLocationApi(lat, lng, zoneID);
/*    final wsUrl = Uri.parse('${Get.find<SplashController>().config!.webSocketUrl}:${Get.find<SplashController>().config!.webSocketPort}${AppConstants.updateLastLocationUsingSocket}=${Get.find<SplashController>().config!.webSocketKey}');
    var channel = WebSocketChannel.connect(wsUrl);
    log("socket key==> ${wsUrl}");
    Stream stream = channel.stream;
    stream.listen((event) {
      Map<String, dynamic> jsonData =
      {"user_id" : "${Get.find<ProfileController>().profileInfo!.id}",
        "type" : "driver",
        "latitude" : lat,
        "longitude" : lng,
        "zone_id" : zoneID};
      channel.sink.add(jsonEncode(jsonData));
      channel.sink.close(status.goingAway);
    },onError: (e){
      storeLastLocationApi(lat, lng, zoneID);
    }, onDone: (() {
    })
    );*/
    update();
  }

  bool lastLocationLoading = false;

  Future<void> storeLastLocationApi(
      String lat, String lng, String zoneId) async {
    String resolvedZoneId = zoneId.trim();

    if (resolvedZoneId.isEmpty) {
      resolvedZoneId =
          Get.find<SharedPreferences>().getString(AppConstants.zoneId) ?? '';
    }

    // Never upload an invalid fallback such as "1". Resolve the real zone
    // from the driver's latest coordinates before storing live location.
    if (resolvedZoneId.isEmpty || resolvedZoneId == '1') {
      final ZoneResponseModel zoneResponse = await getZone(lat, lng, false);
      resolvedZoneId = zoneResponse.zoneIds.trim();
      if (!zoneResponse.isSuccess || resolvedZoneId.isEmpty) {
        if (kDebugMode) {
          print('LIVE LOCATION NOT STORED: valid zone unavailable');
        }
        return;
      }
      // getZone already stores this same location after resolving the zone.
      return;
    }

    lastLocationLoading = true;
    update();

    try {
      final Response response =
          await locationServiceInterface.storeLastLocationApi(
        lat,
        lng,
        resolvedZoneId,
      );

      if (kDebugMode) {
        print(
          'LIVE LOCATION STORED: $lat, $lng, zone: $resolvedZoneId, '
          'status: ${response.statusCode}',
        );
      }
    } finally {
      lastLocationLoading = false;
      update();
    }
  }

  Future<String> getAddressFromGeocode(LatLng latLng) async {
    Response response =
        await locationServiceInterface.getAddressFromGeocode(latLng);
    if (response.statusCode == 200) {
      _address =
          response.body['data']['results'][0]['formatted_address'].toString();
    }
    return _address;
  }

  Future<bool> checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      final bool agreed = await _showLocationDisclosure();

      if (!agreed) {
        return false;
      }

      permission = await Geolocator.requestPermission();
    }

    if (permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever) {
      _pendingPermissionCallback = null;

      await onTap();
      return true;
    }

    _pendingPermissionCallback = onTap;

    if (!(Get.isDialogOpen ?? false)) {
      Get.dialog(
        ConfirmationDialogWidget(
          description: 'you_have_to_allow'.tr,
          fromOpenLocation: true,
          onYesPressed: () async {
            await Geolocator.openAppSettings();
          },
          icon: Images.logo,
        ),
        barrierDismissible: false,
      );
    }

    return false;
  }

  Future<bool> handlePermissionOnResume() async {
    final Function? callback = _pendingPermissionCallback;
    if (callback == null) {
      return false;
    }

    final LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    _pendingPermissionCallback = null;
    await callback();
    return true;
  }
}
