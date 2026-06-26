import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/profile/domain/models/profile_model.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/domain/models/categoty_model.dart';
import 'package:ride_sharing_user_app/features/profile/domain/models/vehicle_brand_model.dart';
import 'package:ride_sharing_user_app/features/profile/domain/models/vehicle_body.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/date_picker_widget.dart';

class VehicleAddScreen extends StatefulWidget {
  final Vehicle? vehicleInfo;

  const VehicleAddScreen({super.key, this.vehicleInfo});

  @override
  State<VehicleAddScreen> createState() => _VehicleAddScreenState();
}

class _VehicleAddScreenState extends State<VehicleAddScreen> {
  TextEditingController licencePlateNumberController = TextEditingController();
  TextEditingController licenceExpiryDateController = TextEditingController();
  TextEditingController vinNumberController = TextEditingController();
  TextEditingController transmissionController = TextEditingController();
  TextEditingController parcelWeightCapacity = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  FocusNode licencePlateFocus = FocusNode();
  FocusNode licenceExpiryFocus = FocusNode();
  FocusNode vinNumberFocus = FocusNode();
  FocusNode transmissionFocus = FocusNode();
  FocusNode parcelWeightFocus = FocusNode();

  PlatformFile? fileNamed;
  File? file;
  int? fileSize;

  @override
  void initState() {
    Get.find<ProfileController>().getVehicleBrandList(1);
    Get.find<ProfileController>().clearVehicleData();

    if (widget.vehicleInfo != null) {
      licencePlateNumberController.text =
          widget.vehicleInfo!.licencePlateNumber!;
      Get.find<ProfileController>()
          .setStartDate(DateTime.parse(widget.vehicleInfo!.licenceExpireDate!));
      Get.find<ProfileController>()
          .setFuelType(widget.vehicleInfo!.fuelType!, false);
      parcelWeightCapacity.text =
          (widget.vehicleInfo?.parcelWeightCapacity ?? '').toString();
    }

    super.initState();
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 50,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  InputDecoration _materialDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      prefixIconConstraints: const BoxConstraints(
        minWidth: 52,
        minHeight: 54,
      ),
      prefixIcon: Icon(
        icon,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
      labelStyle: textMedium.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: Colors.grey.shade500,
      ),
      floatingLabelStyle: textMedium.copyWith(
        fontSize: Dimensions.fontSizeSmall,
        color: Colors.grey.shade600,
        backgroundColor: Colors.white,
      ),
      hintStyle: textRegular.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: Colors.grey.shade500,
      ),
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
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _fieldGap() => const SizedBox(height: 14);

  Widget _brandDropdown(BuildContext context, ProfileController controller) {
    Brand? selectedBrand;
    for (final item in controller.brandList) {
      if (item.id == controller.selectedBrand?.id &&
          controller.selectedBrand?.id != 'abc') {
        selectedBrand = item;
        break;
      }
    }

    return DropdownButtonFormField<Brand>(
      value: selectedBrand,
      isExpanded: true,
      style: textRegular.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      decoration: _materialDecoration(
        context,
        label: 'vehicle_brand'.tr,
        icon: Icons.directions_car_filled_outlined,
      ),
      hint: Text(
        'select_vehicle_brand'.tr,
        style: textRegular.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Colors.grey.shade500,
        ),
      ),
      items: controller.brandList.map((item) {
        return DropdownMenuItem<Brand>(
          value: item,
          child: Text(
            item.name!.tr,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
        );
      }).toList(),
      onChanged: (newVal) {
        if (newVal != null) {
          controller.setBrandIndex(newVal, true);
        }
      },
    );
  }

  Widget _modelDropdown(BuildContext context, ProfileController controller) {
    VehicleModels? selectedModel;
    for (final item in controller.modelList) {
      if (item.id == controller.selectedModel.id &&
          controller.selectedModel.id != 'abc') {
        selectedModel = item;
        break;
      }
    }

    return DropdownButtonFormField<VehicleModels>(
      value: selectedModel,
      isExpanded: true,
      style: textRegular.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      decoration: _materialDecoration(
        context,
        label: 'vehicle_model'.tr,
        icon: Icons.car_rental_outlined,
      ),
      hint: Text(
        'select_vehicle_model'.tr,
        style: textRegular.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Colors.grey.shade500,
        ),
      ),
      items: controller.modelList.map((item) {
        return DropdownMenuItem<VehicleModels>(
          value: item,
          child: Text(
            item.name!.tr,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
        );
      }).toList(),
      onChanged: (newVal) {
        if (newVal != null) {
          controller.setModelIndex(newVal, true);
        }
      },
    );
  }

