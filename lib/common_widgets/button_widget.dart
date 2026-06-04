import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ButtonWidget extends StatelessWidget {
  final Function()? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets margin;
  final double height;
  final double width;
  final double? fontSize;
  final double radius;
  final IconData? icon;
  final bool showBorder;
  final double borderWidth;
  final Color? borderColor;
  final bool isLoading;
  final Color? iconColor;
  final Color? textColor;
  final Color? backgroundColor;
  final String? imageIcon;

  const ButtonWidget({
    super.key,
    this.onPressed,
    required this.buttonText,
    this.transparent = false,
    this.margin = EdgeInsets.zero,
    this.width = Dimensions.webMaxWidth,
    this.height = 45,
    this.fontSize,
    this.radius = 5,
    this.icon,
    this.imageIcon,
    this.showBorder = false,
    this.borderWidth = 1,
    this.borderColor,
    this.textColor,
    this.iconColor,
    this.backgroundColor,
    this.isLoading = false,
  }) : assert(
          !(icon != null && imageIcon != null),
          'Provide either icon or imageIcon, not both',
        );

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: backgroundColor ??
          (onPressed == null
              ? Theme.of(context).disabledColor
              : transparent
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.primary),
      minimumSize: Size(width, height),
      padding: EdgeInsets.zero,
      overlayColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: showBorder
              ? BorderSide(
                  color: borderColor ??
                      Theme.of(context).colorScheme.onPrimaryContainer,
                  width: borderWidth)
              : const BorderSide(color: Colors.transparent)),
    );

    return Center(
        child: SizedBox(
            width: width,
            child: Padding(
              padding: margin,
              child: TextButton(
                onPressed: onPressed,
                style: flatButtonStyle,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  imageIcon != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeExtraSmall),
                          child: Image.asset(
                            imageIcon!,
                            height: 24,
                            width: 24,
                          ),
                        )
                      : icon != null
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  right: Dimensions.paddingSizeExtraSmall),
                              child: Icon(icon,
                                  color: transparent
                                      ? iconColor ??
                                          Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.primary),
                            )
                          : const SizedBox.shrink(),
                  const SizedBox(
                    width: Dimensions.paddingSizeSmall,
                  ),
                  Text(buttonText,
                      textAlign: TextAlign.center,
                      style: transparent
                          ? textMedium.copyWith(
                              color: textColor ??
                                  Theme.of(context).colorScheme.onSecondary,
                              fontSize: fontSize ?? Dimensions.fontSizeLarge,
                            )
                          : textBold.copyWith(
                              color:
                                  textColor ?? Theme.of(context).primaryColor,
                              fontSize: fontSize ?? Dimensions.fontSizeLarge,
                            )),
                ]),
              ),
            )));
  }
}
