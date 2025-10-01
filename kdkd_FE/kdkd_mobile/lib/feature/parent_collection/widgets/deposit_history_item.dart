import 'package:flutter/material.dart';
import 'package:kdkd_mobile/common/format/string_format.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';

class DepositHistoryItem extends StatelessWidget {
  final String date;
  final int amount;
  final String memo;

  const DepositHistoryItem({super.key, required this.date, required this.amount, required this.memo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConst.padding, vertical: 16),
      child: Row(
        children: [
          Text(date, style: const TextStyle(color: AppColors.grayMedium, fontSize: 14)),
          const SizedBox(width: 24),
          Expanded(child: Text(memo, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16))),
          Text(
            '+${StringFormat.formatMoney(amount)}',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
