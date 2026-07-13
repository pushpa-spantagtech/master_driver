import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/leaderboard/controllers/leader_board_controller.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TodayLeaderBoardStatusWidget extends StatelessWidget {
  const TodayLeaderBoardStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GetBuilder<LeaderBoardController>(
      builder: (leaderboardController) {
        final double totalIncome =
            double.tryParse(leaderboardController.totalIncome) ?? 0;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault,
            8,
            Dimensions.paddingSizeDefault,
            8,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.today_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'your_today'.tr,
                  style: textSemiBold.copyWith(
                    color: colorScheme.onPrimary,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    PriceConverter.convertPrice(
                      context,
                      totalIncome,
                    ),
                    style: textSemiBold.copyWith(
                      color: colorScheme.onPrimary,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${leaderboardController.totalTrip} ${'trips'.tr}',
                    style: textRegular.copyWith(
                      color: colorScheme.onSecondary,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
