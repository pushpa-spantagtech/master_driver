import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RouteCalculationWidget extends StatelessWidget {
  final bool fromEnd;

  const RouteCalculationWidget({super.key, this.fromEnd = false});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      int hour = 0, min = 0, sec = 0;
      double remainingPercent = 0;
      String distanceText = '--';

      if (rideController.matchedMode != null) {
        final duration = rideController.matchedMode?.durationSec ?? 0;
        hour = duration ~/ 3600;
        min = (duration % 3600) ~/ 60;
        sec = duration % 60;
        distanceText = rideController.matchedMode?.distanceText ?? '--';

        final estimatedDistance =
            rideController.tripDetail?.estimatedDistance ?? 0;
        if (estimatedDistance > 0) {
          remainingPercent = ((double.tryParse(
                          rideController.matchedMode!.distance.toString()) ??
                      0) /
                  1000) /
              estimatedDistance;
        }
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(
            0, Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeSmall),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: Theme.of(context).hintColor.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.timer_rounded,
                title: 'Trip time',
                value:
                    '${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}',
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: _InfoTile(
                icon: Icons.route_rounded,
                title: 'Remaining',
                value: distanceText,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            CircularPercentIndicator(
              radius: 34,
              lineWidth: 5,
              percent: remainingPercent.clamp(0, 1),
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              progressColor: Theme.of(context).colorScheme.primary,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    distanceText.replaceAll(' km', '').replaceAll('KM', ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textSemiBold.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                  Text('km',
                      style: textRegular.copyWith(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.secondary)),
                ],
              ),
            ),
          ]),
          if (rideController.tripDetail!.type == 'ride_request' &&
              !fromEnd) ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),
            ButtonWidget(
              buttonText: rideController.tripDetail!.isPaused!
                  ? 'resume_trip_from_here'.tr
                  : 'pause_trip_for_a_moment'.tr,
              transparent: true,
              icon: rideController.tripDetail!.isPaused!
                  ? Icons.play_arrow_rounded
                  : Icons.pause_rounded,
              borderWidth: 1,
              showBorder: true,
              iconColor: rideController.tripDetail!.isPaused!
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.secondary,
              radius: 14,
              borderColor: Theme.of(context).hintColor.withValues(alpha: 0.20),
              onPressed: () {
                rideController
                    .waitingForCustomer(
                  rideController.tripDetail!.id!,
                  rideController.tripDetail!.isPaused! ? 'resume' : 'pause',
                )
                    .then((value) {
                  if (value.statusCode == 200) {
                    rideController
                        .getRideDetails(rideController.tripDetail!.id!);
                  }
                });
              },
            ),
          ],
        ]),
      );
    });
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile(
      {required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              size: 17, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textRegular.copyWith(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.secondary)),
            const SizedBox(height: 2),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textBold.copyWith(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onPrimary)),
          ]),
        ),
      ]),
    );
  }
}
