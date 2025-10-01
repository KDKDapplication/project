import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kdkd_mobile/feature/parent_collection/models/spending_item.dart';

class SpendingBarChart extends StatelessWidget {
  final Color thisMonthColor;
  final Color lastMonthColor;
  final List<SpendingItem> thisData;
  final List<SpendingItem> lastData;

  const SpendingBarChart({
    super.key,
    required this.thisMonthColor,
    required this.lastMonthColor,
    required this.thisData,
    required this.lastData,
  });

  @override
  Widget build(BuildContext context) {
    // SpendingItem에서 카테고리별 데이터 추출
    final Map<String, double> thisMonthByCategory = {};
    final Map<String, double> lastMonthByCategory = {};

    if (thisData.isNotEmpty) {
      final thisItem = thisData.first;
      thisMonthByCategory['편의점'] = thisItem.convenienceStoreAmount.toDouble();
      thisMonthByCategory['카페'] = thisItem.cafeAmount.toDouble();
      thisMonthByCategory['음식점'] = thisItem.restaurantAmount.toDouble();
      thisMonthByCategory['문구/서점'] = thisItem.stationaryStoreAmount.toDouble();
      thisMonthByCategory['문화'] = thisItem.cultureAmount.toDouble();
      thisMonthByCategory['교통'] = thisItem.transportationAmount.toDouble();
      thisMonthByCategory['기타'] = thisItem.etcAmount.toDouble();
    }

    if (lastData.isNotEmpty) {
      final lastItem = lastData.first;
      lastMonthByCategory['편의점'] = lastItem.convenienceStoreAmount.toDouble();
      lastMonthByCategory['카페'] = lastItem.cafeAmount.toDouble();
      lastMonthByCategory['음식점'] = lastItem.restaurantAmount.toDouble();
      lastMonthByCategory['문구/서점'] = lastItem.stationaryStoreAmount.toDouble();
      lastMonthByCategory['문화'] = lastItem.cultureAmount.toDouble();
      lastMonthByCategory['교통'] = lastItem.transportationAmount.toDouble();
      lastMonthByCategory['기타'] = lastItem.etcAmount.toDouble();
    }

    // 카테고리 순서 고정
    final categories = ['편의점', '카페', '음식점', '문구/서점', '문화', '교통', '기타'];

    final List<BarChartGroupData> barGroups = List.generate(categories.length, (index) {
      final category = categories[index];
      final thisMonthValue = (thisMonthByCategory[category] ?? 0) / 1000; // 천원 단위로 변환
      final lastMonthValue = (lastMonthByCategory[category] ?? 0) / 1000;

      return BarChartGroupData(
        x: index,
        barRods: [
          // Bar for this month
          BarChartRodData(
            toY: thisMonthValue,
            color: thisMonthColor,
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          // Bar for last month
          BarChartRodData(
            toY: lastMonthValue,
            color: lastMonthColor,
            width: 8,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
        barsSpace: 4, // Space between the two bars within a group
      );
    });

    // Configuration for the BarChart
    final BarChartData barChartData = BarChartData(
      barGroups: barGroups,
      alignment: BarChartAlignment.spaceAround,
      maxY: 130, // Increased max Y value to accommodate all data
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              final index = value.toInt();
              if (index >= 0 && index < categories.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    categories[index],
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),

      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String month = rodIndex == 0 ? '이번 달' : '지난 달';
            return BarTooltipItem(
              '${categories[group.x]}\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '$month: ${(rod.toY * 1000).toStringAsFixed(0)}원',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    return SizedBox(
      height: 300,
      child: BarChart(barChartData),
    );
  }
}
