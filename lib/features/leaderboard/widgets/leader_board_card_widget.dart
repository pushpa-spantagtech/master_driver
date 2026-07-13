import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/leaderboard/domain/models/leaderboard_model.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class LeaderBoardCardWidget extends StatelessWidget {
  final int index;
  final Leader leaderBoard;

  const LeaderBoardCardWidget({
    super.key,
    required this.index,
    required this.leaderBoard,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String income = leaderBoard.income ?? '0';
    final double parsedIncome = double.tryParse(income) ?? 0;
    final String firstName = leaderBoard.driver?.firstName ?? '';
    final String lastName = leaderBoard.driver?.lastName ?? '';
    final String fullName = '$firstName $lastName'.trim();

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: textSemiBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ClipOval(
            child: ImageWidget(
              width: 46,
              height: 46,
              fit: BoxFit.cover,
              image:
                  '${Get.find<SplashController>().config!.imageBaseUrl!.profileImage!}/${leaderBoard.driver?.profileImage ?? ''}',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${leaderBoard.totalRecords ?? 0} ${'trips'.tr}',
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            PriceConverter.convertPrice(context, parsedIncome),
            textAlign: TextAlign.right,
            style: textSemiBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
