import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kdkd_mobile/common/format/string_format.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/common/models/history_model.dart';

class HistoryConsumptionWidget extends StatelessWidget {
  const HistoryConsumptionWidget({
    super.key,
    required this.data,
    this.currentMonth,
    this.onMonthChanged,
  });

  final List<HistoryItem> data;
  final int? currentMonth;
  final Function(int)? onMonthChanged;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        color: AppColors.white,
        child: const Center(
          child: Text(
            "소비 내역이 없어요",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    final groupedTransactions = _groupByDate();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConst.padding,
        vertical: 24,
      ),
      color: AppColors.white,
      child: ListView.separated(
        itemCount: groupedTransactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 36),
        itemBuilder: (context, index) {
          final dateKey = groupedTransactions.keys.elementAt(index);
          final dayTransactions = groupedTransactions[dateKey]!;
          return _TransactionDayItem(
            date: dateKey,
            transactions: dayTransactions,
          );
        },
      ),
    );
  }

  Map<String, List<HistoryItem>> _groupByDate() {
    final Map<String, List<HistoryItem>> grouped = {};

    for (final transaction in data) {
      final dateKey = transaction.date;
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }
}

class _HistoryAppBar extends StatelessWidget {
  const _HistoryAppBar({
    required this.transactions,
    this.currentMonth,
    this.onMonthChanged,
  });

  final List<HistoryItem> transactions;
  final int? currentMonth;
  final Function(int)? onMonthChanged;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      toolbarHeight: 70,
      pinned: true,
      elevation: 12.0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConst.padding,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFAEFFDC).withValues(alpha: 0.1),
              const Color(0xFF9B6BFF).withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (onMonthChanged != null)
              GestureDetector(
                onTap: () {
                  final month = currentMonth ?? DateTime.now().month;
                  final newMonth = month == 1 ? 12 : month - 1;
                  onMonthChanged!(newMonth);
                },
                child: SvgPicture.asset(
                  'assets/svgs/left_tri.svg',
                  height: 24,
                  width: 24,
                  color: AppColors.darkGray,
                ),
              )
            else
              const SizedBox(width: 28),
            SizedBox(width: 8),
            Text(
              "${currentMonth ?? DateTime.now().month}월",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8),
            if (onMonthChanged != null)
              GestureDetector(
                onTap: () {
                  final month = currentMonth ?? DateTime.now().month;
                  final newMonth = month == 12 ? 1 : month + 1;
                  onMonthChanged!(newMonth);
                },
                child: SvgPicture.asset(
                  'assets/svgs/right_tri.svg',
                  height: 24,
                  width: 24,
                  color: AppColors.darkGray,
                ),
              )
            else
              const SizedBox(width: 28),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          height: 4,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C4CAF).withValues(alpha: 0.3),
                blurRadius: 11.8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTransactionMessage extends StatelessWidget {
  const _EmptyTransactionMessage();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        color: AppColors.white,
        child: const Center(
          child: Text(
            "소비 내역이 없어요",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions});

  final List<HistoryItem> transactions;

  // 날짜별로 그룹핑
  Map<String, List<HistoryItem>> _groupByDate() {
    final Map<String, List<HistoryItem>> grouped = {};

    for (final transaction in transactions) {
      final dateKey = transaction.date; // "YYYY-MM-DD" 형태
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedTransactions = _groupByDate();

    return SliverFillRemaining(
      hasScrollBody: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConst.padding,
          vertical: 24,
        ),
        color: AppColors.white,
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groupedTransactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 36),
          itemBuilder: (context, index) {
            final dateKey = groupedTransactions.keys.elementAt(index);
            final dayTransactions = groupedTransactions[dateKey]!;
            return _TransactionDayItem(
              date: dateKey,
              transactions: dayTransactions,
            );
          },
        ),
      ),
    );
  }
}

class _TransactionDayItem extends StatelessWidget {
  const _TransactionDayItem({
    required this.date,
    required this.transactions,
  });

  final String date; // "YYYY-MM-DD" 형태
  final List<HistoryItem> transactions;

  @override
  Widget build(BuildContext context) {
    const weekdays = ["월", "화", "수", "목", "금", "토", "일"];
    final parsedDate = DateTime.parse(date);
    final weekday = weekdays[parsedDate.weekday - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${parsedDate.day}일 $weekday요일",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...transactions.map((transaction) {
          return _TransactionDetailRow(transaction: transaction);
        }),
      ],
    );
  }
}

class _TransactionDetailRow extends StatelessWidget {
  const _TransactionDetailRow({required this.transaction});

  final HistoryItem transaction;

  String _formatAmount(int amount) {
    return '${transaction.direction == '감소' ? '-' : '+'} ${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}원';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.graySoft,
            width: .5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: -.5,
                  ),
                ),
                if (transaction.time.isNotEmpty)
                  Text(
                    StringFormat.formatTime(transaction.time),
                    style: TextStyle(
                      color: AppColors.grayMedium,
                      fontSize: 12,
                      letterSpacing: -0.5,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatAmount(transaction.amount),
                style: TextStyle(
                  color: transaction.direction == '감소' ? Colors.red : AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: -.5,
                ),
              ),
              Text(
                StringFormat.formatCardAccount(transaction.source),
                style: TextStyle(
                  color: AppColors.grayMedium,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
