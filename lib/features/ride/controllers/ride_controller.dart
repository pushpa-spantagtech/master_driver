import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/location/screens/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/otp_time_count_controller.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/final_fare_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/on_going_trip_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/parcel_list_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/pending_ride_request_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/remaining_distance_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/services/ride_service_interface.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/features/trip/screens/payment_received_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/notification_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';

class RideController extends GetxController implements GetxService {
  final RideServiceInterface rideServiceInterface;
  void debugStopCoordinates(dynamic body, String source) {
    if (body is! Map || body['data'] is! Map) {
      debugPrint('[$source] No trip data');
      return;
    }

    final data = body['data'] as Map;
    final coordinate = data['coordinate'];

    debugPrint('========== STOP COORDINATES [$source] ==========');
    debugPrint('TOP STOP 1: ${data['int_coordinate_1']}');
    debugPrint('TOP STOP 2: ${data['int_coordinate_2']}');
    debugPrint('TOP INTERMEDIATE: ${data['intermediate_coordinates']}');

    if (coordinate is Map) {
      debugPrint('NESTED STOP 1: ${coordinate['int_coordinate_1']}');
      debugPrint('NESTED STOP 2: ${coordinate['int_coordinate_2']}');
      debugPrint(
        'NESTED INTERMEDIATE: ${coordinate['intermediate_coordinates']}',
      );
    } else {
      debugPrint('NESTED COORDINATE: $coordinate');
    }

    debugPrint('================================================');
  }
  RideController({required this.rideServiceInterface});

  int _orderStatusSelectedIndex = 0;

  int get orderStatusSelectedIndex => _orderStatusSelectedIndex;
  bool isLoading = false;
  bool isPinVerificationLoading = false;
  String? _rideid;

  String? get rideId => _rideid;
  bool arrivalApiCalled = false;
  bool destinationApiCalled = false;
  bool localDestinationReached = false;
  Timer? _liveTrackingTimer;
  final Map<String, Future<Response>> _rideDetailRequests = {};

  bool get hasReachedDestination {
    return localDestinationReached ||
        (tripDetail?.isReachedDestination == true);
  }

  void setRideId(String id) {
    _rideid = id;
  }

