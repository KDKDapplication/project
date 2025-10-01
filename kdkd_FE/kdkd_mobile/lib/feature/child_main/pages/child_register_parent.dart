import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/button/custom_button_Large.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/common/text_field/custom_text_field_with_label.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:kdkd_mobile/feature/child_main/providers/invite_provider.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

class ChildRegisterParent extends ConsumerStatefulWidget {
  const ChildRegisterParent({super.key});

  @override
  ConsumerState<ChildRegisterParent> createState() => _ChildRegisterParentState();
}

class _ChildRegisterParentState extends ConsumerState<ChildRegisterParent> {
  final TextEditingController _codeController = TextEditingController();
  String _code = '';

  @override
  void initState() {
    super.initState();
    // 페이지 진입 시 상태 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inviteProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    setState(() {
      _code = value;
    });
  }

  void _connectWithParent() {
    if (_code.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 코드를 입력해주세요.')),
      );
      return;
    }

    ref.read(inviteProvider.notifier).activateInvite(_code.trim());
  }

  @override
  Widget build(BuildContext context) {
    final inviteState = ref.watch(inviteProvider);

    // 연결 성공 시 프로필 다시 로드하고 자녀 메인으로 이동
    ref.listen<UiState>(inviteProvider, (previous, next) {
      next.when(
        idle: () {},
        loading: () {},
        success: (data, isFallback, fromCache) {
          // 성공 시 프로필 다시 로드
          ref.read(profileProvider.notifier).loadProfile();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('부모님과 성공적으로 연결되었습니다!')),
          );

          // 자녀 메인 페이지로 이동
          context.go(AppRoutes.childRoot);
        },
        failure: (error, message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('연결에 실패했습니다: $message')),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.grayBG,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '부모님 연결',
          style: AppFonts.titleMedium.copyWith(color: AppColors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - kToolbarHeight - 48.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // 안내 텍스트
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.family_restroom,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '부모님과 연결하기',
                      style: AppFonts.headlineMedium.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '부모님이 생성해 주신\n초대 코드를 입력해주세요',
                      style: AppFonts.bodyLarge.copyWith(
                        color: AppColors.grayMedium,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // 코드 입력 필드
              CustomTextFieldWithLabel(
                title: '초대 코드',
                controller: _codeController,
                onChanged: _onCodeChanged,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 8),
              Text(
                '부모님께서 생성한 6자리 코드를 입력하세요',
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.grayMedium,
                ),
              ),

              const SizedBox(height: 80),

              // 연결 버튼
              Center(
                child: CustomButtonLarge(
                  text: '부모님과 연결하기',
                  onPressed: inviteState.when(
                    idle: () => _connectWithParent,
                    loading: () => null,
                    success: (data, isFallback, fromCache) => _connectWithParent,
                    failure: (error, message) => _connectWithParent,
                  ),
                  color: _code.trim().isNotEmpty ? AppColors.primary : AppColors.grayLight,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
