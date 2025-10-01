import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';

import './deposit_history_item.dart';

class DepositHistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> depositHistory;
  const DepositHistoryList({super.key, required this.depositHistory});

  @override
  Widget build(BuildContext context) {
    if (depositHistory.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.only(top: 100),
          child: Center(child: Text('저축 내역이 없습니다.')),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: depositHistory.length,
              itemBuilder: (context, index) {
                final item = depositHistory[index];
                return DepositHistoryItem(
                  date: item['date'] as String,
                  amount: item['amount'] as int,
                  memo: item['memo'] as String,
                );
              },
              separatorBuilder: (context, index) => const Divider(
                color: AppColors.graySoft,
                height: 32, // Includes padding above and below
                thickness: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
