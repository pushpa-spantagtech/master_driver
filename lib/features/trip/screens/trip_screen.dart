import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_menu_screen.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/trip_overview_widget.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/trips_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/zoom_drawer_context_widget.dart';

class TripHistoryMenu extends GetView<ProfileController> {
  const TripHistoryMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (profileController) => ZoomDrawer(
        controller: profileController.zoomDrawerController,
        menuScreen: const ProfileMenuScreen(),
        mainScreen: const TripHistoryScreen(),
        borderRadius: 24.0,
        angle: -5.0,
        isRtl: !Get.find<LocalizationController>().isLtr,
        menuBackgroundColor: Theme.of(context).primaryColor,
        slideWidth: MediaQuery.of(context).size.width * 0.85,
        mainScreenScale: .4,
        mainScreenTapClose: true,
      ),
    );
  }
}

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    Get.find<TripController>().getTripList(1, '', '', "ride_request",
        Get.find<TripController>().selectedFilterTypeName);
    Get.find<TripController>()
        .getTripOverView(Get.find<TripController>().selectedOverview);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<TripController>(builder: (tripController) {
        return Column(children: [
          AppBarWidget(
            title: 'trip_history'.tr,
            showBackButton: false,
            onTap: () {
              Get.find<ProfileController>().toggleDrawer();
            },
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeSmall,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              height: 52,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.20),
                ),
              ),
              child: Row(
                children: List.generate(tripController.activityTypeList.length,
                    (index) {
                  final bool selected =
                      tripController.activityTypeIndex == index;
                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      onTap: () => tripController.setActivityTypeIndex(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? Theme.of(context).cardColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: null,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            tripController.activityTypeList[index].tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          tripController.activityTypeIndex == 0
              ? TripsWidget(
                  tripController: tripController,
                  scrollController: scrollController)
              : TripOverviewWidget(tripController: tripController)
        ]);
      }),
    );
  }
}
