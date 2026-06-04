import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_radio_button.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CancellationRadioButton extends StatefulWidget {
  final bool isOngoing;

  const CancellationRadioButton({super.key, required this.isOngoing});

  @override
  State<CancellationRadioButton> createState() =>
      _CancellationRadioButtonState();
}

class _CancellationRadioButtonState extends State<CancellationRadioButton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'why_do_you_want_to_cancel'.tr,
          style: textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
        const SizedBox(
          height: Dimensions.paddingSizeDefault,
        ),
        GetBuilder<TripController>(builder: (tripController) {
          List<String> cancelList = [];
          if (widget.isOngoing) {
            cancelList =
                tripController.tripCancellationCauseList?.data?.isNotEmpty ==
                        true
                    ? tripController
                            .tripCancellationCauseList!.data![0].ongoingRide ??
                        []
                    : [];
          } else {
            cancelList =
                tripController.tripCancellationCauseList?.data?.isNotEmpty ==
                        true
                    ? tripController
                            .tripCancellationCauseList!.data![0].acceptedRide ??
                        []
                    : [];
          }
          if (cancelList.isEmpty) {
            cancelList = [
              "Customer requested cancel",
              "Customer not responding",
              "Trip taking too long",
            ];
          }
          int length = cancelList.length;
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(
                    color: Theme.of(context)
                        .primaryColor
                        .withValues(alpha: 0.15))),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: length,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CustomRadioButton(
                    text: cancelList[index],
                    isSelected:
                        tripController.tripCancellationCauseCurrentIndex ==
                            index,
                    onTap: () {
                      tripController.setCancellationCurrentIndex(index);
                      setState(() {});
                    },
                    length: length,
                    index: index,
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                  height: 0,
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
