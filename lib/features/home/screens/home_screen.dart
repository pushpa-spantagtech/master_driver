import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_bottom_sheet_widget.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/home_screen_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/home/widgets/add_vehicle_design_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/my_activity_list_view_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/ongoing_ride_card_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/profile_info_card_widget.dart';
import 'package:ride_sharing_user_app/features/home/widgets/vehicle_pending_widget.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_menu_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/sliver_delegate.dart';
import 'package:ride_sharing_user_app/common_widgets/zoom_drawer_context_widget.dart';

class HomeMenu extends GetView<ProfileController> {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (profileController) => ZoomDrawer(
        controller: profileController.zoomDrawerController,
        menuScreen: const ProfileMenuScreen(),
        mainScreen: const HomeScreen(),
        borderRadius: 24.0,
        isRtl: !Get.find<LocalizationController>().isLtr,
        angle: -5.0,
        menuBackgroundColor: Theme.of(context).primaryColor,
        slideWidth: MediaQuery.of(context).size.width * 0.85,
        mainScreenScale: .4,
        mainScreenTapClose: true,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool clickedMenu = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  Future<void> loadData() async {
    final profileController = Get.find<ProfileController>();
    final rideController = Get.find<RideController>();

    // Start dashboard data calls without blocking first screen render.
    profileController.getCategoryList(1);
    profileController.getDailyLog();
    rideController.getOngoingParcelList();
    profileController.getProfileLevelInfo();

    rideController.getLastTrip().then((_) {
      if (rideController.ongoingTripDetails != null) {
        HomeScreenHelper().pendingLastRidePusherImplementation();
      }
    }).catchError((error) {
      debugPrint('getLastTrip error: $error');
    });

    rideController
        .getPendingRideRequestList(1, limit: 100)
        .then((_) {
      if (rideController.getPendingRideRequestModel != null) {
        HomeScreenHelper().pendingParcelListPusherImplementation();
      }
    }).catchError((error) {
      debugPrint('getPendingRideRequestList error: $error');
    });

    if (profileController.profileInfo?.vehicle == null &&
        profileController.profileInfo?.vehicleStatus == 0 &&
        profileController.isFirstTimeShowBottomSheet) {
      profileController.updateFirstTimeShowBottomSheet(false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          isDismissible: false,
          builder: (_) => const HomeBottomSheetWidget(),
        );
      });
    }

