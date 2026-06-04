import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/review/controllers/review_controller.dart';

class ReviewTypeButtonWidget extends StatelessWidget {
  final int index;
  final String reviewType;

  const ReviewTypeButtonWidget(
      {super.key, required this.index, required this.reviewType});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(builder: (reviewController) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeExtraSmall),
        child: InkWell(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          onTap: () {
            reviewController.isLoading
                ? null
                : reviewController.setReviewIndex(index);
          },
          child: Container(
            width: MediaQuery.of(context).size.width / 2.5,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              border: Border.all(
                width: .5,
                color: index == reviewController.reviewTypeIndex
                    ? Theme.of(context).colorScheme.tertiaryContainer
                    : Theme.of(context).hintColor.withValues(alpha: 0.45),
              ),
              color: index == reviewController.reviewTypeIndex
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    reviewType.tr,
                    textAlign: TextAlign.center,
                    style: textSemiBold.copyWith(
                      color: index == reviewController.reviewTypeIndex
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).hintColor.withValues(alpha: 0.65),
                      fontSize: Dimensions.fontSizeLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
