import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/map/widgets/route_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/trip/screens/payment_received_screen.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/sub_total_header.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/loader_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/payment_item_info_widget.dart';

class TripDetails extends StatefulWidget {
  final String tripId;

  const TripDetails({super.key, required this.tripId});

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  @override
  void initState() {
    Get.find<RideController>().getRideDetails(widget.tripId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<RideController>(builder: (rideController) {
        String firstRoute = '';
        String secondRoute = '';
        double finalPrice = 0;
        Duration? tripDuration;
        if (rideController.tripDetail != null) {
          finalPrice = double.parse(rideController.tripDetail!.paidFare!);
          if (rideController.tripDetail!.actualTime != null) {
            tripDuration = Duration(
                minutes: rideController.tripDetail!.actualTime!.ceil());
          }

          List<dynamic> extraRoute = [];
          if (rideController.tripDetail!.intermediateAddresses != null &&
              rideController.tripDetail!.intermediateAddresses != '[[, ]]') {
            extraRoute =
                jsonDecode(rideController.tripDetail!.intermediateAddresses!);

            if (extraRoute.isNotEmpty) {
              firstRoute = extraRoute[0];
            }
            if (extraRoute.isNotEmpty && extraRoute.length > 1) {
              secondRoute = extraRoute[1];
            }
          }
        }

        return rideController.tripDetail != null
            ? SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppBarWidget(title: 'trip_details'.tr),
                      SubTotalHeaderTitle(
                        title:
                            '${'your_trip'.tr} #${rideController.tripDetail!.refId} ${'is'.tr} '
                            '${rideController.tripDetail!.currentStatus!.tr}',
                        color: Theme.of(context).colorScheme.secondary,
                        tripId: widget.tripId,
                        isReviewed: rideController.tripDetail!.isReviewed,
                        paymentStatus: rideController.tripDetail!.paymentStatus,
                        type: rideController.tripDetail!.type,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeExtraLarge),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (rideController.tripDetail!.actualTime != null)
                                SummeryItem(
                                  title:
                                      '${tripDuration!.inHours}:${tripDuration.inMinutes % 60} hr',
                                  subTitle: 'time'.tr,
                                ),
                              SummeryItem(
                                title:
                                    '${rideController.tripDetail!.actualDistance} km',
                                subTitle: 'distance'.tr,
                              ),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeSmall,
                        ),
                        child: Text('trip_details'.tr,
                            style: textMedium.copyWith(
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault),
                        child: RouteWidget(
                          pickupAddress:
                              rideController.tripDetail!.pickupAddress!,
                          destinationAddress:
                              rideController.tripDetail!.destinationAddress!,
                          extraOne: firstRoute,
                          extraTwo: secondRoute,
                          entrance: rideController.tripDetail!.entrance,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(
                            Dimensions.paddingSizeDefault,
                            Dimensions.paddingSizeDefault,
                            Dimensions.paddingSizeDefault,
                            0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context)
                                  .hintColor
                                  .withValues(alpha: 0.45),
                            ),
                            borderRadius: BorderRadius.circular(
                                Dimensions.paddingSizeSmall),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: Dimensions.paddingSizeDefault),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'payment_details'.tr,
                                          style: textSemiBold.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                        ),
                                        Text(
                                          rideController
                                              .tripDetail!.paymentMethod!.tr,
                                          style: textSemiBold.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                        ),
                                      ]),
                                ),
                                PaymentItemInfoWidget(
                                  icon: Images.farePrice,
                                  title: 'fare_price'.tr,
                                  amount: rideController
                                          .tripDetail!.distanceWiseFare ??
                                      0,
                                ),
                                PaymentItemInfoWidget(
                                  icon: Images.idleHourIcon,
                                  title: 'idle_price'.tr,
                                  amount:
                                      rideController.tripDetail!.idleFee ?? 0,
                                ),
                                PaymentItemInfoWidget(
                                  icon: Images.waitingPrice,
                                  title: 'delay_price'.tr,
                                  amount:
                                      rideController.tripDetail!.delayFee ?? 0,
                                ),
                                PaymentItemInfoWidget(
                                  icon: Images.idleHourIcon,
                                  title: 'cancellation_price'.tr,
                                  amount: rideController
                                          .tripDetail!.cancellationFee ??
                                      0,
                                ),
                                PaymentItemInfoWidget(
                                  icon: Images.coupon,
                                  title: 'discount_amount'.tr,
                                  amount: rideController
                                          .tripDetail!.discountAmount ??
                                      0,
                                  discount: true,
                                  toolTipText:
                                      'discount_applied_for_this_ride'.tr,
                                  subTitle:
                                      'later_admin_will_pay_you_this_amount',
                                ),
                                PaymentItemInfoWidget(
                                  icon: Images.coupon,
                                  title: 'coupon_amount'.tr,
                                  amount:
                                      rideController.tripDetail!.couponAmount ??
                                          0,
                                  discount: true,
                                  toolTipText:
                                      'customer_applied_coupon_for_this_ride'
                                          .tr,
                                  subTitle:
                                      'later_admin_will_pay_you_this_amount',
                                ),
                                PaymentItemInfoWidget(
                                  icon: Images.farePrice,
                                  title: 'tips'.tr,
                                  amount: rideController.tripDetail!.tips ?? 0,
                                ),
                                PaymentItemInfoWidget(
                                  icon: Images.farePrice,
                                  title: 'vat_tax'.tr,
                                  amount:
                                      rideController.tripDetail!.vatTax ?? 0,
                                ),
                                PaymentItemInfoWidget(
                                    title: 'sub_total'.tr,
                                    amount: finalPrice,
                                    isSubTotal: true),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'payment_status'.tr,
                                          style: textSemiBold.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                        ),
                                        Text(
                                          rideController
                                              .tripDetail!.paymentStatus!.tr,
                                          style: textSemiBold.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                        ),
                                      ]),
                                ),
                              ]),
                        ),
                      ),
                      if (rideController.tripDetail!.paymentStatus ==
                              'unpaid' &&
                          rideController.tripDetail!.paidFare != '0')
                        Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeExtraSmall,
                              bottom: Dimensions.paddingSizeLarge),
                          child: ButtonWidget(
                            buttonText: 'request_for_payment'.tr,
                            onPressed: () {
                              Get.find<RideController>()
                                  .getFinalFare(rideController.tripDetail!.id!)
                                  .then((value) {
                                if (value.statusCode == 200) {
                                  Get.to(() => const PaymentReceivedScreen());
                                }
                              });
                            },
                          ),
                        ),
                    ]),
              )
            : const LoaderWidget();
      }),
    );
  }
}

class SummeryItem extends StatelessWidget {
  final String title;
  final String subTitle;

  const SummeryItem({super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(Icons.check_circle,
          size: Dimensions.iconSizeSmall,
          color: Theme.of(context).colorScheme.primary),
      Padding(
        padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeExtraSmall),
        child: Text(title,
            style: textMedium.copyWith(
                color: Theme.of(context).colorScheme.secondary)),
      ),
      Text(subTitle,
          style: textRegular.copyWith(color: Theme.of(context).hintColor)),
    ]);
  }
}
