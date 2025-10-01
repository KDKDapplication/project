import 'package:flutter/material.dart';

class ChartLegend extends StatelessWidget {
  final Color thisMonthColor;
  final Color lastMonthColor;

  const ChartLegend({
    super.key,
    required this.thisMonthColor,
    required this.lastMonthColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          color: thisMonthColor,
        ),
        const SizedBox(width: 4),
        const Text('이번 달'),
        const SizedBox(width: 12),
        Container(
          width: 12,
          height: 12,
          color: lastMonthColor,
        ),
        const SizedBox(width: 4),
        const Text('지난 달'),
      ],
    );
  }
}