import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';

class CustomerInfoWidget extends StatelessWidget {
  final Customer? customer;
  final bool fromTripDetails;
  final String? fare;
  final String? customerRating;

  const CustomerInfoWidget(
      {super.key,
      this.fromTripDetails = false,
      required this.customer,
      this.fare,
      this.customerRating});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (riderController) {
      return Padding(
          padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeDefault,
              horizontal: Dimensions.paddingSizeSmall),
          child: Row(children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color.fromRGBO(255, 0, 0, 0.13), width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: ImageWidget(
                  height: 50,
                  width: 50,
                  image: customer?.profileImage != null
                      ? '${Get.find<SplashController>().config!.imageBaseUrl!.profileImageCustomer}/${customer?.profileImage ?? ''}'
                      : '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            if (customer != null)
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (customer!.firstName != null && customer!.lastName != null)
                    Text(
                      '${customer!.firstName!} ${customer!.lastName!}',
                      style: textBold.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  if (customerRating != null && customerRating!.isNotEmpty)
                    Row(children: [
                      Icon(
                        Icons.star_rate_rounded,
                        color: Theme.of(Get.context!).colorScheme.primary,
                        size: Dimensions.iconSizeMedium,
                      ),
                      Text(double.parse(customerRating!).toStringAsFixed(1),
                          style: textRegular.copyWith())
                    ])
                ],
              )),
            fromTripDetails
                ? const SizedBox()
                : Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(
                      'estimated_fare'.tr,
                      style: textMedium.copyWith(
                          color: Theme.of(Get.context!).colorScheme.secondary),
                    ),
                    Text(
                        PriceConverter.convertPrice(Get.context!,
                            fare != null ? double.parse(fare!) : 0),
                        style: textSemiBold.copyWith(
                            color:
                                Theme.of(Get.context!).colorScheme.onPrimary))
                  ])
          ]));
    });
  }
}
