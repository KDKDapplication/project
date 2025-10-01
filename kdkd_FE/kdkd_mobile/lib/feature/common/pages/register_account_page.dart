import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/button/custom_button_Large.dart';
import 'package:kdkd_mobile/common/button/custom_button_half_round.dart';
import 'package:kdkd_mobile/common/card/custom_card.dart';
import 'package:kdkd_mobile/common/modal/custom_bottom_modal.dart';
import 'package:kdkd_mobile/common/text_field/custom_text_field_with_label.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/common/providers/account_registration_provider.dart';
import 'package:kdkd_mobile/feature/common/providers/user_account_provider.dart';

class RegisterAccountPage extends ConsumerStatefulWidget {
  const RegisterAccountPage({super.key});

  @override
  ConsumerState<RegisterAccountPage> createState() => _RegisterAccountPageState();
}

class _RegisterAccountPageState extends ConsumerState<RegisterAccountPage> {
  @override
  void initState() {
    super.initState();
    // 페이지 진입 시 입력값 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accountFormProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountFormProvider);

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: CustomAppBar(isLogo: false, title: '내 계좌 등록', useBackspace: true),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(), // 다른 곳 터치 시 키보드 닫기
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: AppConst.padding,
                    vertical: 24,
                  ),
                  child: CustomCard(
                    accountName: account.bank,
                    accountNumber: account.accountNumber,
                  ),
                ),
              ),

              // 은행 선택
              // ! 백엔드에 어떻게 넘겨줄지 논의 필요
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: 36,
                    vertical: 16,
                  ),
                  child: CustomTextFieldWithLabel(
                    title: "은행",
                    value: account.bank,
                    readOnly: true,
                    onTap: () async {
                      final selectedBank = await showBankPicker(context);

                      if (selectedBank != null) {
                        ref.read(accountFormProvider.notifier).setBank(selectedBank);
                      }
                    },
                  ),
                ),
              ),

              // 계좌번호
              // 계좌번호 자동 하이픈 추가, 길이 제한 (0000-00-0000000)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 16,
                  ),
                  child: CustomTextFieldWithLabel(
                    title: "계좌번호",
                    value: account.accountNumber,
                    keyboardType: TextInputType.number,
                    autoFormat: true,
                    inputFormatType: InputFormatType.account,
                    onChanged: (value) {
                      // 이미 숫자만 들어옴 (ex: 3333111548423)
                      ref.read(accountFormProvider.notifier).setAccountNumber(value);
                    },
                  ),
                ),
              ),

              // 비밀번호
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: 36,
                    vertical: 16,
                  ),
                  child: CustomTextFieldWithLabel(
                    title: "비밀번호",
                    value: account.password,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatType: InputFormatType.password,
                    onChanged: (value) {
                      ref.read(accountFormProvider.notifier).setPassword(value);
                    },
                  ),
                ),
              ),

              // 1원 송금 버튼 (1원 송금이 안 된 경우에만 표시)
              if (!account.isOneWonSent)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36.0,
                      vertical: 16,
                    ),
                    child: CustomButtonLarge(
                      text: '1원 송금',
                      onPressed: () async {
                        final success = await ref.read(accountFormProvider.notifier).sendOneWon();
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('1원 송금이 완료되었습니다. 인증번호를 입력해주세요.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(account.error ?? '1원 송금에 실패했습니다.')),
                          );
                        }
                      },
                    ),
                  ),
                ),

              // 인증번호 입력 (1원 송금이 완료된 경우에만 표시)
              if (account.isOneWonSent)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 16,
                    ),
                    child: CustomTextFieldWithLabel(
                      title: "인증코드",
                      value: account.authCode,
                      keyboardType: TextInputType.text,
                      onChanged: (value) {
                        ref.read(accountFormProvider.notifier).setAuthCode(value);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: CustomButtonHalfRound(
          text: "등록",
          onPressed: () async {
            final notifier = ref.read(accountFormProvider.notifier);
            final state = ref.read(accountFormProvider);

            // 1원 송금이 완료되지 않은 경우
            if (!state.isOneWonSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('먼저 1원 송금을 완료해주세요.')),
              );
              return;
            }

            // 1원 인증 먼저 진행
            final verifySuccess = await notifier.verifyOneWon();
            if (!verifySuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('인증에 실패했습니다')),
              );
              return;
            }

            // 1원 인증 성공 후 계좌 등록 진행
            final registerSuccess = await notifier.registerAccount();
            if (registerSuccess) {
              // 계좌 등록 성공 시 사용자 계좌 정보 새로 불러오기
              await ref.read(userAccountProvider.notifier).refreshUserAccount();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('계좌가 성공적으로 등록되었습니다.')),
              );
              context.pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('계좌 등록에 실패했습니다.')),
              );
            }
          },
        ),
      ),
    );
  }
}

Future<String?> showBankPicker(BuildContext context) {
  final banks = [
    "싸피은행",
    // 대형 시중은행
    "KB국민은행", "신한은행", "우리은행", "KEB하나은행",

    // 지방은행
    "부산은행", "대구은행", "광주은행", "전북은행", "경남은행", "제주은행",

    // 인터넷전문은행
    "카카오뱅크", "케이뱅크", "토스뱅크",

    // 특수·국책은행
    "NH농협은행", "IBK기업은행", "KDB산업은행", "한국수출입은행", "수협은행",
  ];

  int selectedIndex = 0;

  return CustomBottomModal.show<String>(
    context: context,
    confirmText: "선택",
    onConfirm: () {
      context.pop(banks[selectedIndex]);
    },
    child: SizedBox(
      height: 250,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 48,
        perspective: 0.002,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          selectedIndex = index;
        },
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: banks.length,
          builder: (context, index) {
            return Center(
              child: Text(banks[index], style: const TextStyle(fontSize: 18)),
            );
          },
        ),
      ),
    ),
  );
}
