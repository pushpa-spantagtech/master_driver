import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/review/screens/review_screen.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/chart_widget.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripOverviewWidget extends StatelessWidget {
  final TripController tripController;

  const TripOverviewWidget({super.key, required this.tripController});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color surfaceColor = Theme.of(context).cardColor;
    final Color textColor = Theme.of(context).textTheme.bodyMedium!.color!;

    return Expanded(
      child: GetBuilder<TripController>(builder: (tripController) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeDefault,
            Dimensions.paddingSizeSmall,
            Dimensions.paddingSizeDefault,
            110,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'trips_overview'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(
                        color: textColor,
                        fontSize: Dimensions.fontSizeExtraLarge,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  _OverviewFilterDropdown(tripController: tripController),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.show_chart_rounded,
                            color: primaryColor,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Earnings Overview',
                                style: textSemiBold.copyWith(
                                  color: textColor,
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tripController.selectedOverview.tr,
                                style: textRegular.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            PriceConverter.convertPrice(
                              context,
                              tripController.tripOverView?.totalEarn ?? 0,
                            ),
                            style: textSemiBold.copyWith(
                              color: primaryColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 220,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(0, 8, 4, 0),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const ChartWidget(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text(
                'reports'.tr,
                style: textBold.copyWith(
                  color: textColor,
                  fontSize: Dimensions.fontSizeExtraLarge,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              ReportsItemCard(
                title: 'total_trip',
                qty: tripController.tripOverView?.totalTrips ?? 0,
                icon: Icons.local_taxi_rounded,
              ),
              ReportsItemCard(
                title: 'total_trip_amount',
                amount: tripController.tripOverView?.totalEarn ?? 0,
                isTotal: true,
                icon: Icons.account_balance_wallet_rounded,
              ),
              ReportsItemCard(
                title: 'total_cancel_trip',
                qty: tripController.tripOverView?.totalCancel ?? 0,
                icon: Icons.cancel_rounded,
              ),
              GestureDetector(
                onTap: () => Get.to(const ReviewScreen()),
                child: ReportsItemCard(
                  title: 'total_review',
                  qty: tripController.tripOverView?.totalReviews ?? 0,
                  icon: Icons.star_rounded,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _OverviewFilterDropdown extends StatelessWidget {
  final TripController tripController;

  const _OverviewFilterDropdown({required this.tripController});

  void _showOverviewFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'filter'.tr,
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...tripController.selectedOverviewType.map((item) {
                  final bool selected = item == tripController.selectedOverview;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: selected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.10)
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          tripController.setOverviewType(item);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 13),
                          child: Row(
                            children: [
                              Icon(
                                selected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: 21,
                                color: selected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).hintColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.tr,
                                  style: textMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: selected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                  ),
                                ),
                              ),
                              if (selected)
                                Icon(
                                  Icons.check_rounded,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showOverviewFilterSheet(context),
        child: Container(
          height: 42,
          constraints: const BoxConstraints(minWidth: 112),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  tripController.selectedOverview.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.expand_more_rounded,
                size: 20,
                color: Theme.of(context).hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportsItemCard extends StatelessWidget {
  final String? title;
  final double? amount;
  final bool isTotal;
  final int? qty;
  final bool isReview;
  final IconData icon;

  const ReportsItemCard({
    super.key,
    this.title,
    this.amount,
    this.isTotal = false,
    this.qty,
    this.isReview = false,
    this.icon = Icons.analytics_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color textColor = Theme.of(context).textTheme.bodyMedium!.color!;
    final String value = isTotal
        ? PriceConverter.convertPrice(context, amount ?? 0)
        : (qty ?? 0).toString();

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
        border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.09)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primaryColor, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title!.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textMedium.copyWith(
                color: textColor,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textBold.copyWith(
              color: primaryColor,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
        ],
      ),
    );
  }
}
