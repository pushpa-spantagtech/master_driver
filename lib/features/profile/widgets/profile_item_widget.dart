import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';

class ProfileItemWidget extends StatelessWidget {
  final String title;
  final String value;
  final bool isStatus;
  final bool isLevel;
  final IconData? icon;

  const ProfileItemWidget(
      {super.key,
      required this.title,
      required this.value,
      this.icon,
      this.isStatus = false,
      this.isLevel = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              if (icon != null)
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.red.withOpacity(0.08),
                  child: Icon(
                    icon,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Text(
                  title.tr,
                  style: textRegular.copyWith(
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              if (isStatus)
                FlutterSwitch(
                  width: 40,
                  height: 22,
                  toggleSize: 18,
                  value: Get.find<ProfileController>()
                          .profileInfo!
                          .details!
                          .isOnline ==
                      "1",
                  borderRadius: 20,
                  padding: 2,
                  activeColor: Theme.of(context).primaryColor,
                  showOnOff: false,
                  toggleColor: Colors.white,
                  onToggle: (val) {},
                )
              else
                Expanded(
                  flex: 2,
                  child: Text(
                    isLevel
                        ? Get.find<ProfileController>()
                                .profileInfo
                                ?.level
                                ?.name ??
                            "-"
                        : value,
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textMedium.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
