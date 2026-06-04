import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class VerificationScreen extends StatefulWidget {
  final String number;
  final String? from;
  final String countryCode;

  const VerificationScreen(
      {super.key, required this.number, this.from, required this.countryCode});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  TextEditingController pinController = TextEditingController();
  Timer? _timer;
  int? _seconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _seconds = Get.find<SplashController>().config!.otpResendTime!;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds! - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    int minutes = (_seconds! / 60).truncate();
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Image.asset(
                Images.waveClipperTwo,
                fit: BoxFit.fitWidth,
              ),
            ),
            const SizedBox(
              height: Dimensions.paddingSizeSignUp + Dimensions.paddingSizeTwo,
            ),
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge),
                child: GetBuilder<AuthController>(builder: (authController) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'otp_verification'.tr,
                        style: textBold.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: Dimensions.paddingSizeOverLarge,
                        ),
                      ),
                      Text('six_digit_code'.tr,
                          style: textMedium.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: Dimensions.paddingSizeDefault)),
                      (Get.find<SplashController>().config?.isDemo ?? true)
                          ? Padding(
                              padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeSmall)
                                  .copyWith(bottom: Dimensions.paddingSizeOver),
                              child: Text('for_demo_purpose_use'.tr,
                                  style: textSemiBold.copyWith(
                                      color: Theme.of(context).disabledColor)))
                          : const SizedBox(
                              height: Dimensions.paddingSizeExtraLarge),
                      SizedBox(
                          width: 300,
                          child: PinCodeTextField(
                              autoDisposeControllers: false,
                              length: 6,
                              appContext: context,
                              controller: pinController,
                              keyboardType: TextInputType.number,
                              animationType: AnimationType.slide,
                              cursorHeight: Dimensions.paddingSizeLarge,
                              cursorColor:
                                  Theme.of(context).colorScheme.primary,
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                fieldHeight: 40,
                                fieldWidth: 40,
                                borderWidth: 1,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                                selectedColor:
                                    const Color.fromRGBO(250, 173, 2, 1),
                                activeColor:
                                    const Color.fromRGBO(250, 173, 2, 1),
                                selectedFillColor: Get.isDarkMode
                                    ? Colors.grey.withValues(alpha: 0.6)
                                    : Colors.white,
                                inactiveFillColor: Colors.white,
                                inactiveColor: Colors.grey,
                                activeFillColor: Colors.white,
                              ),
                              animationDuration:
                                  const Duration(milliseconds: 300),
                              backgroundColor: Colors.transparent,
                              enableActiveFill: true,
                              onChanged: authController.updateVerificationCode,
                              beforeTextPaste: (text) => true,
                              textStyle: textSemiBold.copyWith(),
                              pastedTextStyle: textRegular.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color))),
                      if (_seconds! <= 0)
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('did_not_receive_the_code_?'.tr,
                                  style: textMedium.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: Dimensions.paddingSizeDefault)),
                              TextButton(
                                  style: TextButton.styleFrom(
                                    overlayColor: Colors.transparent,
                                  ),
                                  onPressed: () {
                                    authController
                                        .sendOtp(
                                      countryCode: widget.countryCode,
                                      phone: widget.number,
                                    )
                                        .then((value) {
                                      if (value.statusCode == 200) {
                                        _timer?.cancel();
                                        _startTimer();
                                      }
                                    });
                                  },
                                  child: Text('resend_it'.tr,
                                      style: textMedium.copyWith(
                                          fontSize: Dimensions.fontSizeLarge,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error),
                                      textAlign: TextAlign.end))
                            ]),
                      if (_seconds! > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                              '${'resend_it'.tr} ${'after'.tr} ${_seconds! > 0 ? '$minutesStr:${_seconds! % 60}' : ''} ${'sec'.tr}'),
                        ),
                      !authController.isLoading
                          ? authController.verificationCode.length == 6
                              ? ButtonWidget(
                                  buttonText: 'send'.tr,
                                  radius: 50,
                                  onPressed: () => authController
                                      .otpVerification(
                                          widget.countryCode,
                                          widget.number,
                                          authController.verificationCode,
                                          from: widget.from!)
                                      .then((value) {
                                    pinController.clear();
                                    authController.updateVerificationCode('');

                                    if (value.statusCode == 200) {
                                      _timer?.cancel();
                                      _seconds = 0;
                                    }

                                    if (mounted) {
                                      setState(() {});
                                    }
                                  }),
                                )
                              : const SizedBox.shrink()
                          : Center(
                              child: SpinKitCircle(
                              color: Theme.of(context).colorScheme.primary,
                              size: 40.0,
                            )),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(
                height: Dimensions.iconSizeOnline +
                    Dimensions.paddingSizeDefault +
                    Dimensions.paddingSizeTiny),
            Center(
                child: Image.asset(
              Images.sevenTaxi,
              height: 30,
              width: 190,
            )),
          ],
        ),
      ),
    );
  }
}
