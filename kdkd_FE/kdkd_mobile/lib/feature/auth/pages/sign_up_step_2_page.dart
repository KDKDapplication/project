import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/date_picker/custom_date_picker.dart';
import 'package:kdkd_mobile/common/progress/custom_progress_bar.dart';
import 'package:kdkd_mobile/common/text_field/custom_text_field_with_label.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/feature/auth/models/sign_up_model.dart';
import 'package:kdkd_mobile/feature/auth/providers/sign_up_provider.dart';

class SignUpStep2Page extends ConsumerStatefulWidget {
  const SignUpStep2Page({super.key});

  @override
  ConsumerState<SignUpStep2Page> createState() => _SignUpStep2PageState();
}

class _SignUpStep2PageState extends ConsumerState<SignUpStep2Page> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 초기 생년월일 설정을 위젯 빌드 후 실행
    Future(() {
      _onDateSelected(_selectedDate);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime selectedDay) {
    setState(() {
      _selectedDate = selectedDay;
    });
    final birthDateString =
        "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
    ref.read(signUpProvider.notifier).setBirthDate(birthDateString);
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpProvider);
    final assetPath =
        signUpState.userRole == UserRole.parent ? 'assets/svgs/parent_avatar.svg' : 'assets/svgs/child_avatar.svg';

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 키보드 내리기
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: CustomAppBar(
            title: '회원가입',
            useBackspace: true,
            actionType: AppBarActionType.none,
          ),
          body: Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomProgressBar(value: 1),
                        const SizedBox(height: 24),
                        Center(
                          child: SvgPicture.asset(assetPath, width: 80, height: 80),
                        ),
                        const SizedBox(height: 24),
                        CustomTextFieldWithLabel(
                          title: "이름",
                          keyboardType: TextInputType.text,
                          controller: _nameController,
                          onChanged: (val) {
                            ref.read(signUpProvider.notifier).setName(val);
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextFieldWithLabel(
                          title: "전화번호",
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                          autoFormat: true,
                          onChanged: (val) {
                            ref.read(signUpProvider.notifier).setPhone(val);
                          },
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '생년월일',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGray,
                                  ),
                                ),
                                CustomDatePicker(
                                  selectedDate: _selectedDate,
                                  onDateChanged: _onDateSelected,
                                  maximumDate: DateTime.now(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 👇 하단 고정 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: ref.watch(signUpProvider.notifier).canComplete
                        ? () {
                            ref.read(signUpProvider.notifier).completeSignUp(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.violet,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "회원가입 완료",
                      style: AppFonts.titleMedium.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
