import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/email_checker.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/domain/models/signup_body.dart';
import 'package:ride_sharing_user_app/features/auth/widgets/text_field_title_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/text_field_widget.dart';

class AdditionalSignUpScreen extends StatelessWidget {
  final String countryCode;
  final List<String> services;

  const AdditionalSignUpScreen(
      {super.key, required this.countryCode, required this.services});

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
                height: Dimensions.paddingSizeSmall,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: Dimensions.paddingSizeLarge,
                    right: Dimensions.paddingSizeLarge,
                    bottom: Dimensions.paddingSizeLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Image.asset(Images.logoWithName, height: 75)),
                    const SizedBox(
                      height: Dimensions.paddingSize,
                    ),
                    Text('required_information'.tr,
                        style: textSemiBold.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: Dimensions.fontSizeExtraLarge,
                        )),
                    const SizedBox(
                      height: Dimensions.paddingSizeSix,
                    ),
                    Text(
                      'additional_sign_up_message'.tr,
                      style: textMedium.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(
                      height: Dimensions.paddingSizeSix,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeSmall,
                        bottom: Dimensions.paddingSizeDefault,
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () => authController.pickImage(false, true),
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                clipBehavior: Clip.none,
                                children: [
                                  authController.pickedProfileFile == null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          child: const ImageWidget(
                                            image: '',
                                            height: 76,
                                            width: 76,
                                            placeholder:
                                                Images.personPlaceholder,
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 38,
                                          backgroundImage: FileImage(
                                            File(authController
                                                .pickedProfileFile!.path),
                                          ),
                                        ),
                                  Positioned(
                                    right: 5,
                                    bottom: -3,
                                    child: InkWell(
                                      overlayColor: WidgetStateProperty.all(
                                          Colors.transparent),
                                      onTap: () =>
                                          authController.pickImage(false, true),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.camera_enhance_rounded,
                                          color: Theme.of(context).primaryColor,
                                          size: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFieldWidget(
                      label: 'email'.tr,
                      hintText: 'email'.tr,
                      inputType: TextInputType.emailAddress,
                      prefixIcon: Images.email,
                      controller: authController.emailController,
                      focusNode: authController.emailNode,
                      nextFocus: authController.addressNode,
                      inputAction: TextInputAction.next,
                    ),
                    TextFieldWidget(
                      label: 'address'.tr,
                      hintText: 'address'.tr,
                      capitalization: TextCapitalization.words,
                      inputType: TextInputType.text,
                      prefixIcon: Images.location,
                      controller: authController.addressController,
                      focusNode: authController.addressNode,
                      nextFocus: authController.identityNumberNode,
                      inputAction: TextInputAction.next,
                    ),
//                     TextFieldTitleWidget(
//                       title: 'identity_type'.tr,
//                     ),
                    DropdownButtonFormField<String>(
                      value: authController.identityType.isEmpty
                          ? null
                          : authController.identityType,
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 14, right: 12),
                          child: Icon(
                            Icons.badge_outlined,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 52,
                          minHeight: 54,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(
                          left: 18,
                          right: 16,
                          top: 22,
                          bottom: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.4,
                          ),
                        ),
                      ),
                      hint: Text(
                        'select_identity_type'.tr,
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      items:
                          authController.identityTypeList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value.tr,
                            style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        authController.setIdentityType(val!);
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    TextFieldWidget(
                      label: 'identification_number'.tr,
                      hintText: 'Ex: 12345',
                      inputType: TextInputType.text,
                      prefixIcon: Images.identity,
                      controller: authController.identityNumberController,
                      focusNode: authController.identityNumberNode,
                      inputAction: TextInputAction.done,
                    ),
                    TextFieldTitleWidget(title: 'identity_image'.tr),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Dimensions.paddingSizeDefault,
                        0,
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeDefault,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          authController.identityImages.length >= 2
                              ? 2
                              : authController.identityImages.length + 1,
                          (index) {
                            return index == authController.identityImages.length
                                ? GestureDetector(
                                    onTap: () =>
                                        authController.pickImage(false, false),
                                    child: DottedBorder(
                                      strokeWidth: 2,
                                      dashPattern: const [10, 5],
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(
                                        Dimensions.paddingSizeSmall,
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              Dimensions.paddingSizeSmall,
                                            ),
                                            child: SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4.3,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Image.asset(
                                                Images.cameraPlaceholder,
                                                scale: 3,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            top: 0,
                                            left: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .hintColor
                                                    .withValues(alpha: 0.07),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Dimensions.paddingSizeSmall,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: Dimensions.paddingSizeSmall,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(
                                                Dimensions
                                                    .paddingSizeExtraSmall,
                                              ),
                                            ),
                                            child: Image.file(
                                              File(
                                                authController
                                                    .identityImages[index].path,
                                              ),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4.3,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: InkWell(
                                          overlayColor: WidgetStateProperty.all(
                                              Colors.transparent),
                                          onTap: () =>
                                              authController.removeImage(index),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .shadow,
                                                  blurRadius: 2,
                                                  offset: const Offset(0, 0),
                                                ),
                                              ],
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(
                                                  Dimensions.paddingSizeDefault,
                                                ),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Icon(
                                                Icons.delete_forever_rounded,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                                size: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                          },
                        ),
                      ),
                    ),
                    authController.isLoading
                        ? Center(
                            child: SpinKitCircle(
                                color: Theme.of(context).colorScheme.primary,
                                size: 40.0))
                        : ButtonWidget(
                            buttonText: 'send'.tr,
                            onPressed: () {
                              String email =
                                  authController.emailController.text;
                              String address =
                                  authController.addressController.text;
                              String identityNumber =
                                  authController.identityNumberController.text;
                              if (authController.pickedProfileFile == null) {
                                showCustomSnackBar(
                                    'profile_image_is_required'.tr);
                              } else if (email.isEmpty) {
                                showCustomSnackBar('email_is_required'.tr);
                                FocusScope.of(context)
                                    .requestFocus(authController.emailNode);
                              } else if (EmailChecker.isNotValid(email)) {
                                showCustomSnackBar(
                                    'enter_valid_email_address'.tr);
                                FocusScope.of(context)
                                    .requestFocus(authController.emailNode);
                              } else if (address.isEmpty) {
                                showCustomSnackBar('address_is_required'.tr);
                                FocusScope.of(context)
                                    .requestFocus(authController.addressNode);
                              } else if (identityNumber.isEmpty) {
                                showCustomSnackBar(
                                    'identity_number_is_required'.tr);
                                FocusScope.of(context).requestFocus(
                                    authController.identityNumberNode);
                              } else if (authController
                                  .identityImages.isEmpty) {
                                showCustomSnackBar(
                                    'identity_image_is_required'.tr);
                              } else if (authController.identityType.isEmpty) {
                                showCustomSnackBar(
                                    'identity_type_is_required'.tr);
                              } else {
                                SignUpBody signUpBody = SignUpBody(
                                    userType: AppConstants.driverType,
                                    email: email,
                                    address: address,
                                    identityNumber: identityNumber,
                                    identificationType:
                                        authController.identityType,
                                    fName: authController.fNameController.text,
                                    lName: authController.lNameController.text,
                                    phone: countryCode +
                                        authController.phoneController.text,
                                    password:
                                        authController.passwordController.text,
                                    confirmPassword: authController
                                        .confirmPasswordController.text,
                                    deviceToken:
                                        authController.getDeviceToken(),
                                    services: services);
                                authController.register(
                                    countryCode, signUpBody);
                              }
                            },
                            radius: 50),
                    const SizedBox(
                      height: Dimensions.paddingSizeDefault,
                    ),
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