  Widget _categoryDropdown(BuildContext context, ProfileController controller) {
    Category? selectedCategory;
    for (final item in controller.categoryList) {
      if (item.id == controller.selectedCategory.id &&
          controller.selectedCategory.id != 'abc') {
        selectedCategory = item;
        break;
      }
    }

    return DropdownButtonFormField<Category>(
      value: selectedCategory,
      isExpanded: true,
      style: textRegular.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      decoration: _materialDecoration(
        context,
        label: 'vehicle_category'.tr,
        icon: Icons.category_outlined,
      ),
      hint: Text(
        'select_vehicle_category'.tr,
        style: textRegular.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Colors.grey.shade500,
        ),
      ),
      items: controller.categoryList.map((item) {
        return DropdownMenuItem<Category>(
          value: item,
          child: Text(
            item.name!.tr,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
        );
      }).toList(),
      onChanged: (newVal) {
        if (newVal != null) {
          controller.setCategoryIndex(newVal, true);
        }
      },
    );
  }

  Widget _fuelDropdown(BuildContext context, ProfileController controller) {
    return DropdownButtonFormField<String>(
      value: controller.selectedFuelType,
      isExpanded: true,
      style: textRegular.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      decoration: _materialDecoration(
        context,
        label: 'fuel_type'.tr,
        icon: Icons.local_gas_station_outlined,
      ),
      items: controller.fuelType.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value.tr,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          controller.setFuelType(value, true);
        }
      },
    );
  }

  Widget _materialTextField(
    BuildContext context, {
    required String label,
    required String hintText,
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextInputType keyboardType,
    required IconData icon,
    FocusNode? nextFocus,
    TextInputAction inputAction = TextInputAction.next,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: textRegular.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      textInputAction: inputAction,
      keyboardType: keyboardType,
      cursorColor: Theme.of(context).colorScheme.primary,
      textCapitalization: TextCapitalization.words,
      autofocus: false,
      decoration: _materialDecoration(
        context,
        label: label,
        hintText: hintText,
        icon: icon,
      ),
      onSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title:
            widget.vehicleInfo == null ? 'add_vehicle'.tr : 'update_vehicle'.tr,
        regularAppbar: true,
      ),
      body: GetBuilder<ProfileController>(builder: (profileController) {
        return SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeDefault,
              Dimensions.paddingSizeDefault,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.vehicleInfo == null)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: Dimensions.paddingSizeDefault,
                      bottom: Dimensions.paddingSizeDefault,
                    ),
                    child: Text(
                      'vehicle_information'.tr,
                      style: textBold.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                  ),
                if (widget.vehicleInfo == null)
                  Text(
                    'add_vehicle_details'.tr,
                    style: textRegular.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                if (widget.vehicleInfo == null) _fieldGap(),
                if (profileController.brandList.isNotEmpty) ...[
                  _brandDropdown(context, profileController),
                  _fieldGap(),
                ],
                if (profileController.modelList.isNotEmpty) ...[
                  _modelDropdown(context, profileController),
                  _fieldGap(),
                ],
                if (profileController.categoryList.isNotEmpty) ...[
                  _categoryDropdown(context, profileController),
                  _fieldGap(),
                ],
                _materialTextField(
                  context,
                  label: 'parcel_weight_capacity'.tr,
                  hintText: 'enter_max_weight'.tr,
                  controller: parcelWeightCapacity,
                  focusNode: parcelWeightFocus,
                  nextFocus: licencePlateFocus,
                  keyboardType: TextInputType.number,
                  icon: Icons.scale_outlined,
                ),
                _fieldGap(),
                _materialTextField(
                  context,
                  label: 'licence_plate_number'.tr,
                  hintText: 'EX: DB-3212',
                  controller: licencePlateNumberController,
                  focusNode: licencePlateFocus,
                  nextFocus: licenceExpiryFocus,
                  keyboardType: TextInputType.text,
                  icon: Icons.confirmation_number_outlined,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                InkWell(
                  onTap: () => profileController.selectDate("start", context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: '${'licence_expire_date'.tr} *',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      labelStyle: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Colors.grey.shade500,
                      ),
                      floatingLabelStyle: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.grey.shade600,
                      ),
                      prefixIcon: Icon(
                        Icons.calendar_month,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.only(
                        left: 18,
                        right: 16,
                        top: 22,
                        bottom: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      profileController.startDate != null
                          ? profileController.dateFormat
                              .format(profileController.startDate!)
                              .toString()
                          : 'dd-mm-yyyy',
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _fieldGap(),
                _fuelDropdown(context, profileController),
                if (widget.vehicleInfo == null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      Dimensions.paddingSizeDefault,
                      0,
                      0,
                    ),
                    child: DottedBorder(
                      dashPattern: const [4, 5],
                      borderType: BorderType.RRect,
                      color: Theme.of(context).hintColor,
                      radius: const Radius.circular(10),
                      child: Container(
                        padding:
                            const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.paddingSizeExtraSmall,
                          ),
                        ),
                        child: InkWell(
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                          onTap: () async {
                            bool res =
                                await profileController.pickOtherFile(false);
                            if (res) {
                              _scrollDown();
                            }
                          },
                          child: Builder(builder: (context) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: Image.asset(Images.upload),
                                ),
                                Text('upload_documents'.tr),
                                profileController.selectedFileForImport != null
                                    ? Text(
                                        fileNamed != null
                                            ? fileNamed!.name
                                            : '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : Text(
                                        'upload_file'.tr,
                                        style: textRegular.copyWith(),
                                      ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                if (profileController.listOfDocuments.isNotEmpty)
                  ListView.builder(
                    itemCount: profileController.listOfDocuments.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onTap: () => profileController.removeFile(index),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0,
                            Dimensions.paddingSizeDefault,
                            0,
                            0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Dimensions.paddingSizeExtraLarge,
                              ),
                              color: Theme.of(context).cardColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .hintColor
                                      .withValues(alpha: .25),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                Dimensions.paddingSizeDefault,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: Dimensions.iconSizeMedium,
                                    child: Image.asset(Images.clip),
                                  ),
                                  const SizedBox(
                                    width: Dimensions.paddingSizeSmall,
                                  ),
                                  Expanded(
                                    child: Text(
                                      profileController.listOfDocuments[index]
                                          .files.first.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.clear,
                                    color: Colors.red,
                                    size: 20,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar:
          GetBuilder<ProfileController>(builder: (profileController) {
        return Container(
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).hintColor.withValues(alpha: .25),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(1, 1),
              )
            ],
          ),
          child: profileController.creating
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitCircle(
                      color: Theme.of(context).colorScheme.primary,
                      size: 40.0,
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: ButtonWidget(
                    buttonText:
                        widget.vehicleInfo == null ? 'submit'.tr : 'update'.tr,
                    onPressed: () {
                      String licencePlateNumber =
                          licencePlateNumberController.text.trim();
                      String fuelType = profileController.selectedFuelType;

                      if (profileController.selectedBrand == null ||
                          profileController.selectedBrand!.id == 'abc') {
                        showCustomSnackBar('select_vehicle_brand'.tr);
                      } else if (profileController.selectedModel.id == null ||
                          profileController.selectedModel.id == 'abc') {
                        showCustomSnackBar('select_vehicle_model'.tr);
                      } else if (profileController.selectedCategory.id ==
                              null ||
                          profileController.selectedCategory.id == 'abc') {
                        showCustomSnackBar('select_vehicle_category'.tr);
                      } else if (licencePlateNumber.isEmpty) {
                        showCustomSnackBar(
                            'licence_plate_number_is_required'.tr);
                      } else if (profileController.startDate == null) {
                        showCustomSnackBar('expire_date_is_required'.tr);
                      } else if (fuelType == 'Select Fuel type') {
                        showCustomSnackBar('fuel_type_is_required'.tr);
                      } else {
                        String brandId = profileController.selectedBrand!.id!;
                        String modelId = profileController.selectedModel.id!;
                        String categoryId =
                            profileController.selectedCategory.id!;
                        String expireDate = profileController.dateFormat
                            .format(profileController.startDate!)
                            .toString();
                        String vinNumber = vinNumberController.text.trim();
                        String transmission =
                            transmissionController.text.trim();

                        VehicleBody body = VehicleBody(
                          brandId: brandId,
                          modelId: modelId,
                          categoryId: categoryId,
                          licencePlateNumber: licencePlateNumber,
                          licenceExpireDate: expireDate,
                          vinNumber: vinNumber,
                          transmission: transmission,
                          fuelType: fuelType,
                          driverId:
                              profileController.profileInfo!.id ?? "123456789",
                          ownership: 'driver',
                          parcelCapacityWeight:
                              parcelWeightCapacity.text.trim(),
                        );

                        if (widget.vehicleInfo == null) {
                          profileController.addNewVehicle(body);
                        } else {
                          profileController
                              .updateVehicle(
                            body,
                            Get.find<ProfileController>().driverId,
                          )
                              .then((onValue) {
                            if (onValue.statusCode == 200) {
                              Get.back();
                            }
                          });
                        }
                      }
                    },
                  ),
                ),
        );
      }),
    );
  }
}
