import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/country_picker_widget.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

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
    this.borderRadius = 12,
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
  late FocusNode _internalFocusNode;
  bool _usingInternalFocusNode = false;
  VoidCallback? _focusListener;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();

    if (widget.focusNode == null) {
      _usingInternalFocusNode = true;
      _internalFocusNode = FocusNode();
    }

    _focusListener = () {
      if (mounted) {
        setState(() {
          _isFocused = _effectiveFocusNode.hasFocus;
        });
      }
    };

    _effectiveFocusNode.addListener(_focusListener!);
  }

  @override
  Widget build(BuildContext context) {
    final double radius = widget.borderRadius == 50 ? 12 : widget.borderRadius;

    final String floatingLabel =
    (widget.label != null && widget.label!.trim().isNotEmpty)
        ? widget.label!
        : (widget.hintText ?? '');

    final bool isPhoneField =
        widget.inputType == TextInputType.phone ||
            (widget.hintText ?? '').toLowerCase().contains('mobile') ||
            (widget.hintText ?? '').toLowerCase().contains('phone') ||
            (widget.label ?? '').toLowerCase().contains('mobile') ||
            (widget.label ?? '').toLowerCase().contains('phone');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          maxLines: widget.maxLines,
          controller: widget.controller,
          focusNode: _effectiveFocusNode,
          style: textRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          textInputAction: widget.inputAction,
          keyboardType: (widget.isAmount || isPhoneField)
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
              : isPhoneField
              ? [AutofillHints.telephoneNumber]
              : widget.inputType == TextInputType.streetAddress
              ? [AutofillHints.fullStreetAddress]
              : widget.inputType == TextInputType.url
              ? [AutofillHints.url]
              : widget.inputType == TextInputType.visiblePassword
              ? [AutofillHints.password]
              : null,
          obscureText: widget.isPassword ? _obscureText : false,
          inputFormatters: isPhoneField
              ? <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ]
              : widget.isAmount
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
              : null,
          decoration: InputDecoration(
            labelText: floatingLabel,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            floatingLabelAlignment: FloatingLabelAlignment.start,
            isDense: true,
            filled: true,
            fillColor: Colors.white,

            labelStyle: textMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Colors.grey.shade500,
            ),
            floatingLabelStyle: textMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: _isFocused
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade600,
              backgroundColor: Colors.white,
            ),

            contentPadding: const EdgeInsets.only(
              left: 18,
              right: 16,
              top: 22,
              bottom: 16,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.4,
              ),
            ),

            prefixIconConstraints: const BoxConstraints(
              minWidth: 52,
              minHeight: 54,
            ),

            prefixIcon: isPhoneField
                ? Icon(
              Icons.phone_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            )
                : widget.prefixIcon != null
                ? Padding(
              padding: const EdgeInsets.only(left: 14, right: 12),
              child: Image.asset(
                widget.prefixIcon!,
                height: 20,
                width: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
                : null,

            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: _obscureText
                    ? Colors.grey.shade400
                    : Theme.of(context).colorScheme.primary,
              ),
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
        const SizedBox(height: 14),
      ],
    );
  }
  Widget _countryCodePrefix(BuildContext context, double radius) {
    final bool isLtr = Get.find<LocalizationController>().isLtr;

    return SizedBox(
      width: 140,
      child: Row(
        children: [
          const SizedBox(width: 8),

          Icon(
            Icons.phone_outlined,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(width: 8),

          Container(
            width: 60,
            height: 54,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.only(
                topRight:
                isLtr ? const Radius.circular(0) : Radius.circular(radius),
                bottomRight:
                isLtr ? const Radius.circular(0) : Radius.circular(radius),
                topLeft:
                isLtr ? Radius.circular(radius) : const Radius.circular(0),
                bottomLeft:
                isLtr ? Radius.circular(radius) : const Radius.circular(0),
              ),
            ),
            child: Center(
              child: CodePickerWidget(
                searchStyle: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
                flagWidth: 25,
                padding: EdgeInsets.zero,
                onChanged: widget.onCountryChanged,
                initialSelection: widget.countryDialCode,
                favorite: [
                  if (widget.countryDialCode != null)
                    widget.countryDialCode!,
                ],
                showDropDownButton: true,
                showCountryOnly: true,
                showOnlyCountryWhenClosed: true,
                showFlagDialog: true,
                hideMainText: true,
                showFlagMain: true,
                dialogBackgroundColor: Theme.of(context).cardColor,
              ),
            ),
          ),

          if (widget.showCountryCode)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                widget.countryDialCode ?? '',
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
            ),
        ],
      ),
    );
  }
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_focusListener!);

    if (_usingInternalFocusNode) {
      _internalFocusNode.dispose();
    }

    super.dispose();
  }
}
