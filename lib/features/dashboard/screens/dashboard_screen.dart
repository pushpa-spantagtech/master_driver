import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/domain/models/navigation_model.dart';
import 'package:ride_sharing_user_app/features/home/screens/home_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/notification/screens/notification_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_screen.dart';
import 'package:ride_sharing_user_app/features/wallet/screens/wallet_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  final PageStorageBucket bucket = PageStorageBucket();

  bool _checkingCurrentRide = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RideController>().updateRoute(true, notify: true);
      Get.find<ProfileController>().getProfileInfo();
      _checkCurrentRide();
      Get.find<RideController>().getPendingRideRequestList(1);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkCurrentRide();
    }
  }

  Future<void> _checkCurrentRide() async {
    if (_checkingCurrentRide) {
      return;
    }

    _checkingCurrentRide = true;

    try {
      await Get.find<RideController>().getCurrentRideStatus(
        fromRefresh: true,
      );
    } finally {
      _checkingCurrentRide = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Get.find<RideController>().updateRoute(true);

    final List<NavigationModel> item = [
      NavigationModel(
        name: 'home'.tr,
        activeIcon: Images.homeActive,
        inactiveIcon: Images.homeOutline,
        screen: const HomeMenu(),
      ),
      NavigationModel(
        name: 'activity'.tr,
        activeIcon: Images.activityActive,
        inactiveIcon: Images.activityOutline,
        screen: const TripHistoryMenu(),
      ),
      NavigationModel(
        name: 'notification'.tr,
        activeIcon: Images.notificationActive,
        inactiveIcon: Images.notificationOutline,
        screen: const NotificationMenu(),
      ),
      NavigationModel(
        name: 'money'.tr,
        activeIcon: Images.moneyActive,
        inactiveIcon: Images.moneyOutline,
        screen: const WalletScreenMenu(),
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (Get.find<BottomMenuController>().currentTab != 0) {
          if (Get.find<ProfileController>().toggle) {
            Get.find<ProfileController>().toggleDrawer();
            Get.find<BottomMenuController>().setTabIndex(0);
          } else {
            Get.find<BottomMenuController>().setTabIndex(0);
          }
        } else {
          if (Get.find<ProfileController>().toggle) {
            Get.find<ProfileController>().toggleDrawer();
          } else {
            Get.find<BottomMenuController>().exitApp();
          }
        }
      },
      child: GetBuilder<BottomMenuController>(
        builder: (menuController) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                PageStorage(
                  bucket: bucket,
                  child: item[menuController.currentTab].screen,
                ),
                if (menuController.currentTab == 0)
                  GetBuilder<RideController>(
                    builder: (rideController) {
                      final String controllerStatus =
                          rideController.currentRideStatus.toLowerCase();
                      final String tripStatus =
                          (rideController.tripDetail?.currentStatus ?? '')
                              .toLowerCase();

                      const activeStatuses = <String>{
                        'accepted',
                        'confirmed',
                        'arrived',
                        'picked_up',
                        'ongoing',
                      };

                      final String effectiveStatus =
                          activeStatuses.contains(tripStatus)
                              ? tripStatus
                              : controllerStatus;

                      final bool hasActiveRide =
                          activeStatuses.contains(effectiveStatus) &&
                              rideController.tripDetail != null;

                      if (!hasActiveRide) {
                        return const SizedBox.shrink();
                      }

                      return Positioned(
                        left: 16,
                        right: 16,
                        bottom: 98,
                        child: _ActiveRideCard(
                          rideController: rideController,
                          status: effectiveStatus,
                        ),
                      );
                    },
                  ),
                Positioned(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeDefault,
                      ),
                      child: Container(
                        height: 68,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFE7E9EE),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x17101828),
                              blurRadius: 24,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: generateBottomNavigationItems(
                            menuController,
                            item,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> generateBottomNavigationItems(
    BottomMenuController menuController,
    List<NavigationModel> item,
  ) {
    List<Widget> items = [];

    for (int index = 0; index < item.length; index++) {
      items.add(
        Expanded(
          child: CustomMenuItem(
            isSelected: menuController.currentTab == index,
            name: item[index].name,
            activeIcon: item[index].activeIcon,
            inActiveIcon: item[index].inactiveIcon,
            onTap: () => menuController.setTabIndex(index),
          ),
        ),
      );
    }

    return items;
  }
}

class _ActiveRideCard extends StatelessWidget {
  final RideController rideController;
  final String status;

  const _ActiveRideCard({
    required this.rideController,
    required this.status,
  });

  static const Color _brandRed = Color(0xFFE71921);
  static const Color _ink = Color(0xFF111827);
  static const Color _muted = Color(0xFF667085);
  static const Color _softRed = Color(0xFFFFECEE);

  bool get _isOngoing => status == 'ongoing' || status == 'picked_up';

  @override
  Widget build(BuildContext context) {
    final trip = rideController.tripDetail;

    final String firstName = trip?.customer?.firstName?.trim() ?? '';
    final String lastName = trip?.customer?.lastName?.trim() ?? '';
    final String customerName = '$firstName $lastName'.trim().isEmpty
        ? 'Customer'
        : '$firstName $lastName'.trim();

    final String pickupAddress = trip?.pickupAddress?.trim() ?? '';
    final String destinationAddress = trip?.destinationAddress?.trim() ?? '';

    final String address = _isOngoing
        ? (destinationAddress.isNotEmpty
            ? destinationAddress
            : 'Continue to destination')
        : (pickupAddress.isNotEmpty
            ? pickupAddress
            : 'Continue to customer pickup');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _openRideScreen,
        child: Ink(
          height: 78,
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE7E9EE),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26101828),
                blurRadius: 24,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: _softRed,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isOngoing
                      ? Icons.navigation_rounded
                      : Icons.person_pin_circle_rounded,
                  color: _brandRed,
                  size: 26,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _isOngoing ? 'Ride in progress' : 'Customer pickup',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 14.5,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _softRed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _isOngoing ? 'ONGOING' : 'ACCEPTED',
                            style: const TextStyle(
                              color: _brandRed,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$customerName • $address',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12.2,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: _brandRed,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openRideScreen() async {
    final String? tripId = rideController.tripDetail?.id;

    if (_isOngoing) {
      Get.find<RiderMapController>().setRideCurrentState(RideState.ongoing);
    } else {
      Get.find<RiderMapController>().setRideCurrentState(RideState.accepted);
    }

    if (tripId != null && tripId.isNotEmpty) {
      await rideController.remainingDistance(
        tripId,
        mapBound: true,
      );
      rideController.startLiveTracking(tripId);
    }

    rideController.updateRoute(false, notify: true);

    await Get.to(
      () => const MapScreen(fromScreen: 'home'),
    );
  }
}

class CustomMenuItem extends StatelessWidget {
  final bool isSelected;
  final String name;
  final String activeIcon;
  final String inActiveIcon;
  final VoidCallback onTap;

  const CustomMenuItem({
    super.key,
    required this.isSelected,
    required this.name,
    required this.activeIcon,
    required this.inActiveIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color selectedColor = Color(0xFFE71921);
    const Color unselectedColor = Color(0xFF98A2B3);

    return InkWell(
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                isSelected ? activeIcon : inActiveIcon,
                width: Dimensions.menuIconSize,
                height: Dimensions.menuIconSize,
                color: isSelected ? selectedColor : unselectedColor,
              ),
              const SizedBox(height: 3),
              Text(
                name.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textRegular.copyWith(
                  color: isSelected ? selectedColor : unselectedColor,
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
