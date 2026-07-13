import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyActivityCardWidget extends StatelessWidget {
  final int index;
  final String title;
  final String icon;
  final int value;
  final Color color;

  const MyActivityCardWidget({
    super.key,
    required this.index,
    required this.title,
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    int hour = 0;
    int min = 0;

    if (value >= 60) {
      hour = (value / 60).floor();
    }
    min = (value % 60).floor();

    final String formattedValue =
        '${hour > 0 ? '$hour hr ' : ''}${min > 0 ? '$min min' : '0 min'}';

    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Container(
        width: 154,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE8EAF0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A101828),
              blurRadius: 16,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    icon,
                    color: color,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 12.5,
                height: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              formattedValue,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
