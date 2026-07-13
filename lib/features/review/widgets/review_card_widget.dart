import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/review/controllers/review_controller.dart';
import 'package:ride_sharing_user_app/features/review/domain/models/review_model.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ReviewCardWidget extends StatelessWidget {
  final Review review;
  final int index;

  const ReviewCardWidget({
    super.key,
    required this.review,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      child: GetBuilder<ReviewController>(builder: (reviewController) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).hintColor.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${'trip'.tr} # ${review.tripRefId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textSemiBold.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          Images.calenderIcon,
                          color: const Color(0xFFFFA000),
                          height: 16,
                          width: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateConverter.localToIsoString(
                            DateTime.parse(review.createdAt!),
                          ),
                          style: textMedium.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FA),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            Theme.of(context).hintColor.withValues(alpha: 0.12),
                      ),
                    ),
                    child: ClipOval(
                      child: ImageWidget(
                        image:
                            '${Get.find<SplashController>().config!.imageBaseUrl!.profileImageCustomer!}/${review.givenUser!.profileImage ?? ''}',
                        height: 42,
                        width: 42,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${review.givenUser!.firstName!} ${review.givenUser!.lastName!}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textSemiBold.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'rate_your_service'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFA000),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          review.rating.toString(),
                          style: textSemiBold.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (review.feedback != null && review.feedback!.isNotEmpty) ...[
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ReadMoreText(
                    review.feedback ?? '',
                    trimLines: 3,
                    colorClickableText: Theme.of(context).primaryColor,
                    trimMode: TrimMode.Line,
                    textAlign: TextAlign.start,
                    trimCollapsedText: 'show_more'.tr,
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    trimExpandedText: 'show_less'.tr,
                    lessStyle: textSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    moreStyle: textSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(
                children: [
                  Container(
                    height: 4,
                    width: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA000).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      reviewController.saveReview(review.id.toString(), index);
                    },
                    child: Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: review.isSaved!
                            ? const Color(0xFFFFF3D8)
                            : Theme.of(context)
                                .hintColor
                                .withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: review.isSaved!
                              ? const Color(0xFFFFD27A)
                              : Theme.of(context)
                                  .hintColor
                                  .withValues(alpha: 0.10),
                        ),
                      ),
                      child: review.isLoading!
                          ? Padding(
                              padding: const EdgeInsets.all(9),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Get.isDarkMode
                                    ? Theme.of(context)
                                        .hintColor
                                        .withValues(alpha: .5)
                                    : const Color(0xFFFFA000),
                              ),
                            )
                          : Icon(
                              review.isSaved!
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              size: 21,
                              color: review.isSaved!
                                  ? const Color(0xFFFFA000)
                                  : Theme.of(context).hintColor,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
