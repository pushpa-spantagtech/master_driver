import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/loader_widget.dart';

String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

class ProfileStatusCardWidget extends StatelessWidget {
  final ProfileController profileController;

  const ProfileStatusCardWidget({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
          border: Border.all(
              width: .5, color: Theme.of(context).colorScheme.secondary),
        ),
        child: profileController.profileInfo != null &&
                profileController.profileInfo!.firstName != null
            ? Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSize),
                child: Row(children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: ImageWidget(
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            image:
                                '${Get.find<SplashController>().config!.imageBaseUrl!.profileImage}/${profileController.profileInfo!.profileImage}',
                          ),
                        )),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                          '${capitalize(profileController.profileInfo?.firstName ?? '')} '
                          '${capitalize(profileController.profileInfo?.lastName ?? '')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textBold.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .color,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall),
                        if (Get.find<SplashController>().config!.levelStatus!)
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withValues(alpha: .10),
                              borderRadius: BorderRadius.circular(
                                  Dimensions.paddingSizeExtraSmall),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                                horizontal: Dimensions.paddingSizeExtraSmall,
                              ),
                              child: Text(
                                profileController.profileInfo!.level != null
                                    ? profileController
                                        .profileInfo!.level!.name!
                                    : '',
                                style: textRegular.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .color),
                              ),
                            ),
                          ),
                      ])),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profileController.isOnline == "1"
                            ? "Online"
                            : "Offline",
                        style: textSemiBold.copyWith(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 52,
                        height: 42,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Switch(
                            value: profileController.isOnline == "1",
                            activeColor:
                                Theme.of(context).colorScheme.surfaceTint,
                            inactiveThumbColor:
                                Theme.of(context).colorScheme.error,
                            activeTrackColor: Theme.of(context).primaryColor,
                            inactiveTrackColor: Theme.of(context).primaryColor,
                            thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                              (states) => const Icon(
                                Icons.circle,
                                size: 0,
                                color: Colors.transparent,
                              ),
                            ),
                            trackOutlineColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Theme.of(context)
                                      .colorScheme
                                      .surfaceTint;
                                }
                                return Theme.of(context).colorScheme.error;
                              },
                            ),
                            onChanged: (val) async {
                              if (GetPlatform.isIOS) {
                                Get.dialog(
                                  const LoaderWidget(),
                                  barrierDismissible: false,
                                );

                                await profileController
                                    .profileOnlineOffline(val)
                                    .then((value) {
                                  if (value.statusCode == 200) {
                                    Get.back();
                                  }
                                });
                              } else {
                                Get.find<LocationController>()
                                    .checkPermission(() async {
                                  Get.dialog(
                                    const LoaderWidget(),
                                    barrierDismissible: false,
                                  );

                                  await profileController
                                      .profileOnlineOffline(val)
                                      .then((value) {
                                    if (value.statusCode == 200) {
                                      Get.back();
                                    }
                                  });
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ]),
              )
            : const SizedBox(),
      ),
    );
  }
}
