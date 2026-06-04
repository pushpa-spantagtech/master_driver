import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/html/screens/policy_viewer_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/screens/additional_sign_up_screen.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/text_field_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isRideShare = true;
  bool isParcelDelivery = true;

  @override
  void initState() {
    Get.find<AuthController>();
    Get.find<AuthController>().countryDialCode = CountryCode.fromCountryCode(
            Get.find<SplashController>().config!.countryCode!)
        .dialCode!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        final authController = Get.find<AuthController>();
        if (authController.acceptTerms) {
          authController.toggleTerms();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: GetBuilder<AuthController>(builder: (authController) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    Images.waveClipperTwo,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const SizedBox(
                  height: Dimensions.paddingSizeSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: Dimensions.paddingSizeSixteen,
                      left: Dimensions.paddingSizeSixteen,
                      bottom: Dimensions.paddingSizeSixteen),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child:
                                Image.asset(Images.logoWithName, height: 75)),
                        const SizedBox(height: Dimensions.paddingSizeTiny),
                        Text(
                          'sign_up_as_driver'.tr,
                          style: textBold.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: Dimensions.paddingSizeOverLarge,
                          ),
                        ),
                        Text(
                          'sign_up_message'.tr,
                          style: textMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSix),
                        // Text(
                        //   'service'.tr,
                        //   style: textMedium.copyWith(
                        //     fontSize: Dimensions.paddingSizeSixteen,
                        //     color: Theme.of(context).colorScheme.secondary,
                        //   ),
                        // ),
                        // const SizedBox(height: Dimensions.paddingSizeTiny),
                        // IntrinsicHeight(
                        //   child: Row(children: [
                        //     Container(
                        //       width: Get.width * 0.44,
                        //       decoration: BoxDecoration(
                        //         borderRadius:
                        //             BorderRadius.circular(Dimensions.radiusSmall),
                        //         border: Border.all(
                        //           color: isRideShare
                        //               ? Theme.of(context)
                        //                   .primaryColor
                        //                   .withValues(alpha: 0.5)
                        //               : Theme.of(context)
                        //                   .hintColor
                        //                   .withValues(alpha: 0.5),
                        //         ),
                        //         color: isRideShare
                        //             ? Theme.of(context)
                        //                 .primaryColor
                        //                 .withValues(alpha: 0.05)
                        //             : null,
                        //       ),
                        //       child: Center(
                        //         child: CheckboxListTile(
                        //           contentPadding: const EdgeInsets.only(left: 3),
                        //           title: Text('ride_share'.tr,
                        //               style: textBold.copyWith(fontSize: 11)),
                        //           value: isRideShare,
                        //           onChanged: (value) {
                        //             isRideShare = value!;
                        //             setState(() {});
                        //           },
                        //           activeColor: Theme.of(context).primaryColor,
                        //           checkColor: Theme.of(context).cardColor,
                        //           subtitle: Text('service_provide_text1'.tr,
                        //               style: textRegular.copyWith(
                        //                 color: Theme.of(context).hintColor,
                        //                 fontSize: 10,
                        //               )),
                        //         ),
                        //       ),
                        //     ),
                        //     const SizedBox(width: Dimensions.paddingSizeSmall),
                        //     Container(
                        //       width: Get.width * 0.44,
                        //       decoration: BoxDecoration(
                        //         borderRadius:
                        //             BorderRadius.circular(Dimensions.radiusSmall),
                        //         border: Border.all(
                        //           color: isParcelDelivery
                        //               ? Theme.of(context)
                        //                   .primaryColor
                        //                   .withValues(alpha: 0.5)
                        //               : Theme.of(context)
                        //                   .hintColor
                        //                   .withValues(alpha: 0.5),
                        //         ),
                        //         color: isParcelDelivery
                        //             ? Theme.of(context)
                        //                 .primaryColor
                        //                 .withValues(alpha: 0.05)
                        //             : null,
                        //       ),
                        //       child: Center(
                        //         child: CheckboxListTile(
                        //           contentPadding: const EdgeInsets.only(left: 3),
                        //           title: Text('parcel_delivery'.tr,
                        //               style: textBold.copyWith(fontSize: 11)),
                        //           value: isParcelDelivery,
                        //           onChanged: (value) {
                        //             isParcelDelivery = value!;
                        //             setState(() {});
                        //           },
                        //           activeColor: Theme.of(context).primaryColor,
                        //           checkColor: Theme.of(context).cardColor,
                        //           subtitle: Text('service_provide_text2'.tr,
                        //               style: textRegular.copyWith(
                        //                   color: Theme.of(context).hintColor,
                        //                   fontSize: 10)),
                        //         ),
                        //       ),
                        //     ),
                        //   ]),
                        // ),
                        TextFieldWidget(
                          hintText: 'first_name'.tr,
                          label: 'first_name'.tr,
                          capitalization: TextCapitalization.words,
                          inputType: TextInputType.name,
                          prefixIcon: Images.profileIcon,
                          controller: authController.fNameController,
                          focusNode: authController.fNameNode,
                          nextFocus: authController.lNameNode,
                          inputAction: TextInputAction.next,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        TextFieldWidget(
                          label: 'last_name'.tr,
                          hintText: 'last_name'.tr,
                          capitalization: TextCapitalization.words,
                          inputType: TextInputType.name,
                          prefixIcon: Images.profileIcon,
                          controller: authController.lNameController,
                          focusNode: authController.lNameNode,
                          nextFocus: authController.phoneNode,
                          inputAction: TextInputAction.next,
                        ),
                        TextFieldWidget(
                          label: 'phone'.tr,
                          hintText: 'phone'.tr,
                          inputType: TextInputType.number,
                          countryDialCode: authController.countryDialCode,
                          controller: authController.phoneController,
                          focusNode: authController.phoneNode,
                          nextFocus: authController.passwordNode,
                          inputAction: TextInputAction.next,
                          onCountryChanged: (CountryCode countryCode) {
                            authController.countryDialCode =
                                countryCode.dialCode!;
                            authController
                                .setCountryCode(countryCode.dialCode!);
                          },
                        ),
                        TextFieldWidget(
                          label: 'password'.tr,
                          hintText: 'password_hint'.tr,
                          inputType: TextInputType.text,
                          prefixIcon: Images.lock,
                          isPassword: true,
                          controller: authController.passwordController,
                          focusNode: authController.passwordNode,
                          nextFocus: authController.confirmPasswordNode,
                          inputAction: TextInputAction.next,
                        ),
                        TextFieldWidget(
                          label: 'confirm_password'.tr,
                          hintText: 'enter_confirm_password'.tr,
                          inputType: TextInputType.text,
                          prefixIcon: Images.lock,
                          controller: authController.confirmPasswordController,
                          focusNode: authController.confirmPasswordNode,
                          inputAction: TextInputAction.done,
                          isPassword: true,
                        ),
                        // const SizedBox(height: Dimensions.paddingSizeSmall),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeEight,
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          child: GetBuilder<AuthController>(
                            builder: (authController) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Transform.scale(
                                      scale: 1,
                                      child: Checkbox(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        checkColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        side: BorderSide(
                                          color: authController.acceptTerms
                                              ? const Color.fromRGBO(250, 173,
                                                  2, 1)
                                              : Theme.of(context)
                                                  .hintColor,
                                        ),
                                        activeColor: const Color.fromRGBO(
                                            250, 173, 2, 1),
                                        value: authController.acceptTerms,
                                        onChanged: (value) {
                                          authController.toggleTerms();
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeSmall),
                                  Expanded(
                                    child: Wrap(
                                      children: [
                                        Text(
                                          '${'i_agree'.tr} ',
                                          style: textMedium.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color: const Color.fromRGBO(
                                                20, 20, 20, 0.7),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await Get.to(() =>
                                                const PolicyViewerScreen());
                                            if (!authController.acceptTerms) {
                                              authController.toggleTerms();
                                            }
                                          },
                                          child: Text(
                                            'terms_and_conditions'.tr,
                                            style: textMedium.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                              color: const Color.fromRGBO(
                                                  250, 173, 2, 1),
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        ButtonWidget(
                          buttonText: 'next'.tr,
                          onPressed: () {
                            String fName = authController.fNameController.text;
                            String lName = authController.lNameController.text;
                            String phone =
                                authController.phoneController.text.trim();
                            String password =
                                authController.passwordController.text;
                            String confirmPassword =
                                authController.confirmPasswordController.text;
                            if (fName.isEmpty) {
                              showCustomSnackBar('first_name_is_required'.tr);
                              FocusScope.of(context)
                                  .requestFocus(authController.fNameNode);
                            } else if (lName.isEmpty) {
                              showCustomSnackBar('last_name_is_required'.tr);
                              FocusScope.of(context)
                                  .requestFocus(authController.lNameNode);
                            } else if (phone.isEmpty) {
                              showCustomSnackBar('phone_is_required'.tr);
                              FocusScope.of(context)
                                  .requestFocus(authController.phoneNode);
                            } else if (!GetUtils.isPhoneNumber(
                                authController.countryDialCode + phone)) {
                              showCustomSnackBar(
                                  'phone_number_is_not_valid'.tr);
                              FocusScope.of(context)
                                  .requestFocus(authController.phoneNode);
                            } else if (password.isEmpty) {
                              showCustomSnackBar('password_is_required'.tr);
                              FocusScope.of(context)
                                  .requestFocus(authController.passwordNode);
                            } else if (password.length < 8) {
                              showCustomSnackBar(
                                  'minimum_password_length_is_8'.tr);
                              FocusScope.of(context)
                                  .requestFocus(authController.passwordNode);
                            } else if (confirmPassword.isEmpty) {
                              showCustomSnackBar(
                                  'confirm_password_is_required'.tr);
                              FocusScope.of(context).requestFocus(
                                  authController.confirmPasswordNode);
                            } else if (password != confirmPassword) {
                              showCustomSnackBar('password_is_mismatch'.tr);
                              FocusScope.of(context).requestFocus(
                                  authController.confirmPasswordNode);
                            } else if (!authController.acceptTerms) {
                              showCustomSnackBar(
                                'Please accept Terms and Conditions',
                              );
                              return;
                            } else if (!isRideShare && !isParcelDelivery) {
                              showCustomSnackBar(
                                  'required_to_select_service'.tr);
                            } else {
                              List<String> services = [];
                              if (isRideShare) {
                                services.add('ride_request');
                              }
                              if (isParcelDelivery) {
                                services.add('parcel');
                              }
                              Get.to(() => AdditionalSignUpScreen(
                                    countryCode: authController.countryDialCode,
                                    services: services,
                                  ));
                            }
                          },
                          radius: 50,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${'already_have_an_account'.tr} ',
                                style: textMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    letterSpacing: 0),
                              ),
                              TextButton(
                                onPressed: () => Get.back(),
                                style: TextButton.styleFrom(
                                    overlayColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(50, 30),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap),
                                child: Text(
                                  'login'.tr,
                                  style: textMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ]),
                      ]),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
