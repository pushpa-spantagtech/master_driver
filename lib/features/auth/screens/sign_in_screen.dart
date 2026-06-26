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
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneNode = FocusNode();
  final FocusNode passwordNode = FocusNode();

  @override
  void initState() {
    super.initState();

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
        Get.find<SplashController>().config!.countryCode!,
      ).dialCode!;
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    phoneController.dispose();
    phoneNode.dispose();
    passwordNode.dispose();
    super.dispose();
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
        body: GetBuilder<AuthController>(
          builder: (authController) {
            return GetBuilder<ProfileController>(
              builder: (profileController) {
                return GetBuilder<RideController>(
                  builder: (rideController) {
                    return GetBuilder<LocationController>(
                      builder: (locationController) {
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                child: Image.asset(
                                  Images.waveClipperOne,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      Images.logoWithName,
                                      height: 90,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'get_started'.tr,
                                      textAlign: TextAlign.center,
                                      style: textBold.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        fontSize:
                                            Dimensions.paddingSizeOverLarge,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'log_in_message'.tr,
                                      textAlign: TextAlign.center,
                                      style: textMedium.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 18,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          TextFieldWidget(
                                            label: 'mobile_number'.tr,
                                            hintText: 'phone'.tr,
                                            inputType: TextInputType.number,
                                            countryDialCode:
                                                authController.countryDialCode,
                                            controller: phoneController,
                                            focusNode: phoneNode,
                                            borderRadius: 16,
                                            onCountryChanged:
                                                (CountryCode countryCode) {
                                              authController.countryDialCode =
                                                  countryCode.dialCode!;
                                              authController.setCountryCode(
                                                countryCode.dialCode!,
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 6),
                                          TextFieldWidget(
                                            label: 'password'.tr,
                                            hintText: 'password'.tr,
                                            inputType: TextInputType.text,
                                            prefixIcon: Images.lock,
                                            inputAction: TextInputAction.done,
                                            focusNode: passwordNode,
                                            prefixHeight: 55,
                                            isPassword: true,
                                            controller: passwordController,
                                            borderRadius: 16,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              InkWell(
                                                overlayColor:
                                                    WidgetStateProperty.all(
                                                  Colors.transparent,
                                                ),
                                                onTap: () => authController
                                                    .toggleRememberMe(),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: Transform.scale(
                                                        scale: 1,
                                                        child: Checkbox(
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                          checkColor:
                                                              Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        3),
                                                          ),
                                                          side: BorderSide(
                                                            color: authController
                                                                    .acceptTerms
                                                                ? const Color
                                                                    .fromRGBO(
                                                                    250,
                                                                    173,
                                                                    2,
                                                                    1)
                                                                : Theme.of(
                                                                        context)
                                                                    .hintColor,
                                                          ),
                                                          activeColor:
                                                              const Color
                                                                  .fromRGBO(250,
                                                                  173, 2, 1),
                                                          value: authController
                                                              .isActiveRememberMe,
                                                          onChanged: (bool?
                                                                  isChecked) =>
                                                              authController
                                                                  .toggleRememberMe(),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'remember'.tr,
                                                      style:
                                                          textMedium.copyWith(
                                                        fontSize: 12,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onTertiaryContainer,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  minimumSize:
                                                      const Size(80, 28),
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  overlayColor:
                                                      Colors.transparent,
                                                ),
                                                onPressed: () => Get.to(
                                                  () =>
                                                      const ForgotPasswordScreen(),
                                                ),
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
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          (authController.isLoading ||
                                                  authController.updateFcm ||
                                                  profileController.isLoading ||
                                                  rideController.isLoading ||
                                                  locationController
                                                      .lastLocationLoading)
                                              ? Center(
                                                  child: SpinKitCircle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    size: 40.0,
                                                  ),
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      16,
                                                    ),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x33FFB300),
                                                        blurRadius: 10,
                                                        offset: Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: ButtonWidget(
                                                    buttonText: 'log_in'.tr,
                                                    onPressed: () {
                                                      String phone =
                                                          phoneController.text;
                                                      String password =
                                                          passwordController
                                                              .text;

                                                      if (phone.isEmpty) {
                                                        showCustomSnackBar(
                                                          'phone_is_required'
                                                              .tr,
                                                        );
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                          phoneNode,
                                                        );
                                                      } else if (!GetUtils
                                                          .isPhoneNumber(
                                                        authController
                                                                .countryDialCode +
                                                            phone,
                                                      )) {
                                                        showCustomSnackBar(
                                                          'phone_number_is_not_valid'
                                                              .tr,
                                                        );
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                          phoneNode,
                                                        );
                                                      } else if (password
                                                          .isEmpty) {
                                                        showCustomSnackBar(
                                                          'password_is_required'
                                                              .tr,
                                                        );
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                          passwordNode,
                                                        );
                                                      } else if (password
                                                              .length <
                                                          8) {
                                                        showCustomSnackBar(
                                                          'minimum_password_length_is_8'
                                                              .tr,
                                                        );
                                                        FocusScope.of(context)
                                                            .requestFocus(
                                                          passwordNode,
                                                        );
                                                      } else {
                                                        authController.login(
                                                          authController
                                                              .countryDialCode,
                                                          phone,
                                                          password,
                                                        );
                                                      }
                                                    },
                                                    radius: 16,
                                                  ),
                                                ),
                                          if (Get.find<SplashController>()
                                              .config!
                                              .selfRegistration!)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8,
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Divider(
                                                      thickness: 1,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: Dimensions
                                                          .paddingSizeSmall,
                                                    ),
                                                    child: Text(
                                                      'or'.tr,
                                                      style: textBold.copyWith(
                                                        fontSize: 16,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .error,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Divider(
                                                      thickness: 1,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ButtonWidget(
                                            showBorder: true,
                                            borderWidth: 1.2,
                                            transparent: true,
                                            imageIcon: Images.tablerMessage,
                                            buttonText: 'otp_login'.tr,
                                            onPressed: () => Get.to(
                                              () => const OtpLoginScreen(
                                                fromSignIn: true,
                                              ),
                                            ),
                                            radius: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
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
                                              Flexible(
                                                child: Text(
                                                  '${'do_not_have_an_account'.tr} ',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: textMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeDefault,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    letterSpacing: 0,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () => Get.to(
                                                  () => const SignUpScreen(),
                                                ),
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  minimumSize:
                                                      const Size(50, 30),
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  overlayColor:
                                                      Colors.transparent,
                                                ),
                                                child: Text(
                                                  'sign_up'.tr,
                                                  style: textMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeDefault,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .error,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${'to_create_account'.tr} ",
                                              ),
                                              InkWell(
                                                overlayColor:
                                                    WidgetStateProperty.all(
                                                  Colors.transparent,
                                                ),
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
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
