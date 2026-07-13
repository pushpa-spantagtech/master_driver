import 'dart:convert';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/ride_completation_dialog_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/swipable_button/slider_buttion_widget.dar.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/map/widgets/cancelation_radio_button.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/chat/controllers/chat_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/widgets/route_calculation_widget.dart';
import 'package:ride_sharing_user_app/features/map/widgets/route_widget.dart';
import 'package:ride_sharing_user_app/features/map/widgets/user_details_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/features/trip/screens/payment_received_screen.dart';
import 'package:ride_sharing_user_app/common_widgets/payment_item_info_widget.dart';

class RideOngoingWidget extends StatefulWidget {
  final String tripId;
  final GlobalKey<ExpandableBottomSheetState> expandableKey;

  const RideOngoingWidget(
      {super.key, required this.tripId, required this.expandableKey});

  @override
  State<RideOngoingWidget> createState() => _RideOngoingWidgetState();
}

class _RideOngoingWidgetState extends State<RideOngoingWidget> {
  bool isFinished = false;
  int currentState = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (riderController) {
      String firstRoute = '';
      String secondRoute = '';
      List<dynamic> extraRoute = [];
      if (riderController.tripDetail != null) {
        if (riderController.tripDetail!.intermediateAddresses != null &&
            riderController.tripDetail!.intermediateAddresses != '[[, ]]') {
          extraRoute =
              jsonDecode(riderController.tripDetail!.intermediateAddresses!);
          if (extraRoute.isNotEmpty) {
            firstRoute = extraRoute[0];
          }
          if (extraRoute.isNotEmpty && extraRoute.length > 1) {
            secondRoute = extraRoute[1];
          }
        }
      }

      return currentState == 0
          ? riderController.tripDetail != null
              ? GetBuilder<RiderMapController>(builder: (riderMapController) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const RouteCalculationWidget(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeSmall),
                            child: Text('trip_details'.tr,
                                style: textBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: Dimensions.paddingSizeSmall),
                            child: RouteWidget(
                              pickupAddress:
                                  riderController.tripDetail!.pickupAddress!,
                              destinationAddress: riderController
                                  .tripDetail!.destinationAddress!,
                              extraOne: firstRoute,
                              extraTwo: secondRoute,
                              entrance:
                                  riderController.tripDetail?.entrance ?? '',
                            ),
                          ),
                          Container(
                            width: Get.width,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .hintColor
                                      .withValues(alpha: 0.12),
                                  width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .shadowColor
                                      .withValues(alpha: 0.06),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      Stack(children: [
                                        Container(
                                          transform: Matrix4.translationValues(
                                              Get.find<LocalizationController>()
                                                      .isLtr
                                                  ? -3
                                                  : 3,
                                              -3,
                                              0),
                                          child: CircularPercentIndicator(
                                            radius: 28,
                                            percent: .75,
                                            lineWidth: 1,
                                            backgroundColor: Colors.transparent,
                                            progressColor:
                                                Theme.of(Get.context!)
                                                    .colorScheme
                                                    .tertiaryContainer,
                                          ),
                                        ),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: ImageWidget(
                                            width: 52,
                                            height: 52,
                                            image: riderController
                                                        .tripDetail!
                                                        .customer
                                                        ?.profileImage !=
                                                    null
                                                ? '${Get.find<SplashController>().config!.imageBaseUrl!.profileImageCustomer}/${riderController.tripDetail!.customer?.profileImage ?? ''}'
                                                : '',
                                          ),
                                        ),
                                      ]),
                                      Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (riderController.tripDetail!
                                                        .customer!.firstName !=
                                                    null &&
                                                riderController.tripDetail!
                                                        .customer!.lastName !=
                                                    null)
                                              SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    '${riderController.tripDetail!.customer!.firstName!} ${riderController.tripDetail!.customer!.lastName!}',
                                                    style:
                                                        textSemiBold.copyWith(),
                                                  )),
                                            if (riderController
                                                    .tripDetail!.customer !=
                                                null)
                                              Row(children: [
                                                Icon(
                                                  Icons.star_rate_rounded,
                                                  color: Theme.of(Get.context!)
                                                      .colorScheme
                                                      .primary,
                                                  size:
                                                      Dimensions.iconSizeMedium,
                                                ),
                                                const SizedBox(
                                                  width: 2,
                                                ),
                                                Text(
                                                  double.parse(riderController
                                                          .tripDetail!
                                                          .customerAvgRating!)
                                                      .toStringAsFixed(1),
                                                  style: textRegular.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary),
                                                ),
                                              ]),
                                          ]),
                                    ]),
                                    Container(
                                        width: 1,
                                        height: 25,
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withValues(alpha: 0.15)),
                                    InkWell(
                                      overlayColor: WidgetStateProperty.all(
                                          Colors.transparent),
                                      onTap: () => Get.find<ChatController>()
                                          .createChannel(
                                        riderController
                                            .tripDetail!.customer!.id!,
                                        tripId: riderController.tripDetail!.id,
                                      ),
                                      child: SizedBox(
                                        width: Dimensions.iconSizeLarge,
                                        child: Image.asset(
                                            Images.customerMessage,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                    ),
                                    Container(
                                        width: 1,
                                        height: 25,
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withValues(alpha: 0.15)),
                                    InkWell(
                                      overlayColor: WidgetStateProperty.all(
                                          Colors.transparent),
                                      onTap: () => Get.find<SplashController>()
                                          .sendMailOrCall(
                                        "tel:${riderController.tripDetail!.customer!.phone}",
                                        false,
                                      ),
                                      child: SizedBox(
                                        width: Dimensions.iconSizeLarge,
                                        child: Image.asset(Images.customerCall,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                    ),
                                    const SizedBox()
                                  ]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: Dimensions.paddingSizeDefault),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                Dimensions.paddingSizeDefault,
                                Dimensions.paddingSizeDefault,
                                Dimensions.paddingSizeDefault,
                                0,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                border: Border.all(
                                    color: Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: 0.12),
                                    width: 1),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .shadowColor
                                        .withValues(alpha: 0.06),
                                    blurRadius: 14,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PaymentItemInfoWidget(
                                      icon: Images.farePrice,
                                      title: 'fare_price'.tr,
                                      amount: double.parse(riderController
                                          .tripDetail!.estimatedFare!),
                                      isFromTripDetails: true,
                                    ),
                                    PaymentItemInfoWidget(
                                      icon: Images.paymentTypeIcon,
                                      title: 'payment'.tr,
                                      amount: 234,
                                      paymentType: riderController
                                          .tripDetail!.paymentMethod!
                                          .replaceAll(RegExp('[\\W_]+'), ' ')
                                          .capitalize,
                                    ),
                                  ]),
                            ),
                          ),
                          if (riderController.tripDetail!.note != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: Dimensions.paddingSizeSmall),
                              child: Text(
                                'note'.tr,
                                style: textRegular.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                            ),
                          if (riderController.tripDetail!.note != null)
                            Text(
                              riderController.tripDetail!.note!,
                              style: textRegular.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                          if (riderController.tripDetail != null &&
                              riderController.tripDetail!.type == 'parcel' &&
                              riderController.tripDetail!.parcelUserInfo !=
                                  null)
                            Container(
                              width: Get.width,
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeDefault),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.fontSizeExtraSmall),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${'who_will_pay'.tr}?',
                                      style: textRegular.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    ),
                                    Text(
                                      riderController.tripDetail!
                                          .parcelInformation!.payer!.tr,
                                      style: textMedium.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    )
                                  ]),
                            ),
                          if (riderController.tripDetail != null &&
                              riderController.tripDetail!.type == 'parcel' &&
                              riderController.tripDetail!.parcelUserInfo !=
                                  null)
                            ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: riderController
                                  .tripDetail!.parcelUserInfo!.length,
                              itemBuilder: (context, index) {
                                return UserDetailsWidget(
                                  name: riderController.tripDetail
                                          ?.parcelUserInfo![index].name ??
                                      '',
                                  contactNumber: riderController
                                          .tripDetail
                                          ?.parcelUserInfo![index]
                                          .contactNumber ??
                                      '',
                                  type: riderController.tripDetail
                                          ?.parcelUserInfo![index].userType ??
                                      '',
                                );
                              },
                            ),
                          (riderController.tripDetail!.isPaused!)
                              ? const SizedBox()
                              : (!riderController.tripDetail!.isPaused! &&
                                      riderController.tripDetail!.type ==
                                          "ride_request")
                                  ? Column(children: [
                                      SliderButton(
                                        action: () async {
                                          final rideController =
                                              Get.find<RideController>();

                                          if (rideController
                                              .hasReachedDestination) {
                                            final response =
                                                await rideController
                                                    .tripStatusUpdate(
                                              'completed',
                                              rideController.tripDetail!.id!,
                                              'trip_completed_successfully',
                                              '',
                                            );

                                            if (response.statusCode == 200) {
                                              await rideController.getFinalFare(
                                                  rideController
                                                      .tripDetail!.id!);
                                              Get.find<RiderMapController>()
                                                  .setRideCurrentState(
                                                      RideState.initial);
                                              Get.off(() =>
                                                  const PaymentReceivedScreen());
                                            }
                                            return;
                                          }

                                          Get.dialog(
                                            const RideCompletationDialogWidget(),
                                            barrierDismissible: false,
                                          );
                                        },
                                        label: Text(
                                          "complete".tr,
                                          style: textSemiBold.copyWith(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                        dismissThresholds: 0.5,
                                        dismissible: false,
                                        shimmer: false,
                                        width: 1170,
                                        height: 48,
                                        buttonSize: 48,
                                        radius: 24,
                                        icon: Center(
                                            child: Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  Theme.of(context).cardColor),
                                          child: Center(
                                              child: Icon(
                                            Get.find<LocalizationController>()
                                                    .isLtr
                                                ? Icons
                                                    .arrow_forward_ios_rounded
                                                : Icons.keyboard_arrow_left,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            size: 16.0,
                                          )),
                                        )),
                                        isLtr:
                                            Get.find<LocalizationController>()
                                                .isLtr,
                                        boxShadow:
                                            const BoxShadow(blurRadius: 0),
                                        buttonColor: Colors.transparent,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        baseColor:
                                            Theme.of(context).primaryColor,
                                      ),
                                    ])
                                  : SliderButton(
                                      action: () {
                                        if (riderController.tripDetail!
                                                    .parcelInformation!.payer ==
                                                'sender' &&
                                            riderController.tripDetail!
                                                    .paymentStatus ==
                                                'unpaid') {
                                          riderController
                                              .getFinalFare(riderController
                                                  .tripDetail!.id!)
                                              .then((value) {
                                            if (value.statusCode == 200) {
                                              Get.to(() =>
                                                  const PaymentReceivedScreen(
                                                      fromParcel: true));
                                            }
                                          });
                                        } else {
                                          Get.find<RideController>()
                                              .remainingDistance(
                                                  riderController
                                                      .tripDetail!.id!,
                                                  mapBound: true);
                                          Get.find<RiderMapController>()
                                              .setRideCurrentState(
                                                  RideState.end);
                                        }
                                      },
                                      label: Text('complete'.tr,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      dismissThresholds: 0.5,
                                      dismissible: false,
                                      shimmer: false,
                                      width: 1170,
                                      height: 48,
                                      buttonSize: 48,
                                      radius: 24,
                                      icon: Center(
                                          child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context).cardColor),
                                        child: Center(
                                            child: Icon(
                                          Get.find<LocalizationController>()
                                                  .isLtr
                                              ? Icons.arrow_forward_ios_rounded
                                              : Icons.keyboard_arrow_left,
                                          color: Colors.grey,
                                          size: 20.0,
                                        )),
                                      )),
                                      isLtr: Get.find<LocalizationController>()
                                          .isLtr,
                                      boxShadow: const BoxShadow(blurRadius: 0),
                                      buttonColor: Colors.transparent,
                                      backgroundColor: Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.15),
                                      baseColor: Theme.of(context).primaryColor,
                                    )
                        ]),
                  );
                })
              : const SizedBox()
          : Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text('your_trip_is_ongoing'.tr,
                        style: textSemiBold.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: Dimensions.fontSizeSmall,
                        )),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    const CancellationRadioButton(isOngoing: true),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Row(children: [
                      Expanded(
                          child: ButtonWidget(
                        buttonText: 'no_continue_trip'.tr,
                        showBorder: true,
                        radius: Dimensions.paddingSizeSmall,
                        onPressed: () {
                          currentState = 0;
                          setState(() {});
                        },
                      )),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                          child: ButtonWidget(
                        buttonText: 'submit'.tr,
                        showBorder: true,
                        transparent: true,
                        textColor: Get.isDarkMode ? Colors.white : Colors.black,
                        borderColor: Theme.of(context).hintColor,
                        radius: Dimensions.paddingSizeSmall,
                        onPressed: () async {
                          String cancelReason = "Driver cancelled";
                          if (Get.find<TripController>()
                                      .tripCancellationCauseList !=
                                  null &&
                              Get.find<TripController>()
                                      .tripCancellationCauseList!
                                      .data !=
                                  null &&
                              Get.find<TripController>()
                                  .tripCancellationCauseList!
                                  .data!
                                  .isNotEmpty &&
                              Get.find<TripController>()
                                      .tripCancellationCauseList!
                                      .data![0]
                                      .ongoingRide !=
                                  null &&
                              Get.find<TripController>()
                                  .tripCancellationCauseList!
                                  .data![0]
                                  .ongoingRide!
                                  .isNotEmpty) {
                            cancelReason = Get.find<TripController>()
                                    .tripCancellationCauseList!
                                    .data![0]
                                    .ongoingRide![
                                Get.find<TripController>()
                                    .tripCancellationCauseCurrentIndex];
                          }
                          var value = await riderController.tripStatusUpdate(
                            'cancelled',
                            riderController.tripDetail!.id!,
                            "trip_cancelled_successfully",
                            cancelReason,
                          );
                          if (value.statusCode == 200) {
                            Get.find<RiderMapController>()
                                .setRideCurrentState(RideState.initial);
                            Get.offAll(() => const DashboardScreen());
                          }
                        },
                      )),
                    ])
                  ]),
            );
    });
  }
}
