import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/common_widgets/country_picker_widget.dart';

class TextFieldWidget extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final bool isPassword;
  final bool isAmount;
  final Function(String text)? onChanged;
  final bool isEnabled;
  final int maxLines;
  final TextCapitalization capitalization;
  final double borderRadius;
  final String? prefixIcon;
  final bool showBorder;
  final String? countryDialCode;
  final String? label;
  final double prefixHeight;
  final bool showCountryCode;
  final Function(CountryCode countryCode)? onCountryChanged;

  const TextFieldWidget({
    super.key,
    this.hintText = 'Write something...',
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.isEnabled = true,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.onChanged,
    this.prefixIcon,
    this.capitalization = TextCapitalization.none,
    this.isPassword = false,
    this.isAmount = false,
    this.borderRadius = 50,
    this.showBorder = false,
    this.prefixHeight = 50,
    this.countryDialCode,
    this.onCountryChanged,
    this.showCountryCode = true,
    this.label = '',
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool _obscureText = true;
  bool _isFocused = false;
  VoidCallback? _focusListener;

  @override
  void initState() {
    super.initState();

    if (widget.focusNode != null) {
      _focusListener = () {
        if (mounted) {
          setState(() {
            _isFocused = widget.focusNode!.hasFocus;
          });
        }
      };

      widget.focusNode!.addListener(_focusListener!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((widget.label ?? '').isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              widget.label ?? '',
              style: textMedium.copyWith(
                fontSize: Dimensions.paddingSizeSixteen,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          maxLines: widget.maxLines,
          controller: widget.controller,
          focusNode: widget.focusNode,
          style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyMedium?.color),
          textInputAction: widget.inputAction,
          keyboardType:
              (widget.isAmount || widget.inputType == TextInputType.phone)
                  ? const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: true,
                    )
                  : widget.inputType,
          cursorColor: Theme.of(context).colorScheme.primary,
          textCapitalization: widget.capitalization,
          enabled: widget.isEnabled,
          autofocus: false,
          autofillHints: widget.inputType == TextInputType.name
              ? [AutofillHints.name]
              : widget.inputType == TextInputType.emailAddress
                  ? [AutofillHints.email]
                  : widget.inputType == TextInputType.phone
                      ? [AutofillHints.telephoneNumber]
                      : widget.inputType == TextInputType.streetAddress
                          ? [AutofillHints.fullStreetAddress]
                          : widget.inputType == TextInputType.url
                              ? [AutofillHints.url]
                              : widget.inputType ==
                                      TextInputType.visiblePassword
                                  ? [AutofillHints.password]
                                  : null,
          obscureText: widget.isPassword ? _obscureText : false,
          inputFormatters: widget.inputType == TextInputType.phone
              ? <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ]
              : widget.isAmount
                  ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
                  : null,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.tertiary),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.surface),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(
                  width: widget.showBorder ? 0.5 : 0.5,
                  color: Theme.of(context).colorScheme.primary),
            ),
            hintText: widget.hintText,
            filled: true,
            fillColor: _isFocused
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.surface,
            hintStyle: textMedium.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).colorScheme.secondaryContainer),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 0, vertical: widget.isEnabled ? 12 : 0),
            prefixIcon: widget.prefixIcon != null
                ? Container(
                    width: widget.prefixHeight,
                    padding: const EdgeInsets.only(left: 8, right: 0),
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.only(
                        topRight: Get.find<LocalizationController>().isLtr
                            ? const Radius.circular(0)
                            : Radius.circular(widget.borderRadius),
                        bottomRight: Get.find<LocalizationController>().isLtr
                            ? const Radius.circular(0)
                            : Radius.circular(widget.borderRadius),
                        topLeft: Get.find<LocalizationController>().isLtr
                            ? Radius.circular(widget.borderRadius)
                            : const Radius.circular(0),
                        bottomLeft: Get.find<LocalizationController>().isLtr
                            ? Radius.circular(widget.borderRadius)
                            : const Radius.circular(0),
                      ),
                    ),
                    child: Center(
                        child: Image.asset(
                      widget.prefixIcon!,
                      height: 20,
                      width: 20,
                      color: Theme.of(context).colorScheme.primary,
                    )),
                  )
                : SizedBox(
                    width: widget.showCountryCode ? 125 : 80,
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.only(
                              topRight: Get.find<LocalizationController>().isLtr
                                  ? const Radius.circular(0)
                                  : Radius.circular(widget.borderRadius),
                              bottomRight:
                                  Get.find<LocalizationController>().isLtr
                                      ? const Radius.circular(0)
                                      : Radius.circular(widget.borderRadius),
                              topLeft: Get.find<LocalizationController>().isLtr
                                  ? Radius.circular(widget.borderRadius)
                                  : const Radius.circular(0),
                              bottomLeft:
                                  Get.find<LocalizationController>().isLtr
                                      ? Radius.circular(widget.borderRadius)
                                      : const Radius.circular(0),
                            ),
                          ),
                          margin: EdgeInsets.only(
                              right: Get.find<LocalizationController>().isLtr
                                  ? 10
                                  : 0,
                              left: Get.find<LocalizationController>().isLtr
                                  ? 0
                                  : 10),
                          padding: EdgeInsets.only(
                              left: Get.find<LocalizationController>().isLtr
                                  ? 15
                                  : 0,
                              right: Get.find<LocalizationController>().isLtr
                                  ? 0
                                  : 15),
                          child: Center(
                            child: CodePickerWidget(
                              searchStyle: textRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                              flagWidth: 25,
                              padding: EdgeInsets.zero,
                              onChanged: widget.onCountryChanged,
                              initialSelection: widget.countryDialCode,
                              favorite: [widget.countryDialCode!],
                              showDropDownButton: true,
                              showCountryOnly: true,
                              showOnlyCountryWhenClosed: true,
                              showFlagDialog: true,
                              hideMainText: true,
                              showFlagMain: true,
                              dialogBackgroundColor:
                                  Theme.of(context).cardColor,
                              barrierColor: Get.isDarkMode
                                  ? Colors.black.withValues(alpha: 0.4)
                                  : null,
                              textStyle: textRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                            ),
                          ),
                        ),
                        if (widget.showCountryCode)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Text(
                              widget.countryDialCode ?? '',
                              style: textRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault),
                            ),
                          ),
                      ],
                    ),
                  ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: _obscureText
                            ? Theme.of(context).colorScheme.onSecondaryContainer
                            : Theme.of(context).colorScheme.primary),
                    onPressed: _toggle,
                    style: IconButton.styleFrom(
                      overlayColor: Colors.transparent,
                    ),
                  )
                : null,
          ),
          onSubmitted: (text) => widget.nextFocus != null
              ? FocusScope.of(context).requestFocus(widget.nextFocus)
              : null,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    if (widget.focusNode != null && _focusListener != null) {
      widget.focusNode!.removeListener(_focusListener!);
    }

    super.dispose();
  }
}
