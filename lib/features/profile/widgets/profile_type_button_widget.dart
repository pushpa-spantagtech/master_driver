import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ProfileTypeButtonWidget extends StatelessWidget {
  final int index;
  final String profileTypeName;

  const ProfileTypeButtonWidget({
    super.key,
    required this.index,
    required this.profileTypeName,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        final bool isSelected = index == controller.profileTypeIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => controller.setProfileTypeIndex(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: MediaQuery.of(context).size.width / 2.4,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.tertiaryContainer
                      : Theme.of(context).hintColor.withValues(alpha: 0.45),
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    index == 0
                        ? Icons.person_outline_rounded
                        : Icons.directions_car_outlined,
                    size: 20,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).hintColor.withValues(alpha: 0.65),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    profileTypeName.tr,
                    style: textSemiBold.copyWith(
                        fontSize: 15,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .hintColor
                                .withValues(alpha: 0.65)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
