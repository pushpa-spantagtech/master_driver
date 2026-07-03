import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

class RouteWidget extends StatelessWidget {
  final String pickupAddress;
  final String destinationAddress;
  final String? extraOne;
  final String? extraTwo;
  final List<String>? extraRoutes;
  final String? entrance;
  final bool fromCard;

  const RouteWidget({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    this.extraOne,
    this.extraTwo,
    this.extraRoutes,
    this.entrance,
    this.fromCard = false,
  });

  List<String> get _stops {
    final List<String> stops = [];

    void addStop(String? value) {
      final String stop = (value ?? '').trim();
      if (stop.isEmpty || stop == '[, ]' || stop == '[]') return;

      // Customer app can send multiple stops as one comma separated value
      // like: "a, bc, cd". Show them line by line as Stop 1, Stop 2,
      // Stop 3... instead of showing all text under Stop 1.
      if (stop.contains(',')) {
        final List<String> separatedStops = stop
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();

        if (separatedStops.length > 1) {
          for (final String separatedStop in separatedStops) {
            addStop(separatedStop);
          }
          return;
        }
      }

      if (!stops.any((item) => item.toLowerCase() == stop.toLowerCase())) {
        stops.add(stop);
      }
    }

    if (extraOne != null && extraOne!.trim().isNotEmpty) {
      addStop(extraOne);
    }

    if (extraRoutes != null && extraRoutes!.isNotEmpty) {
      for (final String route in extraRoutes!) {
        addStop(route);
      }
    }

    if (extraTwo != null && extraTwo!.trim().isNotEmpty) {
      addStop(extraTwo);
    }

    // In some ride requests the customer added stop comes in `entrance`.
    // Show it before destination as Stop 1 / Stop 2, not after destination.
    if (entrance != null && entrance!.trim().isNotEmpty) {
      addStop(entrance);
    }

    return stops;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> stops = _stops;

    return GetBuilder<RideController>(builder: (riderController) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(fromCard ? 10 : Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
          border: Border.all(
            color: Theme.of(context).hintColor.withValues(alpha: 0.18),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _RouteTile(
            icon: Icons.my_location_rounded,
            title: 'Pickup Location',
            address: pickupAddress,
            isFirst: true,
            showBottomLine: stops.isNotEmpty || destinationAddress.isNotEmpty,
          ),
          for (int i = 0; i < stops.length; i++)
            _RouteTile(
              icon: Icons.add_location_alt_rounded,
              title: 'Stop ${i + 1}',
              address: stops[i],
              showTopLine: true,
              showBottomLine: true,
            ),
          _RouteTile(
            icon: Icons.location_on_rounded,
            title: 'Destination',
            address: destinationAddress,
            isLast: true,
            showTopLine: stops.isNotEmpty || pickupAddress.isNotEmpty,
          ),
        ]),
      );
    });
  }
}

class _RouteTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String address;
  final bool isFirst;
  final bool isLast;
  final bool showTopLine;
  final bool showBottomLine;

  const _RouteTile({
    required this.icon,
    required this.title,
    required this.address,
    this.isFirst = false,
    this.isLast = false,
    this.showTopLine = false,
    this.showBottomLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 28,
        child: Column(children: [
          if (showTopLine)
            SizedBox(
              height: 8,
              child: _VerticalDashedLine(
                color: Theme.of(context).hintColor.withValues(alpha: 0.55),
              ),
            )
          else
            const SizedBox(height: 8),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isFirst
                  ? Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.10)
                  : isLast
                      ? Theme.of(context)
                          .colorScheme
                          .error
                          .withValues(alpha: 0.10)
                      : Theme.of(context).colorScheme.secondaryContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: isFirst || !isLast
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isLast
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          if (showBottomLine)
            SizedBox(
              height: 24,
              child: _VerticalDashedLine(
                color: Theme.of(context).hintColor.withValues(alpha: 0.55),
              ),
            )
          else
            const SizedBox(height: 8),
        ]),
      ),
      const SizedBox(width: Dimensions.paddingSizeSmall),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                address,
                style: textRegular.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}

class _VerticalDashedLine extends StatelessWidget {
  final Color color;

  const _VerticalDashedLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const double dashHeight = 3;
      const double dashSpace = 3;
      final int dashCount = (constraints.maxHeight / (dashHeight + dashSpace))
          .floor()
          .clamp(1, 100);

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(dashCount, (index) {
          return Padding(
            padding:
                EdgeInsets.only(bottom: index == dashCount - 1 ? 0 : dashSpace),
            child: SizedBox(
              width: 1,
              height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            ),
          );
        }),
      );
    });
  }
}