    HomeScreenHelper().checkMaintanenceMode();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        Get.find<ProfileController>().getProfileInfo();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Stack(children: [
          CustomScrollView(slivers: [
            SliverPersistentHeader(
                pinned: true,
                delegate: SliverDelegate(
                    height: GetPlatform.isIOS ? 150 : 120,
                    child: Column(children: [
                      AppBarWidget(
                        title: 'dashboard'.tr,
                        showBackButton: false,
                        onTap: () {
                          Get.find<ProfileController>().toggleDrawer();
                        },
                      ),
                    ]))),
            SliverToBoxAdapter(child:
                GetBuilder<ProfileController>(builder: (profileController) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60.0),
                    if (profileController.profileInfo?.vehicle != null &&
                        profileController.profileInfo?.vehicleStatus != 0 &&
                        profileController.profileInfo?.vehicleStatus != 1)
                      GetBuilder<RideController>(builder: (rideController) {
                        return const OngoingRideCardWidget();
                      }),
                    if (profileController.profileInfo?.vehicle == null &&
                        profileController.profileInfo?.vehicleStatus == 0)
                      const AddYourVehicleWidget(),
                    if (profileController.profileInfo?.vehicle != null &&
                        profileController.profileInfo?.vehicleStatus == 1)
                      VehiclePendingWidget(
                        icon: Images.reward1,
                        description:
                            'create_account_approve_description_vehicle'.tr,
                        title: 'registration_not_approve_yet_vehicle'.tr,
                      ),
                    if (Get.find<ProfileController>().profileInfo?.vehicle !=
                        null)
                      const MyActivityListViewWidget(),
                    const SizedBox(height: 100),
                  ]);
            }))
          ]),
          Positioned(
            top: GetPlatform.isIOS ? 120 : 90,
            left: 0,
            right: 0,
            child: GetBuilder<ProfileController>(builder: (profileController) {
              return GestureDetector(
                  onTap: () {
                    Get.to(() => const ProfileScreen());
                  },
                  child: ProfileStatusCardWidget(
                      profileController: profileController));
            }),
          ),
        ]),
        // floatingActionButton:
        //     GetBuilder<RideController>(builder: (rideController) {
        //   int ridingCount = (rideController.ongoingTrip == null ||
        //           rideController.ongoingTrip!.isEmpty)
        //       ? 0
        //       : (rideController.ongoingTrip![0].currentStatus == 'ongoing' ||
        //               rideController.ongoingTrip![0].currentStatus ==
        //                   'accepted' ||
        //               (rideController.ongoingTrip![0].currentStatus ==
        //                       'completed' &&
        //                   rideController.ongoingTrip![0].paymentStatus ==
        //                       'unpaid') ||
        //               (rideController.ongoingTrip![0].currentStatus ==
        //                           'cancelled' &&
        //                       rideController.ongoingTrip![0].paymentStatus ==
        //                           'unpaid' &&
        //                       rideController.ongoingTrip![0].cancelledBy ==
        //                           'customer') &&
        //                   rideController.ongoingTrip![0].type != 'parcel')
        //           ? 1
        //           : 0;
        //   int parcelCount = rideController.parcelListModel?.totalSize ?? 0;
        //   return Padding(
        //     padding: const EdgeInsets.only(bottom: 80),
        //     child: CustomMenuButtonWidget(
        //       openForegroundColor: Theme.of(context).primaryColor,
        //       closedBackgroundColor: Theme.of(context).primaryColor,
        //       openBackgroundColor: Theme.of(context).primaryColor,
        //       labelsBackgroundColor: Theme.of(context).colorScheme.surface,
        //       speedDialChildren: <CustomMenuWidget>[
        //         CustomMenuWidget(
        //           child: Icon(
        //             Icons.directions_run,
        //             color: Theme.of(context).colorScheme.primary,
        //           ),
        //           foregroundColor: Theme.of(context).primaryColor,
        //           backgroundColor: Theme.of(context).primaryColor,
        //           label: 'ongoing_ride'.tr,
        //           onPressed: () => _openOngoingRide(rideController),
        //           closeSpeedDialOnPressed: true,
        //         ),
        //       ],
        //       child: Padding(
        //         padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        //         child: Badge(
        //             label: Text('${ridingCount + parcelCount}'),
        //             child: Image.asset(
        //               Images.ongoing,
        //               color: Theme.of(context).colorScheme.primary,
        //             )),
        //       ),
        //     ),
        //   );
        // })
      ),
    );
  }

  // Future<void> _openOngoingRide(RideController rideController) async {
  //   if (rideController.ongoingTrip == null ||
  //       rideController.ongoingTrip!.isEmpty) {
  //     showCustomSnackBar('no_trip_available'.tr);
  //     return;
  //   }
  //
  //   final trip = rideController.ongoingTrip!.first;
  //   final String status = (trip.currentStatus ?? '').toLowerCase();
  //   final String paymentStatus = (trip.paymentStatus ?? '').toLowerCase();
  //
  //   final bool canOpen = status == 'accepted' ||
  //       status == 'confirmed' ||
  //       status == 'arrived' ||
  //       status == 'picked_up' ||
  //       status == 'ongoing' ||
  //       ((status == 'completed' || status == 'cancelled') &&
  //           paymentStatus == 'unpaid');
  //
  //   if (!canOpen) {
  //     showCustomSnackBar('no_trip_available'.tr);
  //     return;
  //   }
  //
  //   // Fetch the latest ride details first. The existing controller keeps all
  //   // accepted/ongoing/payment routing behaviour unchanged.
  //   await rideController.getCurrentRideStatus(froDetails: true);
  //
  //   final String latestStatus = rideController.currentRideStatus.toLowerCase();
  //   final String? tripId = rideController.tripDetail?.id;
  //
  //   if ((latestStatus == 'accepted' || latestStatus == 'ongoing') &&
  //       tripId != null &&
  //       tripId.isNotEmpty &&
  //       !Get.currentRoute.contains('MapScreen')) {
  //     final mapController = Get.find<RiderMapController>();
  //     mapController.setRideCurrentState(
  //       latestStatus == 'ongoing' ? RideState.ongoing : RideState.accepted,
  //     );
  //
  //     await rideController.remainingDistance(tripId, mapBound: true);
  //     rideController.startLiveTracking(tripId);
  //     rideController.updateRoute(false, notify: true);
  //
  //     await Get.to(() => const MapScreen(fromScreen: 'home'));
  //   }
  // }
}
