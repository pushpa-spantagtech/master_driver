import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class WalletAmountTypeCardWidget extends StatelessWidget {
  final String icon;
  final double amount;
  final String title;
  final bool haveBorderColor;

  const WalletAmountTypeCardWidget(
      {super.key,
      required this.icon,
      required this.amount,
      required this.title,
      this.haveBorderColor = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
        0,
        Dimensions.paddingSizeSmall,
      ),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          border: Border.all(
            color: haveBorderColor
                ? Theme.of(context).hintColor.withValues(alpha: 0.45)
                : Theme.of(context).hintColor.withValues(alpha: 0.25),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 40, child: Image.asset(icon)),
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeSmall),
            child: Text(
              PriceConverter.convertPrice(context, amount),
              style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          Text(title,
              style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: haveBorderColor
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).textTheme.bodyMedium!.color)),
        ]),
      ),
    );
  }
}
