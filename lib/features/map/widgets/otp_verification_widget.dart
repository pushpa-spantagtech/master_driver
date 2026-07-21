import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ride_sharing_user_app/features/map/controllers/otp_time_count_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'dart:math' as math;

class OtpVerificationWidget extends StatefulWidget {
  final bool fromOtp;

  const OtpVerificationWidget({super.key, this.fromOtp = true});

  @override
  State<OtpVerificationWidget> createState() => _OtpVerificationWidgetState();
}

class _OtpVerificationWidgetState extends State<OtpVerificationWidget> {
  TextEditingController? _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    Get.find<OtpTimeCountController>().startCountingState();
  }

  @override
  void dispose() {
    // Keep same behavior as your original code to avoid functionality changes.
    // Do not dispose here because PinCodeTextField may manage the controller during rebuilds.
    _otpController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RideController rideController = Get.find<RideController>();

    return GetBuilder<OtpTimeCountController>(builder: (otpTimeController) {
      return Column(children: [
        widget.fromOtp
            ? Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E8),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFFFE2A6),
                      width: 1,
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(
                      Icons.access_time_filled_rounded,
                      size: 16,
                      color: Color(0xFFFFB300),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${otpTimeController.min.toString().padLeft(2, '0')}:${otpTimeController.sec.toString().padLeft(2, '0')}',
                      style: textBold.copyWith(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ]),
                ),
              )
            : const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSignUp,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            otpTimeController.currentState == 0
                ? Text(
                    'enter_trip_otp'.tr,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  )
                : Text(
                    'did_customer_arrived'.tr,
                    style: textBold.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
            otpTimeController.currentState == 0
                ? Text(
                    'collect_the_otp_from_customer'.tr,
                    style: textRegular.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    'please_hold_on_a_little_more'.tr,
                    style: textBold.copyWith(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeExtraSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeDefault,
                        0,
                      ),
                      child: PinCodeTextField(
                        controller: _otpController,
                        length: 4,
                        appContext: context,
                        obscureText: false,
                        showCursor: true,
                        cursorHeight: 20,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          fieldHeight: 40,
                          fieldWidth: 35,
                          borderWidth: 1,
                          borderRadius: BorderRadius.circular(10),
                          selectedColor: Theme.of(context).colorScheme.primary,
                          activeColor: Theme.of(context).colorScheme.primary,
                          selectedFillColor: Get.isDarkMode
                              ? Colors.grey.withValues(alpha: 0.6)
                              : Theme.of(context).primaryColor,
                          inactiveFillColor: Theme.of(context).primaryColor,
                          inactiveColor: Theme.of(context).hintColor,
                          activeFillColor: Theme.of(context).primaryColor,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        onChanged: (value) {
                          rideController.updateVerificationCode(value);
                        },
                        beforeTextPaste: (text) {
                          return true;
                        },
                      ),
                    ),
                  ),
                  GetBuilder<RideController>(
                    builder: (buttonController) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        overlayColor: WidgetStateProperty.all(
                          const Color(0xFFFFB300).withValues(alpha: 0.12),
                        ),
                        onTap: buttonController.isPinVerificationLoading
                            ? null
                            : () async {
                                if ((_otpController?.text.length ?? 0) == 4) {
                                  buttonController.matchOtp(
                                    buttonController.tripDetail!.id!,
                                    _otpController!.text,
                                  );
                                } else {
                                  showCustomSnackBar('pin_code_is_required'.tr);
                                }
                              },
                        child: buttonController.isPinVerificationLoading
                            ? SizedBox(
                                width: 48,
                                height: 48,
                                child: Center(
                                  child: SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  Dimensions.paddingSizeExtraSmall,
                                  Dimensions.paddingSizeDefault,
                                  Dimensions.paddingSizeTiny,
                                ),
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform:
                                      Get.find<LocalizationController>().isLtr
                                          ? Matrix4.rotationY(0)
                                          : Matrix4.rotationY(math.pi),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFB300),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFB300)
                                              .withValues(alpha: 0.30),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ]),
        ),
      ]);
    });
  }
}
