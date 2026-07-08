import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';

class ChartWidget extends StatefulWidget {
  const ChartWidget({super.key});

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 12, 6),
      child: GetBuilder<TripController>(
        builder: (tripController) => LineChart(
          mainData(tripController.earningChartList, tripController.maxValue),
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final bool isToday = Get.find<TripController>().selectedOverview == 'today';
    const style = TextStyle(
      color: Color(0xff8994A6),
      fontWeight: FontWeight.w600,
      fontSize: 8.5,
      height: 1,
    );

    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text(isToday ? '6am' : 'Sun', style: style);
        break;
      case 2:
        text = Text(isToday ? '10am' : 'Mon', style: style);
        break;
      case 3:
        text = Text(isToday ? '2pm' : 'Tue', style: style);
        break;
      case 4:
        text = Text(isToday ? '6pm' : 'Wed', style: style);
        break;
      case 5:
        text = Text(isToday ? '10pm' : 'Thu', style: style);
        break;
      case 6:
        text = Text(isToday ? '2am' : 'Fri', style: style);
        break;
      case 7:
        text = Text(isToday ? '' : 'Sat', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff8994A6),
      fontWeight: FontWeight.w500,
      fontSize: 8,
      height: 1,
    );

    String chartValue = meta.formattedValue;

    if (chartValue.toLowerCase().contains('k')) {
      chartValue =
      '${PriceConverter.convertPrice(context, double.parse(chartValue.toLowerCase().replaceAll('k', '')))}K';
    } else if (chartValue.toLowerCase().contains('m')) {
      chartValue =
      '${PriceConverter.convertPrice(context, double.parse(chartValue.toLowerCase().replaceAll('m', '')))}M';
    } else {
      chartValue = PriceConverter.convertPrice(
        context,
        double.parse(chartValue.toLowerCase()),
      );
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 6,
      child: Text(
        chartValue,
        maxLines: 1,
        overflow: TextOverflow.visible,
        style: style,
      ),
    );
  }

  LineChartData mainData(List<FlSpot>? spots, double maxValue) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color softGridColor = Theme.of(context).dividerColor.withValues(alpha: 0.075);
    final double safeMaxValue = maxValue <= 0 ? 1 : maxValue;
    final List<FlSpot> chartSpots = spots ?? [];

    return LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 14,
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tooltipMargin: 14,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                PriceConverter.convertPrice(context, spot.y),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  height: 1,
                ),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: safeMaxValue / 4 <= 0 ? 1 : safeMaxValue / 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: softGridColor,
            strokeWidth: 0.6,
            dashArray: [4, 10],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 46,
            interval: safeMaxValue / 4 <= 0 ? 1 : safeMaxValue / 4,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0.85,
      maxX: 7.15,
      minY: 0,
      maxY: safeMaxValue * 1.12,
      clipData: const FlClipData.none(),
      lineBarsData: [
        LineChartBarData(
          spots: chartSpots,
          isCurved: true,
          curveSmoothness: 0.24,
          barWidth: 1.35,
          isStrokeCapRound: true,
          color: primaryColor,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 2.4,
                color: primaryColor,
                strokeWidth: 1.4,
                strokeColor: Theme.of(context).cardColor,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withValues(alpha: 0.055),
                primaryColor.withValues(alpha: 0.004),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
