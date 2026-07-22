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
