import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/screens/otp_log_in_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_up_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/forgot_password_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/text_field_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  FocusNode phoneNode = FocusNode();
  FocusNode passwordNode = FocusNode();

  @override
  void initState() {
    if (Get.find<AuthController>().getUserNumber().isNotEmpty) {
      phoneController.text = Get.find<AuthController>().getUserNumber();
    }
    passwordController.text = Get.find<AuthController>().getUserPassword();
    if (passwordController.text != '') {
      Get.find<AuthController>().setRememberMe();
    }
    if (Get.find<AuthController>().getLoginCountryCode().isNotEmpty) {
      Get.find<AuthController>().countryDialCode =
          Get.find<AuthController>().getLoginCountryCode();
    } else if (Get.find<SplashController>().config!.countryCode != null) {
      Get.find<AuthController>().countryDialCode = CountryCode.fromCountryCode(
              Get.find<SplashController>().config!.countryCode!)
          .dialCode!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        Get.find<BottomMenuController>().exitApp();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: GetBuilder<AuthController>(builder: (authController) {
          return GetBuilder<ProfileController>(builder: (profileController) {
            return GetBuilder<RideController>(builder: (rideController) {
              return GetBuilder<LocationController>(
                  builder: (locationController) {
                return SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Image.asset(
                            Images.waveClipperOne,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeSixteen),
                          child: Column(
                            children: [
                              Image.asset(Images.logoWithName, height: 75),
                              const SizedBox(height: Dimensions.paddingSize),
                              Text(
                                'get_started'.tr,
                                style: textBold.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: Dimensions.paddingSizeOverLarge),
                              ),
                              Text(
                                'log_in_message'.tr,
                                style: textMedium.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSixteen),
                              TextFieldWidget(
                                label: 'mobile_number'.tr,
                                hintText: 'phone'.tr,
                                inputType: TextInputType.number,
                                countryDialCode: authController.countryDialCode,
                                controller: phoneController,
                                focusNode: phoneNode,
                                onCountryChanged: (CountryCode countryCode) {
                                  authController.countryDialCode =
                                      countryCode.dialCode!;
                                  authController
                                      .setCountryCode(countryCode.dialCode!);
                                },
                              ),
                              TextFieldWidget(
                                label: 'password'.tr,
                                hintText: 'password'.tr,
                                inputType: TextInputType.text,
                                prefixIcon: Images.lock,
                                inputAction: TextInputAction.done,
                                focusNode: passwordNode,
                                prefixHeight: 70,
                                isPassword: true,
                                controller: passwordController,
                              ),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeSmall),
                                  child: InkWell(
                                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                                    onTap: () =>
                                        authController.toggleRememberMe(),
                                    child: Row(children: [
                                      SizedBox(
                                          width: 10.0,
                                          height: 10.0,
                                          child: Transform.scale(
                                            scale: 0.8,
                                            child: Checkbox(
                                              checkColor: Theme.of(context)
                                                  .primaryColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              activeColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              value: authController
                                                  .isActiveRememberMe,
                                              onChanged: (bool? isChecked) =>
                                                  authController
                                                      .toggleRememberMe(),
                                            ),
                                          )),
                                      const SizedBox(
                                          width: Dimensions.paddingSizeSix),
                                      Text(
                                        'remember'.tr,
                                        style: textMedium.copyWith(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiaryContainer),
                                      ),
                                    ]),
                                  ),
                                ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      overlayColor: Colors.transparent,
                                    ),
                                    onPressed: () => Get.to(
                                        () => const ForgotPasswordScreen()),
                                    child: Text(
                                      'forgot_password'.tr,
                                      style: textMedium.copyWith(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                              (authController.isLoading ||
                                      authController.updateFcm ||
                                      profileController.isLoading ||
                                      rideController.isLoading ||
                                      locationController.lastLocationLoading)
                                  ? Center(
                                      child: SpinKitCircle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          size: 40.0))
                                  : ButtonWidget(
                                      buttonText: 'log_in'.tr,
                                      onPressed: () {
                                        String phone = phoneController.text;
                                        String password =
                                            passwordController.text;
                                        if (phone.isEmpty) {
                                          showCustomSnackBar(
                                              'phone_is_required'.tr);
                                          FocusScope.of(context)
                                              .requestFocus(phoneNode);
                                        } else if (!GetUtils.isPhoneNumber(
                                            authController.countryDialCode +
                                                phone)) {
                                          showCustomSnackBar(
                                              'phone_number_is_not_valid'.tr);
                                          FocusScope.of(context)
                                              .requestFocus(phoneNode);
                                        } else if (password.isEmpty) {
                                          showCustomSnackBar(
                                              'password_is_required'.tr);
                                          FocusScope.of(context)
                                              .requestFocus(passwordNode);
                                        } else if (password.length < 8) {
                                          showCustomSnackBar(
                                              'minimum_password_length_is_8'
                                                  .tr);
                                          FocusScope.of(context)
                                              .requestFocus(passwordNode);
                                        } else {
                                          authController.login(
                                              authController.countryDialCode,
                                              phone,
                                              password);
                                        }
                                      },
                                      radius: 50,
                                    ),
                              if (Get.find<SplashController>()
                                  .config!
                                  .selfRegistration!)
                                Row(children: [
                                  Expanded(
                                      child: Divider(
                                    thickness: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                  )),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'or'.tr,
                                      style: textBold.copyWith(
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error),
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
                                imageIcon: Images.tablerMessage,
                                buttonText: 'otp_login'.tr,
                                onPressed: () => Get.to(() =>
                                    const OtpLoginScreen(fromSignIn: true)),
                                radius: 50,
                              ),
                              const SizedBox(
                                  height: Dimensions.paddingSizeSmall),
                              (Get.find<SplashController>()
                                              .config!
                                              .selfRegistration !=
                                          null &&
                                      Get.find<SplashController>()
                                          .config!
                                          .selfRegistration!)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                          Text(
                                            '${'do_not_have_an_account'.tr} ',
                                            style: textMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                letterSpacing: 0),
                                          ),
                                          TextButton(
                                            onPressed: () => Get.to(
                                                () => const SignUpScreen()),
                                            style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(50, 30),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                overlayColor:
                                                    Colors.transparent),
                                            child: Text(
                                              'sign_up'.tr,
                                              style: textMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                              ),
                                            ),
                                          ),
                                        ])
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                          Text("${'to_create_account'.tr} "),
                                          InkWell(
                                            overlayColor: WidgetStateProperty.all(Colors.transparent),
                                            onTap: () =>
                                                Get.find<SplashController>()
                                                    .sendMailOrCall(
                                              "tel:${Get.find<SplashController>().config?.businessContactPhone}",
                                              false,
                                            ),
                                            child: Text(
                                              "${'contact_support'.tr} ",
                                              style: textRegular.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ]),
                            ],
                          ),
                        ),
                      ]),
                );
              });
            });
          });
        }),
      ),
    );
  }
}
