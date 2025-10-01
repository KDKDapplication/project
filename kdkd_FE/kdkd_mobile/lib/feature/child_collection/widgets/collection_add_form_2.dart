import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/common/text_field/custom_text_field.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:kdkd_mobile/feature/child_main/providers/auto_transfer_provider.dart';
import 'package:kdkd_mobile/feature/common/providers/user_account_provider.dart';

class CollectionAddForm2 extends ConsumerStatefulWidget {
  const CollectionAddForm2({
    super.key,
    this.initialSavingAmount = '',
    required this.onPriceChanged,
  });

  final String initialSavingAmount;
  final ValueChanged<String> onPriceChanged;

  @override
  ConsumerState<CollectionAddForm2> createState() => _AccountAddForm2State();
}

class _AccountAddForm2State extends ConsumerState<CollectionAddForm2> {
  late TextEditingController _savingAmountController;

  @override
  void initState() {
    super.initState();
    _savingAmountController = TextEditingController(text: widget.initialSavingAmount);

    // 초기값 콜백 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSavingAmount.isNotEmpty) {
        widget.onPriceChanged(widget.initialSavingAmount);
      }
    });
  }

  @override
  void dispose() {
    _savingAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 이름 용
    final profile = ref.watch(profileProvider);

    // 계좌 잔액용
    final accountBalance = ref.watch(userAccountProvider);

    // 매달 용돈 조회용
    final autoTransfer = ref.watch(autoTransferProvider);

    // 사용자 이름 가져오기
    final userName = profile.when(
      idle: () => '사용자',
      loading: () => '사용자',
      success: (data, isFallback, fromCache) => data.name ?? '사용자',
      failure: (error, message) => '사용자',
    );

    // 자동이체 금액 가져오기
    final autoTransferAmount = autoTransfer.when(
      data: (amount) => amount ?? 0,
      loading: () => 0,
      error: (_, __) => 0,
    );

    // 계좌 잔액 가져오기
    final balance = accountBalance.when(
      idle: () => 0,
      loading: () => 0,
      success: (data, isFallback, fromCache) => data.balance ?? 0,
      failure: (error, message) => 0,
    );

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            '$userName 님이 현재 정기 적금에 이체되고 있는',
            style: AppFonts.titleMedium.copyWith(fontSize: 16),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '금액은 매달',
                style: AppFonts.titleMedium.copyWith(fontSize: 16),
              ),
              Text(
                " ${autoTransferAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원 ",
                style: AppFonts.headlineMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                "이에요",
                style: AppFonts.titleMedium.copyWith(fontSize: 16),
              ),
            ],
          ),
          Divider(
            height: 60,
            thickness: 1.5,
            color: AppColors.primary,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConst.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '현재 잔액',
                  style: AppFonts.titleMedium.copyWith(fontSize: 16),
                ),
                Text(
                  '${balance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                  style: AppFonts.titleMedium.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            '생성할 모으기 상자에 매달 저금할 금액을 입력해주세요',
            style: AppFonts.titleMedium.copyWith(fontSize: 14),
          ),
          SizedBox(
            height: 8,
          ),
          CustomTextField(
            controller: _savingAmountController,
            onChanged: widget.onPriceChanged,
            keyboardType: TextInputType.number,
          ),
          SizedBox(
            height: 56,
          ),
          Text(
            '저금할 금액을 다음에 설정하고 싶으면 생성을 눌러주세요',
            style: AppFonts.titleMedium.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
