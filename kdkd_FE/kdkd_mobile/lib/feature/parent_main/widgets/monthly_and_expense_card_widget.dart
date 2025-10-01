import 'package:flutter/material.dart';
import 'package:kdkd_mobile/common/format/string_format.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/feature/parent_main/models/parent_latest_payment_model.dart';

class MonthlyAndExpenseCardWidget extends StatelessWidget {
  const MonthlyAndExpenseCardWidget({
    super.key,
    this.accountBalance,
    this.latestPayment,
  });

  final int? accountBalance;
  final ParentLatestPaymentModel? latestPayment;

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
                  '매월 용돈',
                  style: AppFonts.bodyLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
                Text(
                  accountBalance != null ? StringFormat.formatMoney(accountBalance) : '조회중...',
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
    ParentLatestPaymentModel? latestPayment,
  }) {
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
          latestPayment.childName,
          style: AppFonts.titleLarge.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
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
