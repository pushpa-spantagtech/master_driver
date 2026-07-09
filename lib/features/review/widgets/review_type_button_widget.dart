import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/review/controllers/review_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ReviewTypeButtonWidget extends StatelessWidget {
  final int index;
  final String reviewType;

  const ReviewTypeButtonWidget({
    super.key,
    required this.index,
    required this.reviewType,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(builder: (reviewController) {
      final bool isSelected = index == reviewController.reviewTypeIndex;

      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeExtraSmall),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          onTap: () {
            reviewController.isLoading
                ? null
                : reviewController.setReviewIndex(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: MediaQuery.of(context).size.width / 2.5,
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeSmall,
              horizontal: Dimensions.paddingSizeDefault,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFFF3D8)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFD27A)
                    : Theme.of(context).hintColor.withValues(alpha: 0.13),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: isSelected ? 0.055 : 0.025),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                reviewType.tr,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textSemiBold.copyWith(
                  color: isSelected
                      ? const Color(0xFFFFA000)
                      : Theme.of(context).hintColor.withValues(alpha: 0.70),
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
