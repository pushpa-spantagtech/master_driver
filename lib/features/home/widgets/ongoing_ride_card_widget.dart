import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/custom_arrow_icon_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/custom_menu_driving_status_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/last_trip_shimmer_widget.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/trip/screens/payment_received_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class OngoingRideCardWidget extends StatelessWidget {
  const OngoingRideCardWidget({super.key});

  static Future<void> reopenActiveRide(RideController rideController) async {
    if (rideController.isNavigatingToMap) {
      return;
    }

    final trip = rideController.ongoingTrip != null &&
            rideController.ongoingTrip!.isNotEmpty
        ? rideController.ongoingTrip!.first
        : rideController.tripDetail;
    if (trip == null) {
      return;
    }
    final String tripId = trip.id ?? '';
    final String status = (trip.currentStatus ?? '').toLowerCase();
    final String paymentStatus = (trip.paymentStatus ?? '').toLowerCase();

    if (tripId.isEmpty) {
      return;
    }

    if (status == 'accepted' || status == 'ongoing') {
      rideController.isNavigatingToMap = true;

      try {
        final response = await rideController.getRideDetails(tripId);
        if (response.statusCode != 200) {
          return;
        }

        final mapController = Get.find<RiderMapController>();
        mapController.setRideCurrentState(
          status == 'ongoing' ? RideState.ongoing : RideState.accepted,
        );
        mapController.setMarkersInitialPosition();
        rideController.startLiveTracking(tripId);
        rideController.updateRoute(false, notify: true);

        await Get.to(() => const MapScreen(fromScreen: 'home'));
      } finally {
        rideController.isNavigatingToMap = false;
      }
      return;
    }

    if (status == 'completed' && paymentStatus == 'unpaid') {
      final response = await rideController.getFinalFare(tripId);
      if (response.statusCode == 200) {
        Get.to(() => const PaymentReceivedScreen());
      }
      return;
    }

    Get.to(() => TripDetails(tripId: tripId));
  }

  @override
  Widget build(BuildContext context) {
    String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
    return GetBuilder<RideController>(builder: (rideController) {
      String tripDate = '0', suffix = 'st';
      List<dynamic> extraRoute = [];
      int totalMinutes = 0, count = 1;
      bool isCompleted = false;

      if (rideController.ongoingTrip != null &&
          rideController.ongoingTrip!.isNotEmpty) {
        final currentTrip = rideController.ongoingTrip![0];
        isCompleted = currentTrip.currentStatus == 'completed';

        tripDate = DateConverter.dateTimeStringToDateOnly(
            currentTrip.createdAt!);
        if (tripDate == "1") {
          suffix = "st";
        } else if (tripDate == "2") {
          suffix = "nd";
        } else if (tripDate == "3") {
          suffix = "rd";
        } else {
          suffix = "th";
        }

        if (isCompleted && currentTrip.actualTime != null && currentTrip.actualTime! > 0) {
          totalMinutes = currentTrip.actualTime!.toInt();
        } else if (isCompleted &&
            currentTrip.tripStatus?.ongoing != null &&
            currentTrip.tripStatus?.completed != null) {
          try {
            totalMinutes = DateTime.parse(currentTrip.tripStatus!.completed!)
                .difference(DateTime.parse(currentTrip.tripStatus!.ongoing!))
                .inMinutes;
          } catch (_) {
            totalMinutes = DateTime.now()
                .difference(DateTime.parse(currentTrip.createdAt!))
                .inMinutes;
          }
        } else {
          try {
            final startTime = currentTrip.tripStatus?.ongoing != null
                ? DateTime.parse(currentTrip.tripStatus!.ongoing!)
                : DateTime.parse(currentTrip.createdAt!);
            totalMinutes = DateTime.now().difference(startTime).inMinutes;
          } catch (_) {
            totalMinutes = 0;
          }
        }

        if (totalMinutes < 0) totalMinutes = 0;

        for (int i = 0; i < extraRoute.length; i++) {
          if (extraRoute[i] != '') {
            count++;
            if (kDebugMode) {
              print(count);
            }
          }
        }
      }

      final int durationHrs = totalMinutes ~/ 60;
      final int durationMins = totalMinutes % 60;
      final String durationFormatted = durationHrs > 0
          ? '$durationHrs hr $durationMins min'
          : '$durationMins min';

      Future<void> openCurrentRide() => reopenActiveRide(rideController);

      return rideController.ongoingTrip != null
          ? rideController.ongoingTrip!.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFE7E9EE),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D101828),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: Dimensions.paddingSizeSmall),
                                child: Column(
                                  children: [
                                    Text(
                                      '$tripDate $suffix',
                                      style: textBold.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontSize: Dimensions.fontSizeLarge),
                                    ),
                                    Text(
                                        DateConverter
                                            .dateTimeStringToMonthAndYear(
                                                rideController.ongoingTrip![0]
                                                    .createdAt!),
                                        style: textMedium),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                  capitalize(rideController
                                      .ongoingTrip![0].currentStatus!.tr),
                                  style: textSemiBold.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary)),
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomArrowIconWidget(
                                    onTap: () {
                                      if (rideController
                                              .orderStatusSelectedIndex !=
                                          0) {
                                        rideController.setOrderStatusTypeIndex(
                                            rideController
                                                    .orderStatusSelectedIndex -
                                                1);
                                      }
                                    },
                                    color: rideController
                                                .orderStatusSelectedIndex ==
                                            0
                                        ? const Color(0xFFF3F3F3)
                                        : Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                    iconColor: rideController
                                                .orderStatusSelectedIndex ==
                                            0
                                        ? const Color(0xFF9E9E9E)
                                        : const Color(0xFF141414),
                                    icon: CupertinoIcons.left_chevron,
                                  ),
                                  InkWell(
                                      overlayColor: WidgetStateProperty.all(
                                          Colors.transparent),
                                      onTap: openCurrentRide,
                                      child: CircularPercentIndicator(
                                          radius: 80.0,
                                          lineWidth: 10.0,
                                          percent: rideController
                                                      .orderStatusSelectedIndex ==
                                                  0
                                              ? 0.70
                                              : rideController
                                                          .orderStatusSelectedIndex ==
                                                      1
                                                  ? 0.90
                                                  : 0.70,
                                          circularStrokeCap:
                                              CircularStrokeCap.round,
                                          center: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                  isCompleted && rideController.orderStatusSelectedIndex == 0
                                                      ? "trip_duration".tr
                                                      : "estimated".tr,
                                                  style: textRegular.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onTertiaryContainer)),
                                              Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    vertical: Dimensions
                                                        .paddingSizeExtraSmall),
                                                child: Text(
                                                  rideController
                                                              .orderStatusSelectedIndex ==
                                                          0
                                                      ? (isCompleted && totalMinutes > 0
                                                          ? "$totalMinutes min"
                                                          : "${rideController.ongoingTrip![0].estimatedTime} min")
                                                      : rideController
                                                                  .orderStatusSelectedIndex ==
                                                              1
                                                          ? (isCompleted && (rideController.ongoingTrip![0].actualDistance ?? 0) > 0
                                                              ? '${rideController.ongoingTrip![0].actualDistance!.toStringAsFixed(2)} km'
                                                              : '${rideController.ongoingTrip![0].estimatedDistance!.toStringAsFixed(2)} km')
                                                          : PriceConverter.convertPrice(
                                                              context,
                                                              double.parse((isCompleted
                                                                      ? (rideController.ongoingTrip![0].paidFare ??
                                                                          rideController.ongoingTrip![0].actualFare ??
                                                                          rideController.ongoingTrip![0].estimatedFare)
                                                                      : rideController.ongoingTrip![0].estimatedFare)
                                                                  .toString())),
                                                  style: textBold.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                      fontSize: Dimensions
                                                          .fontSizeOverLarge),
                                                ),
                                              ),
                                              Text(
                                                rideController
                                                            .orderStatusSelectedIndex ==
                                                        0
                                                    ? (isCompleted ? "completed".tr : "driving".tr)
                                                    : rideController
                                                                .orderStatusSelectedIndex ==
                                                            1
                                                        ? "derived".tr
                                                        : "for_this_trip".tr,
                                                style: textRegular.copyWith(
                                                    color: Get.isDarkMode
                                                        ? Theme.of(context)
                                                            .hintColor
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .secondary),
                                              ),
                                            ],
                                          ),
                                          progressColor: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          backgroundColor: Theme.of(context)
                                              .hintColor
                                              .withValues(alpha: .18))),
                                  CustomArrowIconWidget(
                                    onTap: () {
                                      if (rideController
                                              .orderStatusSelectedIndex !=
                                          2) {
                                        rideController.setOrderStatusTypeIndex(
                                            rideController
                                                    .orderStatusSelectedIndex +
                                                1);
                                      }
                                    },
                                    icon: CupertinoIcons.right_chevron,
                                    color: rideController
                                                .orderStatusSelectedIndex !=
                                            2
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                        : const Color(0xFFF3F3F3),
                                    iconColor: rideController
                                                .orderStatusSelectedIndex !=
                                            2
                                        ? const Color(0xFF141414)
                                        : const Color(0xFF9E9E9E),
                                  )
                                ])),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeSmall),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  rideController.orderStatusSelectedIndex == 0
                                      ? (isCompleted
                                          ? '${'trip_duration'.tr}:'
                                          : '${'ongoing_trip_time'.tr}:')
                                      : '${'ongoing_trip_distance'.tr}:',
                                  style: textRegular.copyWith(
                                      color: Get.isDarkMode
                                          ? Theme.of(context).hintColor
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.paddingSizeExtraSmall),
                                child: Text(
                                    rideController.orderStatusSelectedIndex == 0
                                        ? durationFormatted
                                        : rideController
                                            .ongoingTrip![0].estimatedDistance!
                                            .toStringAsFixed(2),
                                    style: textBold.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: Dimensions.fontSizeLarge)),
                              ),
                              if (rideController.orderStatusSelectedIndex != 0)
                                Text(
                                    'km'.tr,
                                    style: textRegular.copyWith(
                                        color: Get.isDarkMode
                                            ? Theme.of(context).hintColor
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface)),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        SizedBox(
                          height: Dimensions.orderStatusIconHeight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomMenuDrivingStatusWidget(
                                  index: 0,
                                  selectedIndex:
                                      rideController.orderStatusSelectedIndex,
                                  icon: Images.drivingIcon),
                              CustomMenuDrivingStatusWidget(
                                  index: 1,
                                  selectedIndex:
                                      rideController.orderStatusSelectedIndex,
                                  icon: Images.drivedIcon),
                              CustomMenuDrivingStatusWidget(
                                  index: 2,
                                  selectedIndex:
                                      rideController.orderStatusSelectedIndex,
                                  icon: Images.paymentIcon),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : const NoDataWidget(title: 'no_trip_found', fromHome: true)
          : const Padding(
              padding: EdgeInsets.only(top: 60.0),
              child: LastTripShimmerWidget());
    });
  }
}
