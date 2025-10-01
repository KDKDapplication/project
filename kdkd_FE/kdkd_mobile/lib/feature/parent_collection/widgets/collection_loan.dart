import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kdkd_mobile/common/container/custom_container.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/child_loan/models/loan_status_response.dart';
import 'package:kdkd_mobile/feature/parent_common/models/child_account_model.dart';
import 'package:kdkd_mobile/feature/parent_loan/providers/loan_provider.dart';

class CollectionLoan extends ConsumerWidget {
  final ChildAccountModel? selectedChild;

  const CollectionLoan({
    super.key,
    required this.selectedChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanStatus = selectedChild?.loanStatus;
    

    switch (loanStatus) {
      case LoanStatus.ACTIVE:
        return SliverToBoxAdapter(child: _buildLoanInfo());
      case LoanStatus.WAITING_APPROVAL:
        return SliverToBoxAdapter(
          child: Column(
            children: [
              _buildWaitingApprovalInfo(ref),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        );
      case LoanStatus.NOT_APPLIED:
      default:
        return SliverToBoxAdapter(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConst.padding),
                child: Text(
                  "${selectedChild!.childName}님은 빌리기중이 아닙니다.",
                  style: AppFonts.thinbasic,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
    }
  }

  Widget _buildLoanInfo() {
    final loanDay = selectedChild?.loanDay;
    final remainingDays = loanDay != null ? DateTime.now().difference(loanDay).inDays.abs() : 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Text(
            "${selectedChild!.childName}님은 빌리기중입니다 남은 기간은 D-$remainingDays일 입니다",
            style: AppFonts.thinbasic,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "빌린금액",
                style: AppFonts.titleLarge,
              ),
              const SizedBox(width: 16),
              Text(
                "${NumberFormat('#,###').format(selectedChild?.loanMoney ?? 0)}원",
                style: AppFonts.titleLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingApprovalInfo(WidgetRef ref) {


    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: AppConst.padding),
      child: CustomContainer(
        child: Padding(
          padding: EdgeInsetsGeometry.all(8),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConst.padding),
                child: Text(
                  "${selectedChild!.childName}님의 빌리기 요청이 승인 대기 중입니다.",
                  style: AppFonts.thinbasic,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "요청금액",
                          style: AppFonts.titleSmall,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${NumberFormat('#,###').format(selectedChild?.loanMoney ?? 0)}원",
                          style: AppFonts.titleLarge,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (selectedChild?.loanUuid != null) {
                              ref.read(parentLoanProvider.notifier).rejectLoan(selectedChild!.loanUuid!);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.redError,
                            ),
                            child: Text(
                              "거절",
                              style: AppFonts.titleSmall.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            if (selectedChild?.loanUuid != null) {
                              ref.read(parentLoanProvider.notifier).acceptLoan(selectedChild!.loanUuid!);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.mint,
                            ),
                            child: Text(
                              "수락",
                              style: AppFonts.titleSmall.copyWith(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
