import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class MyActivityCardWidget extends StatelessWidget {
  final int index;
  final String title;
  final String icon;
  final int value;
  final Color color;

  const MyActivityCardWidget(
      {super.key,
      required this.index,
      required this.title,
      required this.icon,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    int hour = 0, min = 0;
    if (value >= 60) {
      hour = (value / 60).floor();
    }
    min = ((value % 60)).floor();

    return Padding(
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).colorScheme.onSecondary, width: 0.5),
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Text(title.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textBold.copyWith(
                              color: color,
                              fontSize: Dimensions.fontSizeLarge))),
                  SizedBox(
                      width: Dimensions.iconSizeMedium,
                      child: Image.asset(
                        icon,
                        color: Theme.of(context).colorScheme.primary,
                      ))
                ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              '${hour > 0 ? '$hour hr ' : ''}'
              '${min > 0 ? '$min min' : '0 min'}',
              style: textSemiBold.copyWith(
                color: color,
                fontSize: Dimensions.fontSizeExtraLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
