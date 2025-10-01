import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kdkd_mobile/common/format/string_format.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/feature/child_main/models/child_latest_payment_model.dart';
import 'package:kdkd_mobile/feature/child_main/models/transaction.dart';
import 'package:kdkd_mobile/feature/child_main/models/transaction_history.dart';

class MonthlyAndExpenseCardWidget extends StatelessWidget {
  const MonthlyAndExpenseCardWidget({
    super.key,
    this.accountBalance,
    this.transactionHistory,
    this.recentTransactions,
    required this.hasAccountNumber,
    this.latestPayment,
  });

  final bool hasAccountNumber;
  final int? accountBalance;
  final TransactionHistory? transactionHistory;
  final List<Transaction>? recentTransactions;
  final ChildLatestPaymentModel? latestPayment;

  String _formatBalance(int? balance) {
    if (balance == null) return '잔액 조회중...';
    final formatter = NumberFormat('#,###');
    return '${formatter.format(balance)}원';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF9B6BFF),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C4CAF).withOpacity(0.3),
                  blurRadius: 11.8,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '용돈😍',
                  style: AppFonts.bodyLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
                Text(
                  hasAccountNumber ? _formatBalance(accountBalance) : '계좌 미등록',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C4CAF).withOpacity(0.3),
                  blurRadius: 11.8,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '최근 지출',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF9B6BFF),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildTransactionList(latestPayment: latestPayment),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList({
    ChildLatestPaymentModel? latestPayment,
  }) {
    print('latestPayment : $latestPayment');
    if (latestPayment == null) {
      return const Center(
        child: Text(
          '소비내역이 없습니다',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFFAFAFAF),
            letterSpacing: -0.56,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          textAlign: TextAlign.end,
          latestPayment.merchantName,
          style: AppFonts.titleLarge.copyWith(
            fontSize: 16,
          ),
        ),
        Spacer(),
        Text(
          textAlign: TextAlign.end,
          StringFormat.formatMoney(latestPayment.paymentBalance),
          style: AppFonts.labelMedium.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
