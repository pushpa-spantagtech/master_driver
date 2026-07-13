import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/loader_widget.dart';
import 'package:ride_sharing_user_app/features/leaderboard/screens/leaderboard_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/widgets/calculating_sub_total_widget.dart';
import 'package:ride_sharing_user_app/features/map/widgets/accepted_rider_widget.dart';
import 'package:ride_sharing_user_app/features/map/widgets/custom_icon_card_widget.dart';
import 'package:ride_sharing_user_app/features/map/widgets/customer_ride_request_card_widget.dart';
import 'package:ride_sharing_user_app/features/map/widgets/end_trip_dialog_widget.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/screens/ride_request_list_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'stay_online_widget.dart';
import 'ride_ongoing_widget.dart';

class RiderBottomSheetWidget extends StatelessWidget {
  final GlobalKey<ExpandableBottomSheetState> expandableKey;

  const RiderBottomSheetWidget({
    super.key,
    required this.expandableKey,
  });

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double maxSheetHeight =
        mediaQuery.size.height - mediaQuery.padding.top - 24;

    return GetBuilder<RiderMapController>(
      builder: (riderController) {
        return GetBuilder<RideController>(
          builder: (rideController) {
            return GetBuilder<ProfileController>(
              builder: (profileController) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxSheetHeight),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: mediaQuery.size.width,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(
                            Dimensions.paddingSizeDefault,
                          ),
                          topRight: Radius.circular(
                            Dimensions.paddingSizeDefault,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).hintColor,
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: Dimensions.paddingSizeDefault,
                          left: Dimensions.paddingSizeDefault,
                          right: Dimensions.paddingSizeDefault,
                          bottom: mediaQuery.padding.bottom,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 5,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Theme.of(context).disabledColor,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeExtraSmall,
                                ),
                              ),
                            ),
                            if (riderController.currentRideState ==
                                RideState.initial)
                              const StayOnlineWidget(),
                            if (riderController.currentRideState ==
                                RideState.pending)
                              CustomerRideRequestCardWidget(
                                rideRequest: rideController.tripDetail!,
                              ),
                            if (riderController.currentRideState ==
                                RideState.accepted)
                              RideAcceptedWidget(
                                expandableKey: expandableKey,
                              ),
                            if (riderController.currentRideState ==
                                RideState.ongoing)
                              RideOngoingWidget(
                                tripId: rideController.tripDetail!.id!,
                                expandableKey: expandableKey,
                              ),
                            if (riderController.currentRideState ==
                                RideState.end)
                              const EndTripWidget(),
                            if (riderController.currentRideState ==
                                RideState.completed)
                              const CalculatingSubTotalWidget(),
                            if (riderController.currentRideState ==
                                RideState.initial)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  Dimensions.paddingSizeSmall,
                                  0,
                                  Dimensions.paddingSizeDefault,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    riderController.isRefresh
                                        ? const LoaderWidget()
                                        : CustomIconCardWidget(
                                            title: 'refresh'.tr,
                                            index: 0,
                                            icon: Images.mIcon3,
                                            iconColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            onTap:
                                                riderController.isRefreshLoader,
                                          ),
                                    CustomIconCardWidget(
                                      title: 'leader_board'.tr,
                                      index: 1,
                                      icon: Images.mIcon2,
                                      iconColor:
                                          Theme.of(context).colorScheme.primary,
                                      onTap: () => Get.to(
                                        () => const LeaderboardScreen(),
                                      ),
                                    ),
                                    CustomIconCardWidget(
                                      title: 'trip_request'.tr,
                                      index: 2,
                                      icon: Images.mIcon1,
                                      iconColor:
                                          Theme.of(context).colorScheme.primary,
                                      onTap: () {
                                        if (!Get.currentRoute.contains(
                                          'RideRequestScreen',
                                        )) {
                                          Get.to(
                                            () => const RideRequestScreen(),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
