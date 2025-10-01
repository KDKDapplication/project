import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/auth/models/auth_model.dart';
import 'package:kdkd_mobile/feature/auth/models/profile_model.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:kdkd_mobile/feature/auth/providers/sign_up_provider.dart';
import 'package:kdkd_mobile/feature/auth/repositories/auth_api.dart';
import 'package:kdkd_mobile/feature/common/repositories/fcm_api.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

final authStateProvider = StateNotifierProvider<AuthController, UiState<AuthModel>>(
  (ref) => AuthController(ref),
);

class AuthController extends StateNotifier<UiState<AuthModel>> {
  final Ref ref;
  AuthController(this.ref) : super(const Idle());

  Future<void> login(SocialType provider, BuildContext context) async {
    try {
      // 로딩 상태를 나중에 설정하여 UI 응답성 향상
      final repo = ref.read(authApiProvider);

      // 구글 로그인 창을 먼저 띄우고 나서 로딩 상태 설정
      final token = await repo.login(provider);

      // 로그인 창이 뜬 후에 로딩 상태 설정
      state = const Loading();

      if (token == null) {
        state = const Failure('로그인 실패 또는 취소');
      } else {
        state = Success(token);

        // FCM 등록을 비동기로 처리하여 UI 블로킹 방지
        final fcm = ref.read(fcmApiProvider);
        fcm.registerFcm().catchError((e) {
          print('FCM 등록 실패: $e');
        });

        if (token is ExistingUserAuth) {
          // 기존 유저 → 프로필 정보를 가져와서 부모/자녀 확인 후 라우팅
          await _loadProfileAndRoute(context);
        } else if (token is NewUserAuth) {
          // 신규 유저 → 회원가입 첫 단계로
          if (context.mounted) {
            context.go(AppRoutes.signUpStep1);
          }
        }
      }
    } catch (e) {
      state = Failure(e);
    }
  }

  Future<void> signOut() async {
    await ref.read(authApiProvider).logout();
    ref.read(profileProvider.notifier).clearProfile();
    state = const Idle();
  }

  Future<void> _loadProfileAndRoute(BuildContext context) async {
    try {
      // 프로필 정보 로드
      await ref.read(profileProvider.notifier).loadProfile();

      final profileState = ref.read(profileProvider);

      print('loadprofileandroute : $profileState');

      profileState.when(
        idle: () {},
        loading: () {},
        success: (profile, isFallback, fromCache) {
          if (context.mounted) {
            if (profile.r == role.PARENT) {
              context.go(AppRoutes.parentRoot);
            } else {
              context.go(AppRoutes.childRoot);
            }
          }
        },
        failure: (error, message) {
          if (context.mounted) {
            context.go(AppRoutes.test);
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        context.go(AppRoutes.test);
      }
    }
  }

  void completeSignUp(ExistingUserAuth newState) {
    state = Success(newState);
  }
}
