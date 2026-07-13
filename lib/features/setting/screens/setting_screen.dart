import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/features/setting/controllers/setting_controller.dart';
import 'package:ride_sharing_user_app/features/setting/widgets/theme_change_widget.dart';
import 'package:ride_sharing_user_app/localization/language_model.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBarWidget(
        title: 'setting'.tr,
        regularAppbar: true,
      ),
      body: GetBuilder<SettingController>(
        builder: (settingController) {
          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeLarge,
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeExtraLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SettingCard(
                    child: GetBuilder<LocalizationController>(
                      builder: (localizationController) {
                        return Row(
                          children: [
                            _IconBox(
                              child: Image.asset(
                                Images.languageIcon,
                                width: 24,
                                height: 24,
                              ),
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeDefault,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'language'.tr,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'choose_your_preferred_language'.tr,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: colorScheme.onSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeSmall,
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<Locale>(
                                value: localizationController.locale,
                                isDense: true,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault,
                                ),
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: colorScheme.onSecondary,
                                ),
                                selectedItemBuilder: (context) {
                                  return AppConstants.languages
                                      .map<Widget>((LanguageModel language) {
                                    return Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        language.languageName,
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onPrimary,
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },
                                items: AppConstants.languages
                                    .map((LanguageModel language) {
                                  final bool isSelected = localizationController
                                          .locale.languageCode ==
                                      language.languageCode;

                                  return DropdownMenuItem<Locale>(
                                    value: Locale(
                                      language.languageCode,
                                      language.countryCode,
                                    ),
                                    child: Text(
                                      language.languageName.tr,
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSecondary,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (Locale? newValue) {
                                  if (newValue != null) {
                                    Get.find<LocalizationController>()
                                        .setLanguage(newValue);
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  _SettingCard(
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _IconBox(
                              child: Image.asset(
                                Images.themeIcon,
                                width: 24,
                                height: 24,
                              ),
                            ),
                            const SizedBox(
                              width: Dimensions.paddingSizeDefault,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'theme'.tr,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'select_how_the_app_should_look'.tr,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: colorScheme.onSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeDefault,
                        ),
                        const ThemeChangeWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _SettingCard({
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeLarge,
          ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IconBox extends StatelessWidget {
  final Widget child;

  const _IconBox({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: child,
    );
  }
}
