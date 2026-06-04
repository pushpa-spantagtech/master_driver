import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TextFieldTitleWidget extends StatelessWidget {
  final String title;
  final TextStyle? style;

  const TextFieldTitleWidget({
    super.key,
    required this.title,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 8),
        child: Text(
          title,
          style: style ??
              textMedium.copyWith(
                fontSize: Dimensions.paddingSizeSixteen,
                color: Theme.of(context).colorScheme.secondary,
              ),
        ));
  }
}
