import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/features/map/controllers/otp_time_count_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/services/ride_service_interface.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/location/screens/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/final_fare_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/on_going_trip_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/parcel_list_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/pending_ride_request_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/remaining_distance_model.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/trip/screens/payment_received_screen.dart';

class RideController extends GetxController implements GetxService {
  final RideServiceInterface rideServiceInterface;

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
  }) async {
    isLoading = true;

    if (froDetails) {
      getResult = true;

      if (isUpdate) {
        update();
      }
    }

    final Response response = await rideServiceInterface.currentRideStatus();

    if (response.statusCode == 200) {
      getResult = false;
      isLoading = false;

      if (response.body['data'] != null) {
        tripDetail = TripDetailsModel.fromJson(response.body).data;

        if (tripDetail == null) {
          update();
          return response;
        }

        currentRideStatus =
            (tripDetail?.currentStatus ?? 'fresh').toLowerCase();

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

          if (!_isOnMapScreen() && !isNavigatingToMap) {
            isNavigatingToMap = true;

            Future.delayed(
              const Duration(milliseconds: 300),
              () async {
                try {
                  if (Get.currentRoute != '/MapScreen') {
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

          if (!_isOnMapScreen() && !isNavigatingToMap) {
            isNavigatingToMap = true;

            Future.delayed(
              const Duration(milliseconds: 300),
              () async {
                try {
                  if (Get.currentRoute != '/MapScreen') {
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
            await getFinalFare(tripDetail!.id!);

            Get.offAll(
              () => const PaymentReceivedScreen(),
            );
          }
        } else if (currentRideStatus == 'cancelled') {
          stopLiveTracking();

          tripDetail = null;
          ongoingTrip = [];
          _rideid = null;
          polyline = '';

          remainingDistanceItem?.clear();
          matchedMode = null;

          arrivalApiCalled = false;
          destinationApiCalled = false;
          localDestinationReached = false;

          if (Get.isRegistered<OtpTimeCountController>()) {
            Get.find<OtpTimeCountController>().initialCounter();
          }

          if (Get.isRegistered<RiderMapController>()) {
            final RiderMapController mapController =
                Get.find<RiderMapController>();

            mapController.initializeData();
            mapController.setRideCurrentState(RideState.initial);
          }

          currentRideStatus = 'fresh';
          updateRoute(true, notify: true);

          Get.offAllNamed(RouteHelper.getHomeRoute());
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

      if (!fromRefresh) {
        Get.offNamed(RouteHelper.getHomeRoute());
      }
    }

    update();
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
      {bool fromHomeScreen = false}) async {
    isLoading = true;
    Response response = await rideServiceInterface.getRideDetails(tripId);
    if (response.statusCode == 200) {
      tripDetail = TripDetailsModel.fromJson(response.body).data!;
      currentRideStatus = (tripDetail?.currentStatus ?? currentRideStatus);

      polyline = tripDetail!.encodedPolyline!;
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
      isLoading = false;
      polyline = tripDetail!.encodedPolyline!;
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
    Response response = await rideServiceInterface.ongoingTripRequest();
    if (response.statusCode == 200) {
      ongoingTrip = [];
      if (response.body['data'] != null) {
        ongoingTrip!.addAll(OngoingTripModel.fromJson(response.body).data!);
      }
    } else {
      ApiChecker.checkApi(response);
    }
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
        // distance, polyline, and the refreshed pending list. The request
        // card already places the accepted ride into tripDetail, so the map
        // can open immediately after the accept API succeeds.
        unawaited(getRideDetails(tripId));
        unawaited(remainingDistance(tripId, mapBound: true));
        startLiveTracking(tripId);
        unawaited(getPendingRideRequestList(1));
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

    _liveTrackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (tripDetail == null) {
        timer.cancel();
        return;
      }

      if (tripDetail!.currentStatus == 'accepted' ||
          tripDetail!.currentStatus == 'ongoing') {
        remainingDistance(tripId, mapBound: false);
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

  Future<Response> remainingDistance(String tripId,
      {bool mapBound = false}) async {
    myDriveMode =
        Get.find<ProfileController>().profileInfo!.vehicle!.category!.type!;
    isLoading = true;
    Response response = await rideServiceInterface.remainDistance(tripId);

    List<String> status = ['accepted', 'ongoing'];
    if (response.statusCode == 200) {
      isLoading = false;
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
      final bool isInsideDestinationRadius =
          Get.find<RiderMapController>().isInside;
      final bool isRemainingDistanceReached =
          matchedMode != null && ((matchedMode!.distance ?? 999) <= 0.10);

      if (isOngoingTrip &&
          matchedMode != null &&
          !destinationApiCalled &&
          (isRemainingDistanceReached || isInsideDestinationRadius)) {
        destinationApiCalled = true;

        final Response destinationResponse =
            await arrivalDestination(tripId, "destination");

        if (destinationResponse.statusCode == 200) {
          localDestinationReached = true;
          tripDetail?.isReachedDestination = true;
          await getRideDetails(tripId);
        } else {
          // Allow retry on next live tracking tick if backend/network failed.
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

  Future<Response> tripStatusUpdate(String status, String id, String message,
      String cancellationCause) async {
    isLoading = true;
    update();
    Response response = await rideServiceInterface.tripStatusUpdate(
        status, id, cancellationCause);

    if (response.statusCode == 200) {
      showCustomSnackBar(message.tr, isError: false);

      if (status.toLowerCase() == 'cancelled') {
        // Apply the same cancellation cleanup to local, rental and
        // outstation rides so the Dashboard cannot restore a stale trip.
        stopLiveTracking();

        currentRideStatus = 'fresh';

        if (tripDetail != null) {
          tripDetail!.currentStatus = 'cancelled';
        }

        tripDetail = null;
        ongoingTrip = [];
        _rideid = null;
        polyline = '';

        localDestinationReached = false;
        arrivalApiCalled = false;
        destinationApiCalled = false;

        remainingDistanceItem?.clear();
        matchedMode = null;

        if (Get.isRegistered<OtpTimeCountController>()) {
          Get.find<OtpTimeCountController>().initialCounter();
        }

        if (Get.isRegistered<RiderMapController>()) {
          final RiderMapController mapController =
              Get.find<RiderMapController>();

          mapController.initializeData();
          mapController.setRideCurrentState(RideState.initial);
        }

        updateRoute(true, notify: true);
      }

      isLoading = false;
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

  Future<Response> getPendingRideRequestList(int offset,
      {int limit = 10}) async {
    isLoading = true;
    update();

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
          // Page one is a fresh snapshot from the backend and contains every
          // currently pending request for that page.
          pendingRideRequestModel = incomingModel;
        } else {
          // Keep the already loaded requests and append the next page.
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

      // Display every pending request marker without selecting one request.
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

    update();
    return response;
  }

  FinalFare? finalFare;

  Future<Response> getFinalFare(String tripId) async {
    isLoading = true;
    update();
    Response response = await rideServiceInterface.getFinalFare(tripId);

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

  Future<Response> arrivalDestination(String tripId, String type) async {
    Response response =
        await rideServiceInterface.arrivalDestination(tripId, type);

    if (response.statusCode == 200) {
      if (Get.find<RiderMapController>().isInside) {
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

          AudioPlayer().play(AssetSource('notification.wav'));
        });
      }
    } else {
      if (_isResourceNotFoundResponse(response)) {
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
