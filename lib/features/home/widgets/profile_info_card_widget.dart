import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/loader_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/confirmation_dialog_widget.dart';
import 'package:ride_sharing_user_app/util/images.dart';

String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

class ProfileStatusCardWidget extends StatelessWidget {
  final ProfileController profileController;

  const ProfileStatusCardWidget({
    super.key,
    required this.profileController,
  });

  static const Color _ink = Color(0xFF111827);
  static const Color _muted = Color(0xFF667085);
  static const Color _online = Color(0xFF12A150);
  static const Color _offline = Color(0xFFE5484D);

  @override
  Widget build(BuildContext context) {
    final profile = profileController.profileInfo;

    if (profile == null || profile.firstName == null) {
      return const SizedBox.shrink();
    }

    final bool isOnline = profileController.isOnline == '1';
    final config = Get.find<SplashController>().config;
    final String imageBaseUrl = config?.imageBaseUrl?.profileImage ?? '';
    final String profileImage = profile.profileImage ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Material(
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: null,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFE7E9EE),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D101828),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isOnline ? _online : _offline,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: ImageWidget(
                      fit: BoxFit.cover,
                      width: 44,
                      height: 44,
                      image: '$imageBaseUrl/$profileImage',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${capitalize(profile.firstName ?? '')} '
                            '${capitalize(profile.lastName ?? '')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 16.5,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isOnline ? _online : _offline,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOnline ? 'Ready for rides' : 'You are offline',
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: isOnline ? _online : _offline,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Transform.scale(
                      scale: 0.88,
                      child: Switch(
                        value: isOnline,
                        activeColor: Colors.white,
                        activeTrackColor: _online,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: _offline.withValues(alpha: 0.82),
                        trackOutlineColor:
                        WidgetStateProperty.all(Colors.transparent),
                        onChanged: (val) async {
                          Future<void> changeOnlineStatus() async {
                            Get.dialog(
                              const LoaderWidget(),
                              barrierDismissible: false,
                            );

                            await profileController
                                .profileOnlineOffline(val)
                                .then((value) {
                              if (value.statusCode == 200 &&
                                  (Get.isDialogOpen ?? false)) {
                                Get.back();
                              }
                            });
                          }

                          // ONLINE -> OFFLINE: show the normal confirmation
                          // popup first. Location permission is not required
                          // for switching the driver offline.
                          if (!val) {
                            Get.dialog(
                              ConfirmationDialogWidget(
                                icon: Images.offlineMode,
                                description: 'are_you_sure'.tr,
                                onYesPressed: () async {
                                  Get.back();
                                  await changeOnlineStatus();
                                },
                              ),
                              barrierDismissible: false,
                            );
                            return;
                          }

                          // OFFLINE -> ONLINE: keep the existing permission
                          // flow. The pending online action continues after
                          // location permission is enabled.
                          if (GetPlatform.isIOS) {
                            await changeOnlineStatus();
                          } else {
                            Get.find<LocationController>()
                                .checkPermission(() async {
                              await changeOnlineStatus();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
