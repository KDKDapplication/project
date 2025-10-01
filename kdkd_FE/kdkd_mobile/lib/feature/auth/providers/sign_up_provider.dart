import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/auth/models/auth_model.dart';
import 'package:kdkd_mobile/feature/auth/models/sign_up_model.dart';
import 'package:kdkd_mobile/feature/auth/providers/auth_provider.dart';
import 'package:kdkd_mobile/feature/auth/repositories/auth_api.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

final signUpProvider = StateNotifierProvider<SignUpController, SignUpModel>(
  (ref) => SignUpController(ref),
);

class SignUpController extends StateNotifier<SignUpModel> {
  final Ref ref;
  SignUpController(this.ref) : super(const SignUpModel());

  void setUserRole(UserRole role) {
    state = state.copyWith(userRole: role);
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setPhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void setBirthDate(String birthDate) {
    state = state.copyWith(birthDate: birthDate);
  }

  void setProfileImagePath(String? imagePath) {
    state = state.copyWith(profileImagePath: imagePath);
  }

  void reset() {
    state = const SignUpModel();
  }

  bool get canProceedToStep2 => state.userRole != null;
  bool get canComplete {
    final authState = ref.watch(authStateProvider);
    bool hasNewUserAuth = false;
    if (authState is Success<AuthModel>) {
      hasNewUserAuth = authState.data is NewUserAuth;
    }

    return state.name != null &&
           state.phone != null &&
           state.birthDate != null &&
           state.userRole != null &&
           hasNewUserAuth;
  }

  Future<void> completeSignUp(BuildContext context) async {
    if (!canComplete) return;

    try {
      final authApi = ref.read(authApiProvider);
      final NewUserAuth authData = (ref.read(authStateProvider) as Success).data;

      final ExistingUserAuth? result = await authApi.onboard(
        signupToken: authData.signupToken,
        role: state.userRole == UserRole.parent ? 'PARENT' : 'CHILD',
        name: state.name!,
        birthdate: state.birthDate!,
        profileImagePath: state.profileImagePath,
      );

      if (result != null && context.mounted) {
        // 회원가입 성공 시 적절한 페이지로 이동
        if (state.userRole == UserRole.parent) {
          context.go(AppRoutes.parentRoot);
        } else {
          context.go(AppRoutes.childRoot);
        }

        // 상태 초기화
        reset();
      }
    } catch (e) {
      // 에러 처리
      print('회원가입 실패: $e');
    }
  }
}
