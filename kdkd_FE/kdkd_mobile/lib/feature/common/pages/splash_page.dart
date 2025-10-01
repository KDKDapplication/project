import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/storage/local_storage_service.dart';
import 'package:kdkd_mobile/feature/auth/models/profile_model.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:kdkd_mobile/feature/auth/repositories/auth_api.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 로컬 스토리지 초기화
      final localStorage = ref.read(localStorageServiceProvider);
      await localStorage.initialize();

      // 스플래시 화면을 최소 2초간 표시
      await Future.delayed(const Duration(seconds: 1));

      // 저장된 토큰 확인
      final accessToken = localStorage.getAccessToken();
      final refreshToken = localStorage.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        // 토큰이 없으면 로그인 페이지로
        if (mounted) {
          context.go(AppRoutes.login);
        }
        return;
      }

      // 토큰 유효성 검증 및 갱신
      final authApi = ref.read(authApiProvider);
      final refreshResult = await authApi.refresh(refreshToken);

      if (refreshResult == null) {
        // 리프레시 실패 시 토큰 삭제하고 로그인 페이지로
        await localStorage.clearTokens();
        if (mounted) {
          context.go(AppRoutes.login);
        }
        return;
      }

      // 사용자 프로필 정보 로드
      final profileNotifier = ref.read(profileProvider.notifier);
      await profileNotifier.loadProfile();

      final profileState = ref.read(profileProvider);

      if (mounted) {
        profileState.when(
          idle: () => context.go(AppRoutes.login),
          loading: () => context.go(AppRoutes.login),
          success: (profile, isFallback, fromCache) {
            // 역할에 따라 적절한 루트 페이지로 이동
            if (profile.r == role.PARENT) {
              context.go(AppRoutes.parentRoot);
            } else {
              context.go(AppRoutes.childRoot);
            }
          },
          failure: (error, message) {
            // 프로필 로드 실패 시 로그인 페이지로
            context.go(AppRoutes.login);
          },
        );
      }
    } catch (e) {
      // 에러 발생 시 로그인 페이지로
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "키득키득",
          style: TextStyle(
            fontFamily: "Chab",
            fontSize: 54,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      backgroundColor: Color(0xFF9B6BFF),
    );
  }
}
