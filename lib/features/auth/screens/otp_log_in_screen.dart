import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/text_field_widget.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_up_screen.dart';
import 'package:ride_sharing_user_app/features/auth/screens/verification_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';

class OtpLoginScreen extends StatefulWidget {
  final bool fromSignIn;

  const OtpLoginScreen({super.key, this.fromSignIn = false});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  TextEditingController phoneController = TextEditingController();
  FocusNode phoneNode = FocusNode();

  @override
  void initState() {
    super.initState();

    Get.find<AuthController>().countryDialCode = CountryCode.fromCountryCode(
            Get.find<SplashController>().config!.countryCode!)
        .dialCode!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: GetBuilder<AuthController>(builder: (authController) {
        return SingleChildScrollView(
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
                height: Dimensions.paddingSizeSix,
              ),
              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSixteen),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Image.asset(Images.logoWithName, height: 75)),
                    SizedBox(
                      height: Dimensions.paddingSizeOverLarge +
                          Dimensions.paddingSizeSixteen,
                    ),
                    Text(
                      'otp_login'.tr,
                      style: textBold.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: Dimensions.paddingSizeOverLarge,
                      ),
                    ),
                    Text(
                      'verification_code'.tr,
                      style: textMedium.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    TextFieldWidget(
                      label: 'enter_your_phone_number'.tr,
                      hintText: 'phone'.tr,
                      inputType: TextInputType.phone,
                      countryDialCode: authController.countryDialCode,
                      prefixHeight: 70,
                      controller: phoneController,
                      focusNode: phoneNode,
                      inputAction: TextInputAction.done,
                      onCountryChanged: (CountryCode countryCode) {
                        authController.countryDialCode = countryCode.dialCode!;
                        authController.setCountryCode(countryCode.dialCode!);
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSize),
                    authController.isLoading
                        ? Center(
                            child: SpinKitCircle(
                                color: Theme.of(context).colorScheme.primary,
                                size: 40.0))
                        : ButtonWidget(
                            buttonText: 'send_otp'.tr,
                            onPressed: () {
                              String phone = phoneController.text.trim();

                              if (phone.isEmpty) {
                                showCustomSnackBar(
                                    'enter_your_phone_number'.tr);
                                FocusScope.of(context).requestFocus(phoneNode);
                              } else if (!GetUtils.isPhoneNumber(
                                  authController.countryDialCode + phone)) {
                                showCustomSnackBar(
                                    'phone_number_is_not_valid'.tr);
                              } else {
                                authController
                                    .sendOtp(
                                        countryCode:
                                            authController.countryDialCode,
                                        phone: phone)
                                    .then((value) {
                                  if (value.statusCode == 200) {
                                    Get.to(() => VerificationScreen(
                                          number: phone,
                                          from: 'login',
                                          countryCode:
                                              authController.countryDialCode,
                                        ));
                                  }
                                });
                              }
                            },
                            radius: 50,
                          ),
                    Row(children: [
                      Expanded(
                          child: Divider(
                              thickness: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: 8),
                        child: Text(
                          'or'.tr,
                          style: textBold.copyWith(
                              fontSize: Dimensions.paddingSizeSixteen,
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                              thickness: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer)),
                    ]),
                    ButtonWidget(
                      showBorder: true,
                      borderWidth: 1,
                      transparent: true,
                      buttonText: 'log_in'.tr,
                      onPressed: () => Get.back(),
                      radius: 50,
                    ),
                    const SizedBox(height: Dimensions.paddingSize),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        '${'do_not_have_an_account'.tr} ',
                        style: textMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).colorScheme.secondary,
                            letterSpacing: 0),
                      ),
                      const SizedBox(
                        width: Dimensions.paddingSizeSix,
                      ),
                      TextButton(
                        onPressed: () {
                          Get.off(() => const SignUpScreen());
                        },
                        style: TextButton.styleFrom(
                          overlayColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'sign_up'.tr,
                          style: textMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      )
                    ]),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
