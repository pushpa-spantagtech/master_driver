import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';

import '../screens/payment_received_screen.dart';

class TripCard extends StatelessWidget {
  final TripDetail tripModel;

  const TripCard({super.key, required this.tripModel});

  @override
  Widget build(BuildContext context) {
    final String pickupAddress = tripModel.pickupAddress ?? '';
    final String destinationAddress = tripModel.destinationAddress ?? '';
    final double paidFare = double.tryParse(tripModel.paidFare ?? '0') ?? 0;

    return GestureDetector(
      onTap: () {
        if (tripModel.currentStatus == 'accepted' ||
            tripModel.currentStatus == 'ongoing') {
          if (tripModel.currentStatus == "accepted") {
            Get.find<RideController>()
                .getRideDetails(tripModel.id!)
                .then((value) {
              if (value.statusCode == 200) {
                Get.find<RiderMapController>()
                    .setRideCurrentState(RideState.accepted);
                Get.find<RiderMapController>().setMarkersInitialPosition();
                Get.find<RideController>().updateRoute(false, notify: true);
                Get.to(() => const MapScreen(fromScreen: 'splash'));
              }
            });
          } else if (tripModel.currentStatus == "completed" &&
              tripModel.paymentStatus == 'unpaid') {
            Get.find<RideController>()
                .getFinalFare(tripModel.id!)
                .then((value) {
              if (value.statusCode == 200) {
                Get.to(() => const PaymentReceivedScreen());
              }
            });
          } else {
            Get.find<RiderMapController>()
                .setRideCurrentState(RideState.ongoing);
            Get.find<RideController>()
                .getRideDetails(tripModel.id!)
                .then((value) {
              if (value.statusCode == 200) {
                Get.find<RiderMapController>().setMarkersInitialPosition();
                Get.find<RideController>().updateRoute(false, notify: true);
                Get.to(() => const MapScreen(fromScreen: 'splash'));
              }
            });
          }
        } else {
          Get.to(() => TripDetails(tripId: tripModel.id!));
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Dimensions.paddingSizeDefault,
          0,
          Dimensions.paddingSizeDefault,
          Dimensions.paddingSizeDefault,
        ),
        child: Material(
          color: Theme.of(context).cardColor,
          elevation: 0,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(children: [
                if (tripModel.currentStatus == 'ongoing' &&
                    tripModel.type != 'parcel')
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: tripModel.screenshot != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ImageWidget(
                        image: tripModel.screenshot,
                        width: Get.width,
                        height: Get.width / 1.5,
                        fit: BoxFit.fitWidth,
                      ),
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(Images.mapSample),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding:
                          const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: tripModel.type == 'parcel'
                              ? Image.asset(Images.parcel)
                              : Image.asset(
                            tripModel.vehicleCategory != null
                                ? tripModel.vehicleCategory!.type == "car"
                                ? Images.car
                                : Images.bike
                                : Images.car,
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AddressLine(
                              icon: Icons.radio_button_checked_rounded,
                              iconColor: Theme.of(context).colorScheme.primary,
                              text: pickupAddress,
                              textStyle: textMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 6, top: 3, bottom: 3),
                              child: Container(
                                height: 14,
                                width: 1.5,
                                color: Theme.of(context)
                                    .dividerColor
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                            _AddressLine(
                              icon: Icons.location_on_rounded,
                              iconColor: Theme.of(context).colorScheme.error,
                              text: destinationAddress,
                              textStyle: textRegular.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Row(children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 14,
                                  color: Theme.of(context).hintColor),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  DateConverter.isoStringToDateTimeString(
                                      tripModel.createdAt!),
                                  style: textRegular.copyWith(
                                    color: Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: .82),
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Row(children: [
                              Expanded(
                                child: Text(
                                  '${'total'.tr} ${PriceConverter.convertPrice(context, paidFare)}',
                                  style: textBold.copyWith(
                                    color:
                                    Theme.of(context).colorScheme.primary,
                                    fontSize: Dimensions.fontSizeDefault,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (tripModel.currentStatus == 'ongoing')
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: Dimensions.paddingSizeSmall),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeExtraSmall,
                                    horizontal: Dimensions.paddingSizeSmall,
                                  ),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                          .withValues(alpha: 0.55),
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Text(
                                      tripModel.type == 'parcel'
                                          ? 'on_the_way'.tr
                                          : 'ongoing'.tr,
                                      style: textBold.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontSize: Dimensions.fontSizeSmall,
                                      )),
                                )
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.chevron_right_rounded,
                            size: 24,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressLine extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final TextStyle textStyle;

  const _AddressLine({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: textStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
