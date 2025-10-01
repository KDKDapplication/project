import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/button/custom_button_Large.dart';
import 'package:kdkd_mobile/common/date_picker/custom_date_picker.dart';
import 'package:kdkd_mobile/common/text_field/custom_input_field.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/child_loan/models/loan_status_response.dart';
import 'package:kdkd_mobile/feature/child_loan/models/request_loan_info.dart';
import 'package:kdkd_mobile/feature/child_loan/provider/loan_provider.dart';
import 'package:kdkd_mobile/feature/child_loan/widgets/rate_selection_box.dart';

class ChildLoanPage extends ConsumerStatefulWidget {
  const ChildLoanPage({super.key});

  @override
  ConsumerState<ChildLoanPage> createState() => _ChildLoanPageState();
}

class _ChildLoanPageState extends ConsumerState<ChildLoanPage> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  int _selectedRateIndex = 0;
  bool _isLoading = false;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<LoanStatusResponse?> res = ref.watch(loanStatusProvider);

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: CustomAppBar(
          useBackspace: true,
          title: "빌리기",
          actionType: AppBarActionType.none,
        ),
        body: res.when(
          data: (loanStatus) => _buildContent(loanStatus),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('오류가 발생했습니다: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(loanStatusProvider),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(LoanStatusResponse? loanStatus) {
    if (loanStatus == null) {
      return _buildLoanRequestForm();
    }

    switch (loanStatus.loanStatus) {
      case LoanStatus.NOT_APPLIED:
        return _buildLoanRequestForm();
      case LoanStatus.WAITING_APPROVAL:
        return _buildWaitingApprovalView(loanStatus);
      case LoanStatus.ACTIVE:
        return _buildActiveLoanView(loanStatus);
    }
  }

  Widget _buildLoanRequestForm() {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConst.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  "요청 금액",
                  style: AppFonts.headlineSmall.copyWith(color: const Color(0xFF2F2F2F)),
                ),
                const SizedBox(width: 2),
                SvgPicture.asset('assets/svgs/badge-check.svg'),
              ],
            ),
            CustomInputField(
              controller: _amountController,
              hintText: "요청 금액 입력",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 34),
            Row(
              children: [
                Text(
                  "사유",
                  style: AppFonts.headlineSmall.copyWith(color: const Color(0xFF2F2F2F)),
                ),
                const SizedBox(width: 2),
                SvgPicture.asset('assets/svgs/badge-check.svg'),
              ],
            ),
            CustomInputField(
              controller: _reasonController,
              hintText: "사유를 입력하세요",
              maxLines: 3,
            ),
            const SizedBox(height: 34),
            Row(
              children: [
                Text(
                  "이자율",
                  style: AppFonts.headlineSmall.copyWith(color: const Color(0xFF2F2F2F)),
                ),
                const SizedBox(width: 2),
                SvgPicture.asset('assets/svgs/badge-check.svg'),
              ],
            ),
            const SizedBox(height: 12),
            RateSelectionBox(
              rates: const ['2.0%', '3.0%', '4.0%', '5.0%'],
              onRateSelected: (index) {
                setState(() {
                  _selectedRateIndex = index;
                });
              },
            ),
            const SizedBox(height: 34),
            Text(
              "이자는 왜 내는 거예요?",
              style: AppFonts.labelMedium.copyWith(color: AppColors.darkGray),
            ),
            const SizedBox(height: 8),
            Text(
              "빌려주는 동안 위험도 있고, 시간이 지나면 돈의 가치도 달라지죠.\n"
              "그래서 빌린 사람은 '돈을 사용하는 값'으로 이자를 내는 거예요.",
              style: AppFonts.bodySmall.copyWith(color: AppColors.darkGray),
            ),
            const SizedBox(height: 34),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "만기일",
                      style: AppFonts.headlineSmall.copyWith(color: AppColors.darkGray),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset('assets/svgs/badge-check.svg'),
                  ],
                ),
                CustomDatePicker(
                  selectedDate: _selectedDate,
                  onDateChanged: (DateTime newDate) => setState(() => _selectedDate = newDate),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CustomButtonLarge(
          text: _isLoading ? '요청 중...' : '빌리기 요청',
          onPressed: _isLoading ? null : _handleLoanRequest,
        ),
      ),
    );
  }

  Widget _buildWaitingApprovalView(LoanStatusResponse loanStatus) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConst.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          SvgPicture.asset(
            'assets/svgs/time.svg',
            height: 80,
            width: 80,
            color: AppColors.yellow,
          ),
          const SizedBox(height: 24),
          Text(
            '빌리기 승인 대기 중',
            style: AppFonts.headlineMedium.copyWith(color: AppColors.darkGray),
          ),
          const SizedBox(height: 16),
          Text(
            '부모님께서 승인해주실 때까지 기다려주세요.',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.grayMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.grayBG,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '요청 정보',
                  style: AppFonts.titleMedium.copyWith(color: AppColors.darkGray),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('요청 금액', '${loanStatus.loanAmount?.toString() ?? '0'}원'),
                const SizedBox(height: 8),
                _buildInfoRow('이자율', '${loanStatus.loanInterest?.toString() ?? '0'}%'),
                const SizedBox(height: 8),
                _buildInfoRow('사유', loanStatus.loanContent ?? ''),
                const SizedBox(height: 8),
                _buildInfoRow('만기일', loanStatus.loanDue != null ? _dateFormat.format(loanStatus.loanDue!) : ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveLoanView(LoanStatusResponse loanStatus) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConst.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            SvgPicture.asset(
              'assets/svgs/money_bag.svg',
              height: 80,
              width: 80,
              color: AppColors.blueAccent,
            ),
            const SizedBox(height: 24),
            Text(
              '빌린 금액',
              style: AppFonts.headlineMedium.copyWith(color: AppColors.darkGray),
            ),
            const SizedBox(height: 8),
            Text(
              '${loanStatus.loanAmount?.toString() ?? '0'}원',
              style: AppFonts.displaySmall.copyWith(
                color: AppColors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: AppColors.grayBG,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '대출 정보',
                    style: AppFonts.titleMedium.copyWith(color: AppColors.darkGray),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('이자율', '${loanStatus.loanInterest?.toString() ?? '0'}%'),
                  const SizedBox(height: 8),
                  _buildInfoRow('현재 이자', '${loanStatus.currentInterestAmount?.toString() ?? '0'}원'),
                  const SizedBox(height: 8),
                  _buildInfoRow('대출일', loanStatus.loanDate != null ? _dateFormat.format(loanStatus.loanDate!) : ''),
                  const SizedBox(height: 8),
                  _buildInfoRow('만기일', loanStatus.loanDue != null ? _dateFormat.format(loanStatus.loanDue!) : ''),
                  const SizedBox(height: 8),
                  _buildInfoRow('사유', loanStatus.loanContent ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CustomButtonLarge(
          text: '상환하기',
          onPressed: () => _handlePayback(loanStatus.loanUuid!),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFonts.bodyMedium.copyWith(color: AppColors.grayMedium),
        ),
        Flexible(
          child: Text(
            value,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.darkGray),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Future<void> _handlePayback(String loanUuid) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('상환하기'),
        content: const Text('정말 상환하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('상환하기'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final paybackResult = await ref.read(loanStatusProvider.notifier).paybackLoan(loanUuid);
        if (paybackResult != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('상환이 완료되었습니다')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('상환에 실패했습니다')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<void> _handleLoanRequest() async {
    if (_amountController.text.isEmpty || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요')),
      );
      return;
    }

    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효한 금액을 입력해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final interestRates = [2, 3, 4, 5];
      final requestLoanInfo = RequestLoanInfo(
        loanAmount: amount,
        loanDue: _selectedDate,
        loanInterest: interestRates[_selectedRateIndex],
        loanContent: _reasonController.text,
      );

      final success = await ref.read(loanStatusProvider.notifier).applyLoan(requestLoanInfo);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('빌리기 요청이 완료되었습니다')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('빌리기 요청에 실패했습니다')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
