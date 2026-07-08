import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/notification/domain/models/notification_model.dart';

class NotificationCardWidget extends StatelessWidget {
  final Notifications notification;

  const NotificationCardWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final String title = notification.title ?? '';
    final String description = notification.description ?? '';
    final _NotificationStyle style = _getNotificationStyle(title, description);

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: style.color.withOpacity(.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: style.color.withOpacity(.13),
                shape: BoxShape.circle,
              ),
              child: Icon(style.icon, color: style.color, size: 22),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textMedium.copyWith(
                            color: const Color(0xFF1F2937),
                            fontSize: Dimensions.fontSizeDefault + 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: style.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textRegular.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: Dimensions.fontSizeSmall + 1,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: const Color(0xFF94A3B8).withOpacity(.95),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          notification.createdAt != null
                              ? DateConverter.isoStringToDateTimeString(
                                  notification.createdAt!)
                              : '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textRegular.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: Dimensions.fontSizeSmall,
                          ),
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
  }

  _NotificationStyle _getNotificationStyle(String title, String description) {
    final String text = '$title $description'.toLowerCase();

    if (text.contains('cancel')) {
      return const _NotificationStyle(
        color: Color(0xFFEF4444),
        icon: Icons.cancel_rounded,
      );
    }

    if (text.contains('payment') ||
        text.contains('cash') ||
        text.contains('paid')) {
      return const _NotificationStyle(
        color: Color(0xFF16A34A),
        icon: Icons.account_balance_wallet_rounded,
      );
    }

    if (text.contains('review') || text.contains('rating')) {
      return const _NotificationStyle(
        color: Color(0xFF8B5CF6),
        icon: Icons.star_rounded,
      );
    }

    if (text.contains('ride')) {
      return const _NotificationStyle(
        color: Color(0xFFF59E0B),
        icon: Icons.local_taxi_rounded,
      );
    }

    return const _NotificationStyle(
      color: Color(0xFF2563EB),
      icon: Icons.notifications_rounded,
    );
  }
}

class _NotificationStyle {
  final Color color;
  final IconData icon;

  const _NotificationStyle({required this.color, required this.icon});
}
