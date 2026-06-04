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
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).hintColor.withValues(alpha: .20),
                  blurRadius: 1,
                  spreadRadius: 1,
                  offset: const Offset(1, 1),
                )
              ]),
          child: Column(children: [
            if (tripModel.currentStatus == 'ongoing' &&
                tripModel.type != 'parcel')
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: tripModel.screenshot != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                            Dimensions.paddingSizeDefault),
                        child: ImageWidget(
                          image: tripModel.screenshot,
                          width: Get.width,
                          height: Get.width / 1.5,
                          fit: BoxFit.fitWidth,
                        ),
                      )
                    : Image.asset(Images.mapSample),
              ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Row(children: [
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(
                          Dimensions.paddingSizeExtraSmall)),
                  height: Dimensions.orderStatusIconHeight,
                  width: Dimensions.orderStatusIconHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
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
                      Text(tripModel.pickupAddress!, style: textMedium),
                      Text(tripModel.destinationAddress!, style: textRegular),
                      Text(
                        DateConverter.isoStringToDateTimeString(
                            tripModel.createdAt!),
                        style: textRegular.copyWith(
                          color: Theme.of(context).hintColor.withValues(alpha: .85),
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                      Row(children: [
                        Text(
                            '${'total'.tr} ${PriceConverter.convertPrice(context, double.parse(tripModel.paidFare!))}'),
                        const Spacer(),
                        if (tripModel.currentStatus == 'ongoing')
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall),
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeTiny,
                              horizontal: Dimensions.paddingSizeExtraSmall,
                            ),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.paddingSizeExtraSmall)),
                            child: Text(
                                tripModel.type == 'parcel'
                                    ? 'on_the_way'.tr
                                    : 'ongoing'.tr,
                                style: textBold),
                          )
                      ]),
                    ])),
                SizedBox(
                  width: Dimensions.iconSizeSmall,
                  child: Icon(Icons.arrow_forward_ios_rounded,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
