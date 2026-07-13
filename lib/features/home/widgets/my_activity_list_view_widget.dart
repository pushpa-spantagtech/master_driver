import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/home/widgets/activity_card_widget.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';

class MyActivityListViewWidget extends StatelessWidget {
  const MyActivityListViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'My Activity',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 19,
                height: 1.2,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 13),
          GetBuilder<ProfileController>(
            builder: (profileController) {
              int activeSec = 0;
              int offlineSec = 0;
              int drivingSec = 0;
              int idleSec = 0;

              final timeTrack = profileController.profileInfo?.timeTrack;
              if (timeTrack != null) {
                activeSec = timeTrack.totalOnline?.floor() ?? 0;
                drivingSec = timeTrack.totalDriving?.floor() ?? 0;
                idleSec = timeTrack.totalIdle?.floor() ?? 0;
                offlineSec = timeTrack.totalOffline?.floor() ?? 0;
              }

              if (profileController.profileInfo == null) {
                return const SizedBox.shrink();
              }

              return SizedBox(
                height: 116,
                child: ListView(
                  padding: const EdgeInsets.only(right: 20),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    MyActivityCardWidget(
                      title: 'active',
                      icon: Images.activeHourIcon,
                      index: 0,
                      value: activeSec,
                      color: const Color(0xFF12A150),
                    ),
                    MyActivityCardWidget(
                      title: 'on_driving',
                      icon: Images.onDrivingHourIcon,
                      index: 1,
                      value: drivingSec,
                      color: const Color(0xFFFFB100),
                    ),
                    MyActivityCardWidget(
                      title: 'idle_time',
                      icon: Images.idleHourIcon,
                      index: 2,
                      value: idleSec,
                      color: const Color(0xFF4F75E8),
                    ),
                    MyActivityCardWidget(
                      title: 'offline',
                      icon: Images.offlineHourIcon,
                      index: 3,
                      value: offlineSec,
                      color: const Color(0xFF8A94A6),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
