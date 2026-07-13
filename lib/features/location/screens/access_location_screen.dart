import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/loader_widget.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class AccessLocationScreen extends StatelessWidget {
  const AccessLocationScreen({super.key});

  static const Color _background = Color(0xFFF8F9FC);
  static const Color _brandGold = Color(0xFFF5A800);
  static const Color _ink = Color(0xFF111827);
  static const Color _muted = Color(0xFF667085);
  static const Color _softGold = Color(0xFFFFF3CC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          Get.find<BottomMenuController>().exitApp();
        },
        child: SafeArea(
          child: GetBuilder<LocationController>(
            builder: (locationController) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 44,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _LocationIllustration(),
                              const SizedBox(height: 22),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'find_customer_near_you'.tr,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: _ink,
                                        fontSize: 16,
                                        height: 1.2,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  'please_select_you_location_to_start_finding_available_customer_near_you'
                                      .tr,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: _muted,
                                        fontSize: 14.5,
                                        height: 1.5,
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 22),
                              const BottomButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LocationIllustration extends StatelessWidget {
  const _LocationIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AccessLocationScreen._brandGold.withValues(alpha: 0.28),
                width: 1.1,
              ),
            ),
          ),
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: AccessLocationScreen._brandGold.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AccessLocationScreen._softGold,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF111827).withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Image.asset(
              Images.mapLocationIconOne,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomButton extends StatelessWidget {
  const BottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: () async {
          Get.find<LocationController>().checkPermission(() async {
            Get.dialog(
              const LoaderWidget(),
              barrierDismissible: false,
            );

            final value =
                await Get.find<LocationController>().getCurrentLocation();

            if (Get.isDialogOpen ?? false) {
              Get.back();
            }

            if (value.latitude != 0 && value.longitude != 0) {
              if (Get.find<AuthController>().isLoggedIn()) {
                Get.offAll(() => const DashboardScreen());
              } else {
                Get.offAll(() => const SignInScreen());
              }
            }
          });
        },
        style: FilledButton.styleFrom(
          backgroundColor: AccessLocationScreen._brandGold,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AccessLocationScreen._brandGold.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white,
          elevation: 1,
          shadowColor: AccessLocationScreen._brandGold.withValues(alpha: 0.22),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.my_location_rounded,
              size: 20,
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                'use_current_location'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 9),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }
}