  void setOrderStatusTypeIndex(int index) {
    _orderStatusSelectedIndex = index;
    update();
  }
  void updateIntermediateStopMarkers(dynamic responseBody) {
    if (!Get.isRegistered<RiderMapController>()) return;

    final dynamic data =
    responseBody is Map ? responseBody['data'] : null;

    if (data is! Map) return;

    final dynamic rawStops = data['intermediate_coordinates'];

    final List<LatLng> positions = [];

    try {
      final dynamic decoded =
      rawStops is String ? jsonDecode(rawStops) : rawStops;

      if (decoded is List) {
        for (final point in decoded) {
          if (point is List &&
              point.length >= 2 &&
              point[0] is num &&
              point[1] is num) {
            positions.add(
              LatLng(
                (point[0] as num).toDouble(),
                (point[1] as num).toDouble(),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('STOP PARSING ERROR: $e');
    }

    Get.find<RiderMapController>()
        .setIntermediateStopMarkers(positions);

    debugPrint('INTERMEDIATE STOP MARKERS: ${positions.length}');
  }

  Future<Response> bidding(String tripId, String amount) async {
    isLoading = true;
    update();
    Response response = await rideServiceInterface.bidding(tripId, amount);
    if (response.statusCode == 200) {
      Get.back();
      isLoading = false;
      showCustomSnackBar('bid_submitted_successfully'.tr, isError: false);
      getPendingRideRequestList(1);
      getRideDetailBeforeAccept(tripId);
    } else {
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  bool notSplashRoute = false;
  bool isNavigatingToMap = false;

  void updateRoute(bool showHideIcon, {bool notify = false}) {
    notSplashRoute = showHideIcon;
    if (notify) {
      update();
    }
  }

  bool _isOnMapScreen() {
    return Get.currentRoute.contains('MapScreen') ||
        (Get.context != null &&
            ModalRoute.of(Get.context!)?.settings.name?.contains('MapScreen') ==
                true);
  }

  String currentRideStatus = 'fresh';
  bool getResult = false;

  Future<Response> getCurrentRideStatus({
    bool fromRefresh = false,
    bool froDetails = false,
    bool isUpdate = true,
    bool allowNavigation = true,
    bool fromSplash = false,
  }) async {

    final Stopwatch stopwatch = Stopwatch()..start();
    debugPrint('===== CURRENT RIDE STATUS START =====');
    isLoading = true;

    if (froDetails) {
      getResult = true;

      if (isUpdate) {
        update();
      }
    }
    print("========== CURRENT RIDE STATUS ==========");

    final Response response = await rideServiceInterface.currentRideStatus();

    print("Status Code : ${response.statusCode}");
    print("Body        : ${response.body}");
    print("=========================================");

    if (response.statusCode == 200) {
      getResult = false;
      isLoading = false;

      if (response.body['data'] != null) {
        tripDetail = TripDetailsModel.fromJson(response.body).data;
        updateIntermediateStopMarkers(response.body);
        debugStopCoordinates(response.body, 'CURRENT RIDE');
        if (tripDetail == null) {
          update();
          return response;
        }

        currentRideStatus =
            (tripDetail?.currentStatus ?? 'fresh').toLowerCase();
        print("Current Status : $currentRideStatus");
        print("Payment Status : ${tripDetail?.paymentStatus}");

        polyline = tripDetail?.encodedPolyline ?? '';

        if (Get.find<AuthController>().getZoneId().isEmpty) {
          Get.to(() => const AccessLocationScreen());
          update();
          return response;
        }

        if (currentRideStatus == 'fresh') {
          Get.find<RiderMapController>().setRideCurrentState(RideState.initial);

          Get.offAllNamed(RouteHelper.getHomeRoute());
        } else if (currentRideStatus == 'accepted') {
          Get.find<RiderMapController>()
              .setRideCurrentState(RideState.accepted);

          await remainingDistance(
            tripDetail!.id!,
            mapBound: true,
          );

          startLiveTracking(tripDetail!.id!);
          updateRoute(false, notify: true);

          if (allowNavigation && !_isOnMapScreen() && !isNavigatingToMap) {
            isNavigatingToMap = true;

            Future.delayed(
              const Duration(milliseconds: 300),
              () async {
                try {
                  if (Get.currentRoute != '/MapScreen') {
                    if (fromSplash) {
                      Get.offAllNamed(RouteHelper.getHomeRoute());
                      await Future.delayed(
                        const Duration(milliseconds: 250),
                      );
                    }
                    await Get.to(
                      () => const MapScreen(fromScreen: 'splash'),
                    );
                  }
                } finally {
                  isNavigatingToMap = false;
                }
              },
            );
          }
        } else if (currentRideStatus == 'ongoing') {
          Get.find<RiderMapController>().setRideCurrentState(RideState.ongoing);

          await remainingDistance(
            tripDetail!.id!,
            mapBound: true,
          );

          startLiveTracking(tripDetail!.id!);
          updateRoute(false, notify: true);

          if (allowNavigation && !_isOnMapScreen() && !isNavigatingToMap) {
            isNavigatingToMap = true;

            Future.delayed(
              const Duration(milliseconds: 300),
              () async {
                try {
                  if (Get.currentRoute != '/MapScreen') {
                    if (fromSplash) {
                      Get.offAllNamed(RouteHelper.getHomeRoute());
                      await Future.delayed(
                        const Duration(milliseconds: 250),
                      );
                    }
                    await Get.to(
                      () => const MapScreen(fromScreen: 'splash'),
                    );
                  }
                } finally {
                  isNavigatingToMap = false;
                }
              },
            );
          }
        } else if (currentRideStatus == 'completed') {
          stopLiveTracking();

          final String paymentStatus =
              (tripDetail?.paymentStatus ?? 'unpaid').toLowerCase();

          if (paymentStatus == 'paid') {
            Get.offAllNamed(RouteHelper.getHomeRoute());
          } else {
            final String tripId = tripDetail!.id!;

            try {
              final Response fareResponse = await getFinalFare(tripId)
                  .timeout(const Duration(seconds: 15));

              if (fareResponse.statusCode == 200 && finalFare != null) {
                if (allowNavigation) {
                  Get.offAll(() => const PaymentReceivedScreen());
                }
              } else {
                throw StateError(
                  'Final fare unavailable (HTTP ${fareResponse.statusCode}). '
                      'Trip remains unpaid.',
                );
              }
            } catch (error) {
              isLoading = false;
              update();

              debugPrint('Completed/unpaid ride error: $error');

              if (fromSplash) rethrow;

              showCustomSnackBar(
                'Unable to load payment details. Please try again.',
              );
            }
          }
        } else if (currentRideStatus == 'cancelled') {
          stopLiveTracking();

          tripDetail = null;
          _rideid = null;
          polyline = '';
          localDestinationReached = false;
          destinationApiCalled = false;
          arrivalApiCalled = false;
          ongoingTrip = [];

          Get.find<RiderMapController>().setRideCurrentState(
            RideState.initial,
          );

          update();

          if (allowNavigation) {
            Get.offAllNamed(RouteHelper.getHomeRoute());
          }
        }
      }
    } else if (response.statusCode == 403) {
      isLoading = false;
      getResult = false;

      if (Get.find<AuthController>().getZoneId().isNotEmpty) {
        if (!fromRefresh) {
          Get.offNamed(RouteHelper.getHomeRoute());
        }
      } else {
        Get.to(() => const AccessLocationScreen());
      }
    } else {
      getResult = false;
      isLoading = false;

      /*
   * Never consider a 404 response as payment confirmation.
   *
   * Payment navigation must happen only after an API response explicitly
   * returns payment_status = paid.
   */
      if (!fromRefresh) {
        Get.offAllNamed(RouteHelper.getHomeRoute());
      }
    }
    update();
    stopwatch.stop();
    debugPrint(
      '===== CURRENT RIDE STATUS END: ${stopwatch.elapsedMilliseconds} ms =====',
    );
    return response;
  }

  Future<Map<String, dynamic>> activeRideInfoForNotification() async {
    // IMPORTANT: This method is used only from notification click.
    // Do NOT call currentRideStatus() here because that method has navigation
    // side effects and can redirect to Home/Login/Map.
    String localStatus = currentRideStatus.toLowerCase();
    String localRideId = tripDetail?.id?.toString() ?? '';

    if (localStatus != 'accepted' && localStatus != 'ongoing') {
      localStatus = (tripDetail?.currentStatus ?? '').toLowerCase();
    }

    bool hasSavedOngoingRide = false;
    try {
      hasSavedOngoingRide = Get.find<SplashController>().haveOngoingRides();
    } catch (_) {
      hasSavedOngoingRide = false;
    }

    if (localStatus == 'accepted' || localStatus == 'ongoing') {
      return {
        'hasRide': true,
        'rideId': localRideId,
        'status': localStatus.isNotEmpty ? localStatus : 'ongoing',
      };
    }

    return {
      'hasRide': false,
      'rideId': '',
      'status': '',
    };
  }

  TripDetail? tripDetail;

  Future<Response> getRideDetails(String tripId,
      {bool fromHomeScreen = false}) {
    final existingRequest = _rideDetailRequests[tripId];
    if (existingRequest != null) return existingRequest;

    final request = _fetchRideDetails(
      tripId,
      fromHomeScreen: fromHomeScreen,
    );
    _rideDetailRequests[tripId] = request;

    request.then<void>((_) {
      if (identical(_rideDetailRequests[tripId], request)) {
        _rideDetailRequests.remove(tripId);
      }
    }, onError: (Object error, StackTrace stackTrace) {
      if (identical(_rideDetailRequests[tripId], request)) {
        _rideDetailRequests.remove(tripId);
      }
    });

    return request;
  }

  Future<Response> _fetchRideDetails(String tripId,
      {bool fromHomeScreen = false}) async {
    isLoading = true;
    Response response = await rideServiceInterface.getRideDetails(tripId);
    if (response.statusCode == 200) {
      tripDetail = TripDetailsModel.fromJson(response.body).data!;
      debugStopCoordinates(response.body, 'RIDE DETAILS');
      currentRideStatus = (tripDetail?.currentStatus ?? currentRideStatus);

      polyline = tripDetail?.encodedPolyline ?? '';
      isLoading = false;
    } else {
      isLoading = false;
      fromHomeScreen ? null : ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Future<Response> uploadScreenShots(String tripId, XFile file) async {
    Response response =
        await rideServiceInterface.uploadScreenShots(tripId, file);
    if (response.statusCode == 200) {}
    update();
    return response;
  }

  String polyline = '';

  Future<Response> getRideDetailBeforeAccept(String tripId) async {
    isLoading = true;
    update();
    Response response =
        await rideServiceInterface.getRideDetailBeforeAccept(tripId);
    if (response.statusCode == 200) {
      tripDetail = TripDetailsModel.fromJson(response.body).data!;
      debugStopCoordinates(response.body, 'RIDE DETAILS');
      isLoading = false;
      polyline = tripDetail?.encodedPolyline ?? '';
      Get.find<RideController>().remainingDistance(tripId, mapBound: true);
      Get.find<RiderMapController>().getPickupToDestinationPolyline();
    } else {
      isLoading = false;
      ApiChecker.checkApi(response);
    }

    update();
    return response;
  }

  List<TripDetail>? ongoingTrip;

  List<TripDetail>? get ongoingTripDetails => ongoingTrip;

  void clearLastRideDetails() {
    ongoingTrip = [];
    update();
  }

  Future<Response> getLastTrip() async {
    final Stopwatch stopwatch = Stopwatch()..start();

    debugPrint('===== GET LAST TRIP START =====');

    Response response = await rideServiceInterface.ongoingTripRequest();

    stopwatch.stop();

    debugPrint(
      '===== GET LAST TRIP END: ${stopwatch.elapsedMilliseconds} ms =====',
    );
    debugPrint('GET LAST TRIP STATUS: ${response.statusCode}');

    if (response.statusCode == 200) {
      ongoingTrip = [];

      if (response.body['data'] != null) {
        ongoingTrip!.addAll(
          OngoingTripModel.fromJson(response.body).data!,
        );
      }
    } else {
      ApiChecker.checkApi(response);
    }
    debugPrint(
      '===== ONGOING TRIP AFTER API: '
          'null=${ongoingTrip == null}, '
          'length=${ongoingTrip?.length} =====',
    );
    update();
    return response;
  }

  bool accepting = false;

  Future<Response> tripAcceptOrRejected(String tripId, String type,
      {bool fromList = true, int index = 0}) async {
    if (fromList &&
        pendingRideRequestModel?.data != null &&
        pendingRideRequestModel!.data!.length > index) {
      pendingRideRequestModel!.data![index].isLoading = true;
      update();
    }
    accepting = true;
    update();
    Response response =
        await rideServiceInterface.tripAcceptOrReject(tripId, type);
    await NotificationHelper.stopAlertSound();
    if (response.statusCode == 200) {
      if (fromList &&
          pendingRideRequestModel?.data != null &&
          pendingRideRequestModel!.data!.length > index) {
        pendingRideRequestModel!.data![index].isLoading = false;
      }
      accepting = false;
      Get.find<RiderMapController>().getPickupToDestinationPolyline();
      if (type == 'rejected') {
        await rideServiceInterface.ignoreMessage(tripId);
        showCustomSnackBar('trip_is_rejected'.tr, isError: false);
      } else {
        showCustomSnackBar('trip_is_accepted'.tr, isError: false);
        Get.find<OtpTimeCountController>().initialCounter();

        currentRideStatus = 'accepted';
        tripDetail?.currentStatus = 'accepted';

        Get.find<RiderMapController>().setRideCurrentState(
          RideState.accepted,
        );

        // Do not block the Accept response while loading ride details,
        // distance and polyline. The request
        // card already places the accepted ride into tripDetail, so the map
        // can open immediately after the accept API succeeds.
        unawaited(getRideDetails(tripId));
        unawaited(remainingDistance(tripId, mapBound: true));
        startLiveTracking(tripId);
        pendingRideRequestModel?.data = <TripDetail>[];
        pendingRideRequestModel?.totalSize = 0;
      }
    } else {
      if (fromList &&
          pendingRideRequestModel?.data != null &&
          pendingRideRequestModel!.data!.length > index) {
        pendingRideRequestModel!.data![index].isLoading = false;
      }
      accepting = false;
      ApiChecker.checkApi(response);
    }
    if (fromList &&
        pendingRideRequestModel?.data != null &&
        pendingRideRequestModel!.data!.length > index) {
      pendingRideRequestModel!.data![index].isLoading = false;
    }
    accepting = false;
    update();
    return response;
  }

  String _verificationCode = '';
  String _otp = '';

  String get otp => _otp;

  String get verificationCode => _verificationCode;

  void updateVerificationCode(String query) {
    _verificationCode = query;
    if (_verificationCode.isNotEmpty) {
      _otp = _verificationCode;
    }
    update();
  }

  void clearVerificationCode() {
    _verificationCode = '';
    update();
  }

  Uint8List? imageFile;

  Future<Response> matchOtp(String tripId, String otp) async {
    isPinVerificationLoading = true;
    update();
    Response response = await rideServiceInterface.matchOtp(tripId, otp);
    if (response.statusCode == 200) {
      clearVerificationCode();
      if (tripDetail!.type! == 'parcel' &&
          tripDetail?.parcelInformation?.payer == 'sender') {
        Get.find<RiderMapController>().setRideCurrentState(RideState.ongoing);
        getFinalFare(tripId).then((value) {
          if (value.statusCode == 200) {
            Get.to(() => const PaymentReceivedScreen(
                  fromParcel: true,
                ));
          }
        });
      } else {
        destinationApiCalled = false;
        localDestinationReached = false;

        // Destination notification fix only:
        // After OTP success, make sure ride state is ongoing before
        // remainingDistance() starts checking destination radius.
        await getRideDetails(tripDetail!.id!);
        tripDetail?.currentStatus = 'ongoing';
        Get.find<RiderMapController>().setRideCurrentState(RideState.ongoing);

        await remainingDistance(tripDetail!.id!, mapBound: true);

        startLiveTracking(tripDetail!.id!);
      }
      showCustomSnackBar('otp_verified_successfully'.tr, isError: false);
      isPinVerificationLoading = false;
      Future.delayed(const Duration(seconds: 12)).then((value) async {
        imageFile =
            await Get.find<RiderMapController>().mapController!.takeSnapshot();
        if (imageFile != null) {
          uploadScreenShots(tripDetail!.id!, XFile.fromData(imageFile!));
        }
      });
      PusherHelper().tripCancelAfterOngoing(tripDetail!.id!);
      PusherHelper().tripPaymentSuccessful(tripDetail!.id!);
    } else {
      isPinVerificationLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  void startLiveTracking(String tripId) {
    _liveTrackingTimer?.cancel();

    _liveTrackingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (tripDetail == null) {
        timer.cancel();
        return;
      }

      if (tripDetail!.currentStatus == 'accepted' ||
          tripDetail!.currentStatus == 'ongoing') {
        remainingDistance(tripId, mapBound: false);
        if (tripDetail!.currentStatus == 'ongoing') {
          getRideDetails(tripId);
        }
      } else {
        stopLiveTracking();
      }
    });
  }

  void stopLiveTracking() {
    _liveTrackingTimer?.cancel();
    _liveTrackingTimer = null;
  }

  String myDriveMode = '';
  RemainingDistanceModel? matchedMode;
  List<RemainingDistanceModel>? remainingDistanceItem = [];
  final Map<String, Future<Response>> _routeRequests = {};

  Future<Response> remainingDistance(
      String tripId, {
        bool mapBound = false,
      }) async {
    // Pickup and ongoing routes must remain separate.
    final key = '$tripId:${tripDetail?.currentStatus ?? currentRideStatus}';

    final existingRequest = _routeRequests[key];

    if (existingRequest != null) {
      final response = await existingRequest;

      // Preserve a caller's request to fit the map camera.
      if (mapBound &&
          response.statusCode == 200 &&
          response.body is List &&
          response.body.isNotEmpty &&
          tripDetail?.id == tripId) {
        final encoded = response.body[0]['encoded_polyline'];
        if (encoded is String && encoded.isNotEmpty) {
          Get.find<RiderMapController>()
              .getDriverToPickupOrDestinationPolyline(
            encoded,
            mapBound: true,
          );
        }
      }

      return response;
    }

    final request = _fetchRemainingDistance(
      tripId,
      mapBound: mapBound,
    );
    _routeRequests[key] = request;

    try {
      return await request;
    } finally {
      _routeRequests.remove(key);
    }
  }
  Future<Response> _fetchRemainingDistance(String tripId,
      {bool mapBound = false}) async {
    myDriveMode =
        Get.find<ProfileController>().profileInfo!.vehicle!.category!.type!;
    isLoading = true;
    Response response = await rideServiceInterface.remainDistance(tripId);

    List<String> status = ['accepted', 'ongoing'];
    if (response.statusCode == 200) {
      isLoading = false;
      debugPrint('========== REMAIN DISTANCE RESPONSE ==========');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      if (response.body is List && response.body.isNotEmpty) {
        debugPrint(
          'ENCODED POLYLINE: ${response.body[0]['encoded_polyline']}',
        );
      }

      debugPrint('==============================================');
      if (status
          .contains(Get.find<RiderMapController>().currentRideState.name)) {
        Get.find<RiderMapController>().getDriverToPickupOrDestinationPolyline(
            response.body[0]['encoded_polyline'],
            mapBound: mapBound);
      }

      remainingDistanceItem = [];
      response.body.forEach((distance) {
        remainingDistanceItem!.add(RemainingDistanceModel.fromJson(distance));
      });
      if (remainingDistanceItem != null && remainingDistanceItem!.isNotEmpty) {
        matchedMode = remainingDistanceItem![0];
      }

      if (!arrivalApiCalled &&
          matchedMode != null &&
          (matchedMode!.distance! * 1000) <= 100 &&
          tripDetail != null &&
          (tripDetail!.currentStatus == 'pending' ||
              tripDetail!.currentStatus == 'accepted')) {
        arrivalApiCalled = true;

        arrivalPickupPoint(tripId);
      }

      // Destination reached notification check.
      // After OTP verification the trip status becomes `ongoing`.
      // When the driver reaches the destination radius, call backend
      // coordinate-arrival API once. Backend will notify the customer:
      // "You have reached your destination."
      //
      // Do not depend only on `matchedMode.isPicked`, because for some trips
      // the remaining-distance API may not set that flag even after pickup.

      final bool isOngoingTrip =
          Get.find<RiderMapController>().currentRideState ==
                  RideState.ongoing &&
              tripDetail != null &&
              !(tripDetail!.isPaused ?? false) &&
              tripDetail!.isReachedDestination != true;

      final List<double>? destinationCoordinates =
          tripDetail?.destinationCoordinates?.coordinates;

      double? actualDestinationDistanceMeters;

      if (destinationCoordinates != null &&
          destinationCoordinates.length >= 2) {
        final currentDriverPosition =
            Get.find<LocationController>().initialPosition;

        // GeoJSON coordinates are stored as [longitude, latitude].
        final double destinationLongitude = destinationCoordinates[0];
        final double destinationLatitude = destinationCoordinates[1];

        actualDestinationDistanceMeters =
            Get.find<RiderMapController>().distanceBetween(
          currentDriverPosition.latitude,
          currentDriverPosition.longitude,
          destinationLatitude,
          destinationLongitude,
        );
      }

      final double completionRadius =
          Get.find<SplashController>().config?.completionRadius ?? 100;

      final bool isInsideActualDestinationRadius =
          actualDestinationDistanceMeters != null &&
              actualDestinationDistanceMeters <= completionRadius;

      debugPrint(
        'DESTINATION RADIUS CHECK: '
        'distance=$actualDestinationDistanceMeters, '
        'radius=$completionRadius, '
        'inside=$isInsideActualDestinationRadius',
      );

      if (isOngoingTrip &&
          !destinationApiCalled &&
          isInsideActualDestinationRadius) {
        destinationApiCalled = true;

        final Response destinationResponse =
            await arrivalDestination(tripId, 'destination');

        if (destinationResponse.statusCode == 200) {
          localDestinationReached = true;
          tripDetail?.isReachedDestination = true;
          await getRideDetails(tripId);
        } else {
          destinationApiCalled = false;
          localDestinationReached = false;
        }
      }
    } else {
      isLoading = false;
    }
    update();
    return response;
  }

  bool _isInactiveTripResponse(Response response) {
    final dynamic body = response.body;
    final String responseMessage = body is Map
        ? (body['message'] ?? body['error'] ?? '').toString().toLowerCase()
        : body.toString().toLowerCase();

    return responseMessage.contains('no more active') ||
        responseMessage.contains('no longer active') ||
        responseMessage.contains('already cancelled') ||
        responseMessage.contains('already canceled') ||
        responseMessage.contains('already completed');
  }

  void _clearTerminalTripState(String tripId) {
    stopLiveTracking();
    currentRideStatus = 'cancelled';
    tripDetail = null;
    _rideid = null;
    polyline = '';
    localDestinationReached = false;
    arrivalApiCalled = false;
    destinationApiCalled = false;

    if (Get.isRegistered<OtpTimeCountController>()) {
      Get.find<OtpTimeCountController>().initialCounter();
    }

    if (Get.isRegistered<RiderMapController>()) {
      Get.find<RiderMapController>().setRideCurrentState(RideState.initial);
    }

    ongoingTrip?.removeWhere((trip) => trip.id == tripId);
    if (Get.isRegistered<SharedPreferences>()) {
      Get.find<SharedPreferences>().remove('active_trip_id');
    }
  }

  Future<Response> tripStatusUpdate(String arg1, String arg2, String message,
      String cancellationCause) async {
    // Determine which argument is status and which is tripId regardless of caller parameter order
    final bool isArg1Status = arg1.toLowerCase() == 'completed' ||
        arg1.toLowerCase() == 'cancelled' ||
        arg1.toLowerCase() == 'rejected' ||
        arg1.toLowerCase() == 'accepted' ||
        arg1.toLowerCase() == 'ongoing';

    final String status = isArg1Status ? arg1 : arg2;
    final String tripId = isArg1Status ? arg2 : arg1;

    isLoading = true;
    update();
    Response response = await rideServiceInterface.tripStatusUpdate(
        tripId, status, cancellationCause);

    if (response.statusCode == 200) {
      showCustomSnackBar(message.tr, isError: false);

      if (status.toLowerCase() == 'cancelled') {
        _clearTerminalTripState(tripId);
        update();
        unawaited(getCurrentRideStatus(froDetails: true, isUpdate: true));
        unawaited(getLastTrip());
      }

      isLoading = false;
    } else if (_isInactiveTripResponse(response)) {
      _clearTerminalTripState(tripId);
      isLoading = false;
      update();
      showCustomSnackBar('Ride request is no longer active');
      unawaited(getLastTrip());
      Get.offAllNamed(RouteHelper.getHomeRoute());
    } else {
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  PendingRideRequestModel? pendingRideRequestModel;

  PendingRideRequestModel? get getPendingRideRequestModel =>
      pendingRideRequestModel;

  Future<Response> getNotifiedRideRequest(String tripId) async {
    isLoading = true;
    pendingRideRequestModel = null;
    update();

    late Response response;

    // The push/Pusher event can arrive a fraction of a second before the
    // notified-driver mapping is visible to the details endpoint. Retry only
    // this exact ride a few times; never poll the full pending-rides list.
    for (int attempt = 0; attempt < 4; attempt++) {
      response = await rideServiceInterface.getRideDetails(tripId);
      if (response.statusCode == 200) {
        break;
      }
      if ((response.statusCode == 403 || response.statusCode == 404) &&
          attempt < 3) {
        await Future.delayed(const Duration(milliseconds: 750));
        continue;
      }
      break;
    }

    if (response.statusCode == 200 && response.body['data'] != null) {
      // ADD DEBUG CODE HERE
      final data = response.body['data'];

      debugPrint('========== STOP COORDINATES ==========');
      debugPrint('STOP 1: ${data['int_coordinate_1']}');
      debugPrint('STOP 2: ${data['int_coordinate_2']}');
      debugPrint('INTERMEDIATE: ${data['intermediate_coordinates']}');
      debugPrint('NESTED COORDINATE: ${data['coordinate']}');

      final coordinate = data['coordinate'];
      if (coordinate is Map) {
        debugPrint('Nested Stop 1: ${coordinate['int_coordinate_1']}');
        debugPrint('Nested Stop 2: ${coordinate['int_coordinate_2']}');
        debugPrint(
          'Nested intermediate: ${coordinate['intermediate_coordinates']}',
        );
      }

      debugPrint('======================================');

      final TripDetail notifiedRide =
      TripDetailsModel.fromJson(response.body).data!;

      tripDetail = notifiedRide;

      currentRideStatus =
          (notifiedRide.currentStatus ?? currentRideStatus).toLowerCase();

      polyline = notifiedRide.encodedPolyline ?? '';

      pendingRideRequestModel = PendingRideRequestModel(
        totalSize: 1,
        limit: '1',
        offset: '1',
        data: <TripDetail>[notifiedRide],
      );
      Get.find<RiderMapController>().addPendingTripRequestMarkers([]);
    }

    isLoading = false;
    update();
    return response;
  }

  Future<Response> getPendingRideRequestList(
    int offset, {
    int limit = 10,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    debugPrint(
      '===== PENDING RIDE LIST START | offset=$offset | limit=$limit =====',
    );
    isLoading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        update();
      }
    });

    final Response response = await rideServiceInterface
        .getPendingRideRequestList(offset, limit: limit);

    debugPrint('========== RIDE REQUEST API ==========');
    debugPrint('STATUS : ${response.statusCode}');
    debugPrint('BODY   : ${response.body}');
    debugPrint('======================================');

    if (response.statusCode == 200) {
      final dynamic responseData = response.body['data'];

      if (responseData != null && responseData != '') {
        final PendingRideRequestModel incomingModel =
            PendingRideRequestModel.fromJson(response.body);

        if (offset == 1 || pendingRideRequestModel == null) {
          pendingRideRequestModel = incomingModel;
        } else {
          pendingRideRequestModel!.totalSize = incomingModel.totalSize;
          pendingRideRequestModel!.offset = incomingModel.offset;
          pendingRideRequestModel!.data ??= [];
          pendingRideRequestModel!.data!.addAll(incomingModel.data ?? []);
        }
      } else if (offset == 1) {
        pendingRideRequestModel =
            PendingRideRequestModel.fromJson(response.body);
      }

      final pendingRequests = pendingRideRequestModel?.data ?? [];

      Get.find<RiderMapController>()
          .addPendingTripRequestMarkers(pendingRequests);

      isLoading = false;
    } else {
      if (offset == 1) {
        pendingRideRequestModel?.data = [];
        pendingRideRequestModel?.totalSize = 0;
        pendingRideRequestModel?.offset = '1';

        Get.find<RiderMapController>().addPendingTripRequestMarkers([]);
      }

      isLoading = false;
      ApiChecker.checkApi(response);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        update();
      }
    });
    stopwatch.stop();
    debugPrint(
      '===== PENDING RIDE LIST END | offset=$offset | limit=$limit | ${stopwatch.elapsedMilliseconds} ms =====',
    );
    return response;

  }

  FinalFare? finalFare;
  String? _finalFareRequestTripId;

  Future<Response> getFinalFare(String tripId) async {
    _finalFareRequestTripId = tripId;
    finalFare = null;
    isLoading = true;
    update();
    Response response = await rideServiceInterface.getFinalFare(tripId);
    debugPrint('FINAL FARE HTTP: ${response.statusCode}');
    debugPrint('FINAL FARE BODY: ${response.body}');

    // Ignore a late response belonging to an older trip.
    if (_finalFareRequestTripId != tripId) {
      return response;
    }

    if (response.statusCode == 200) {
      Get.find<RiderMapController>().initializeData();
      if (response.body['data'] != null) {
        finalFare = FinalFareModel.fromJson(response.body).data!;
      }

      isLoading = false;
    } else {
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-d');

  DateTime get startDate => _startDate;

  DateTime get endDate => _endDate;

  DateFormat get dateFormat => _dateFormat;

  void selectDate(String type, BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    ).then((date) {
      if (type == 'start') {
        _startDate = date!;
      } else {
        _endDate = date!;
      }

      update();
    });
  }

  bool _isResourceNotFoundResponse(Response response) {
    final String statusText = response.statusText?.toLowerCase() ?? '';
    final String bodyText = response.body?.toString().toLowerCase() ?? '';

    // Do not depend only on 404. Backend can return Resource not found with
    // different status codes or only in response body/statusText.
    return statusText.contains('resource not found') ||
        bodyText.contains('resource not found') ||
        statusText == 'not found' ||
        bodyText.contains('message: not found') ||
        bodyText.contains('message:resource not found') ||
        bodyText.contains('message: resource not found');
  }

  Future<Response> arrivalPickupPoint(String tripId) async {
    isLoading = true;
    Response response = await rideServiceInterface.arrivalPickupPoint(tripId);
    if (response.statusCode == 200) {
      isLoading = false;
    } else {
      isLoading = false;

      // This method can be triggered automatically by live-location checking.
      // Backend may sometimes return 404 / Resource not found while the trip
      // state is changing. Do not show that as a popup to the driver.
      if (_isResourceNotFoundResponse(response)) {
        arrivalApiCalled = false;
      } else {
        ApiChecker.checkApi(response);
      }
    }
    update();
    return response;
  }

  Future<Response> arrivalDestination(
    String tripId,
    String type,
  ) async {
    final Response response =
        await rideServiceInterface.arrivalDestination(tripId, type);

    if (response.statusCode == 200) {
      // The destination API is called only after the destination-radius
      // validation in remainingDistance(). Do not check isInside again here,
      // because route recalculation can temporarily reset that value.
      Future.delayed(const Duration(seconds: 2), () {
        Get.snackbar(
          'Destination Reached',
          'You have reached your destination.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.black87,
          duration: const Duration(seconds: 10),
          dismissDirection: DismissDirection.horizontal,
          isDismissible: true,
          borderRadius: 16,
          margin: const EdgeInsets.all(12),
          icon: const Icon(
            Icons.location_on_rounded,
            color: Color(0xFFFFB300),
          ),
        );

        AudioPlayer().play(AssetSource('ride_alert.wav'));
      });
    } else {
      if (_isResourceNotFoundResponse(response)) {
        // Allow the next tracking cycle to retry.
        destinationApiCalled = false;
      } else {
        ApiChecker.checkApi(response);
      }
    }

    update();
    return response;
  }

  Future<Response> waitingForCustomer(
      String tripId, String waitingStatus) async {
    isLoading = true;
    Response response =
        await rideServiceInterface.waitingForCustomer(tripId, waitingStatus);
    if (response.statusCode == 200) {
      getRideDetails(tripId);
      isLoading = false;
      showCustomSnackBar('trip_status_updated_successfully'.tr, isError: false);
    } else {
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
    return response;
  }

  Future<void> focusOnBottomSheet(
      GlobalKey<ExpandableBottomSheetState> key) async {
    if (key.currentState?.expansionStatus == ExpansionStatus.expanded) {
      // ignore: invalid_use_of_protected_member
      key.currentState?.reassemble();
      await Future.delayed(const Duration(milliseconds: 200));
    }
    key.currentState?.expand();
  }

  ParcelListModel? parcelListModel;

  Future<Response> getOngoingParcelList() async {
    isLoading = true;
    Response? response = await rideServiceInterface.getOnGoingParcelList(1);
    if (response!.statusCode == 200) {
      isLoading = false;
      if (response.body['data'] != null) {
        parcelListModel = ParcelListModel.fromJson(response.body);
      }
    } else {
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    update();
    return response;
  }

  ParcelListModel? unpaidParcelListModel;

  Future<Response> getUnpaidParcelList() async {
    isLoading = true;
    Response? response = await rideServiceInterface.getUnpaidParcelList(1);
    if (response!.statusCode == 200) {
      isLoading = false;
      if (response.body['data'] != null) {
        unpaidParcelListModel = ParcelListModel.fromJson(response.body);
      }
    } else {
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    update();
    return response;
  }

  @override
  void onClose() {
    stopLiveTracking();
    super.onClose();
  }
}
