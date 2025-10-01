import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/payments_provider.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/selected_child_provider.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

class CollectionSpendingHistory extends ConsumerWidget {
  const CollectionSpendingHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spendingHistoryState = ref.watch(paymentsProvider);
    final childUuid = ref.watch(selectedChildProvider)!.childUuid;
    final selectChild = ref.watch(selectedChildProvider);

    if (selectChild?.childAccountNumber == null) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: AppConst.padding),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            Row(
              children: [
                Text(
                  '지출 내역',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '계좌가 등록되어있지 않습니다',
                style: TextStyle(
                  color: AppColors.grayMedium,
                  fontSize: 14,
                ),
              ),
            ),
          ]),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppConst.padding),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          GestureDetector(
            onTap: () => context.push(
              AppRoutes.parentMainHistory,
              extra: childUuid,
            ),
            child: Row(
              children: [
                Text(
                  '지출 내역',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                SvgPicture.asset(
                  'assets/svgs/arrow.svg',
                  height: 20,
                  width: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._buildSpendingHistoryItems(context, ref, spendingHistoryState),
        ]),
      ),
    );
  }

  List<Widget> _buildSpendingHistoryItems(BuildContext context, WidgetRef ref, spendingHistoryState) {
    if (spendingHistoryState.isLoading && spendingHistoryState.data.isEmpty) {
      return [
        const Center(
          child: CircularProgressIndicator(),
        ),
      ];
    }

    if (spendingHistoryState.error != null) {
      return [
        Text(
          spendingHistoryState.error ?? 'Failed to load spending history',
          style: const TextStyle(color: Colors.red),
        ),
      ];
    }

    if (spendingHistoryState.data.isEmpty) {
      return [Text('최근 지출 내역이 없습니다.')];
    }

    return spendingHistoryState.data.map<Widget>((item) {
      return Consumer(
        builder: (context, ref, child) {
          return _SpendingHistoryItem(
            accountItemSeq: item.accountItemSeq,
            store: item.merchantName,
            amount: item.paymentBalance,
            date: DateFormat('MM.dd').format(item.transactedAt),
            onTap: () {
              final selectedChild = ref.read(selectedChildProvider);
              if (selectedChild != null) {
                context.push(
                  '${AppRoutes.parentCollectionSpendDetail}?childUuid=${selectedChild.childUuid}&accountItemSeq=${item.accountItemSeq}',
                );
              }
            },
          );
        },
      );
    }).toList();
  }
}

class _SpendingHistoryItem extends StatelessWidget {
  final int accountItemSeq;
  final String store;
  final int amount;
  final String date;
  final VoidCallback? onTap;

  const _SpendingHistoryItem({
    required this.accountItemSeq,
    required this.store,
    required this.amount,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = amount < 0;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Text(date, style: const TextStyle(color: AppColors.grayMedium, fontSize: 12)),
            const SizedBox(width: 16),
            Expanded(child: Text(store, style: const TextStyle(fontWeight: FontWeight.w500))),
            Text(
              '${NumberFormat('#,###').format(amount)}원',
              style: TextStyle(
                color: isExpense ? Colors.black : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
