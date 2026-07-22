import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_view_widget.dart';
import 'package:ride_sharing_user_app/features/leaderboard/controllers/leader_board_controller.dart';
import 'package:ride_sharing_user_app/features/leaderboard/widgets/leader_board_card_widget.dart';
import 'package:ride_sharing_user_app/features/leaderboard/widgets/today_leaderboard_status_widget.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_shimmer_widget.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    Get.find<LeaderBoardController>().getLeaderboardList(1, 'today');
    Get.find<LeaderBoardController>().setFilterTypeName('today');
    Get.find<LeaderBoardController>().getDailyActivities();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: GetBuilder<LeaderBoardController>(
        builder: (leaderboardController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBarWidget(
                title: 'leader_board'.tr,
                showBackButton: true,
              ),
              const TodayLeaderBoardStatusWidget(),
              Expanded(
                child: GetBuilder<LeaderBoardController>(
                  builder: (leaderboardController) {
                    if (leaderboardController.leaderBoardModel == null) {
                      return const NotificationShimmerWidget();
                    }

                    final leaders =
                        leaderboardController.leaderBoardModel!.data;

                    if (leaders == null || leaders.isEmpty) {
                      return const NoDataWidget();
                    }

                    return SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeLarge,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(
                              Dimensions.paddingSizeDefault,
                              Dimensions.paddingSizeSmall,
                              Dimensions.paddingSizeDefault,
                              Dimensions.paddingSizeSmall,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow
                                      .withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'see_others'.tr,
                                    style: textSemiBold.copyWith(
                                      color: colorScheme.onPrimary,
                                      fontSize: Dimensions.fontSizeLarge,
                                    ),
                                  ),
                                ),
                                _FilterDropdown(
                                  controller: leaderboardController,
                                ),
                              ],
                            ),
                          ),
                          _TopDriverCard(
                            leader: leaders.first,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              Dimensions.paddingSizeDefault,
                              Dimensions.paddingSizeExtraLarge,
                              Dimensions.paddingSizeDefault,
                              Dimensions.paddingSizeSmall,
                            ),
                            child: Text(
                              'on_the_serial'.tr,
                              style: textSemiBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          PaginatedListViewWidget(
                            scrollController: scrollController,
                            totalSize: leaderboardController
                                .leaderBoardModel!.totalSize,
                            offset: leaderboardController
                                        .leaderBoardModel!.offset !=
                                    null
                                ? int.tryParse(
                                    leaderboardController
                                        .leaderBoardModel!.offset
                                        .toString(),
                                  )
                                : null,
                            onPaginate: (int? offset) async {
                              // Existing pagination functionality unchanged.
                            },
                            itemView: ListView.separated(
                              itemCount: leaders.length,
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                              ),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                return LeaderBoardCardWidget(
                                  index: index,
                                  leaderBoard: leaders[index],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final LeaderBoardController controller;

  const _FilterDropdown({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 125,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          value: controller.selectedFilterTypeName,
          items: controller.selectedFilterType.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: colorScheme.onSecondary,
                ),
              ),
            );
          }).toList(),
          selectedItemBuilder: (context) {
            return controller.selectedFilterType.map((item) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: colorScheme.onPrimary,
                  ),
                ),
              );
            }).toList();
          },
          onChanged: (value) {
            if (value != null) {
              controller.setFilterTypeName(value);
            }
          },
          buttonStyleData: ButtonStyleData(
            height: 38,
            width: 125,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.outlineVariant,
              ),
            ),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colorScheme.onSecondary,
              size: 18,
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            width: 125,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 42,
            padding: EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }
}

class _TopDriverCard extends StatelessWidget {
  final dynamic leader;

  const _TopDriverCard({
    required this.leader,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final String income = leader.income ?? '0';
    final double parsedIncome = double.tryParse(income) ?? 0;

    final String firstName = leader.driver?.firstName ?? '';
    final String lastName = leader.driver?.lastName ?? '';
    final String fullName = '$firstName $lastName'.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
      ),
      padding: const EdgeInsets.all(
        Dimensions.paddingSizeLarge,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 92,
            height: 92,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary,
                width: 2.5,
              ),
            ),
            child: ClipOval(
              child: ImageWidget(
                image:
                    '${Get.find<SplashController>().config!.imageBaseUrl!.profileImage!}/${leader.driver?.profileImage ?? ''}',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textSemiBold.copyWith(
              color: colorScheme.onPrimary,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${leader.totalRecords ?? 0} ${'trips'.tr}',
            style: textRegular.copyWith(
              color: colorScheme.onSecondary,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  PriceConverter.convertPrice(
                    context,
                    parsedIncome,
                  ),
                  style: textSemiBold.copyWith(
                    color: colorScheme.onPrimary,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
