import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ConfirmationDialogWidget extends StatelessWidget {
  final String icon;
  final String? title;
  final String description;
  final Function onYesPressed;
  final bool isLogOut;
  final Function? onNoPressed;
  final bool fromOpenLocation;
  final bool loading;
  final bool asBottomSheet;

  const ConfirmationDialogWidget({
    super.key,
    required this.icon,
    this.title,
    required this.description,
    required this.onYesPressed,
    this.isLogOut = false,
    this.onNoPressed,
    this.fromOpenLocation = false,
    this.loading = false,
    this.asBottomSheet = false,
  });
  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      width: 500,
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -70,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                        Dimensions.paddingSizeOverLarge,
                      ),
                      child: Image.asset(
                        icon,
                        color: Theme.of(context).colorScheme.primary,
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: Dimensions.paddingSizeOverLarge,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge,
                      ),
                      child: Text(
                        title!,
                        textAlign: TextAlign.center,
                        style: textMedium.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeLarge,
                    ),
                    child: Text(
                      description,
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: Dimensions.paddingSizeLarge,
                  ),
                  if (fromOpenLocation)
                    ButtonWidget(
                      buttonText: 'open_setting'.tr,
                      onPressed: () => onYesPressed(),
                      radius: Dimensions.radiusSmall,
                      height: 40,
                    )
                  else if (loading)
                    SpinKitCircle(
                      color: Theme.of(context).colorScheme.primary,
                      size: 40,
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => isLogOut
                                ? onYesPressed()
                                : onNoPressed != null
                                    ? onNoPressed!()
                                    : Get.back(),
                            style: TextButton.styleFrom(
                              overlayColor: Colors.transparent,
                              backgroundColor: Theme.of(context)
                                  .disabledColor
                                  .withValues(alpha: 0.3),
                              minimumSize: const Size(
                                Dimensions.webMaxWidth,
                                40,
                              ),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radiusSmall,
                                ),
                              ),
                            ),
                            child: Text(
                              isLogOut ? 'yes'.tr : 'no'.tr,
                              style: textBold.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: Dimensions.paddingSizeLarge,
                        ),
                        Expanded(
                          child: ButtonWidget(
                            buttonText: isLogOut ? 'no'.tr : 'yes'.tr,
                            onPressed: () =>
                                isLogOut ? Get.back() : onYesPressed(),
                            radius: Dimensions.radiusSmall,
                            height: 40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (asBottomSheet) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 70),
          child: content,
        ),
      );
    }

    return Dialog(
      surfaceTintColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.none,
      backgroundColor: Colors.transparent,
      child: content,
    );
  }
}
