import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/core/storage/local_storage_service.dart';
import 'package:kdkd_mobile/feature/auth/models/auth_model.dart';
import 'package:kdkd_mobile/feature/auth/repositories/google_login.dart';
import 'package:path/path.dart' as p;

/// 소셜 로그인 공통 인터페이스
abstract class ISocialLogin {
  /// 소셜 로그인 시도 후 idToken 반환 (실패/취소 시 null)
  Future<String?> login();

  /// 소셜 로그아웃
  Future<void> logout();
}

/// 지원하는 소셜 로그인 타입
enum SocialType { google }

/// 인증 API 클래스
///
/// 소셜 로그인(Google, Kakao), 로그아웃, 토큰 갱신 등의 인증 관련 기능을 담당
class AuthApi {
  final Dio dio;
  final LocalStorageService _localStorage;

  /// 소셜 로그인 전략들
  late final Map<SocialType, ISocialLogin> _socialLogins;

  /// 마지막으로 로그인한 provider (로그아웃 시 정확한 provider로 로그아웃하기 위함)
  SocialType? _lastLoginProvider;

  AuthApi(this.dio, this._localStorage) {
    _socialLogins = {
      SocialType.google: GoogleLogin(this),
    };
    _initializeLastLoginProvider();
  }

  /// 저장된 마지막 로그인 provider 초기화
  Future<void> _initializeLastLoginProvider() async {
    await _localStorage.initialize();
    _lastLoginProvider = _localStorage.getLastLoginProvider();
  }

  /// 서버 응답을 적절한 AuthModel 타입으로 파싱
  AuthModel _parseAuthResponse(Map<String, dynamic> data) {
    // 기존 회원인지 신규 회원인지 판단
    if (data.containsKey('accessToken') && data.containsKey('refreshToken')) {
      // 기존 회원: accessToken, refreshToken이 있음
      return ExistingUserAuth.fromJson(data);
    } else if (data.containsKey('signupToken') && data.containsKey('onboardingRequired')) {
      // 신규 회원: signupToken, onboardingRequired가 있음
      return NewUserAuth.fromJson(data);
    } else {
      throw Exception('알 수 없는 인증 응답 형식: $data');
    }
  }

  /// 소셜 로그인 수행
  ///
  /// 1. 소셜 로그인으로 idToken 획득
  /// 2. 서버에 idToken 전달하여 JWT 토큰 발급
  /// 3. 토큰과 provider 정보 로컬에 저장
  ///
  /// [provider] 로그인할 소셜 provider (google, kakao)
  ///
  /// Returns [AuthModel] 로그인 성공 시, [null] 실패/취소 시
  Future<AuthModel?> login(SocialType provider) async {
    try {
      final socialLoginStrategy = _socialLogins[provider];
      if (socialLoginStrategy == null) {
        throw Exception('지원하지 않는 소셜 로그인: $provider');
      }

      // 1. 소셜 로그인 후 idToken 획득
      final idToken = await socialLoginStrategy.login();
      if (idToken == null) {
        return null; // 로그인 실패 또는 사용자 취소
      }

      // 2. 서버에 idToken 전달 → JWT 발급 요청
      final res = await dio.post(
        '/auth/login/${provider.name.toLowerCase()}',
        data: {'idToken': idToken},
      );

      final authData = _parseAuthResponse(Map<String, dynamic>.from(res.data));

      // 3. 로그인 성공 시 정보 저장
      _lastLoginProvider = provider;
      await _localStorage.saveLastLoginProvider(provider);

      // 4. 토큰 저장 (기존 회원인 경우만)
      if (authData is ExistingUserAuth) {
        await _localStorage.saveTokens(authData.accessToken, authData.refreshToken);
      }

      return authData;
    } catch (e) {
      print(e);
      // API 실패 시 소셜 세션 정리
      await _socialLogins[provider]?.logout();
      return null;
    }
  }

  /// 완전 로그아웃 수행
  ///
  /// 1. 소셜 로그인 세션 해제
  /// 2. 로컬 스토리지 데이터 삭제 (토큰, provider 정보 등)
  /// 3. 백엔드 로그아웃 요청
  Future<void> logout() async {
    try {
      // 1. 구글 로그인 세션 해제 (구글만 사용)
      await _socialLogins[SocialType.google]?.logout();
      _lastLoginProvider = null;

      // 2. 로컬 스토리지의 모든 데이터 삭제
      await _localStorage.clearAll();

      // 3. 백엔드 로그아웃 요청
      await dio.post('/auth/logout');
    } catch (e) {
      // 로그아웃 과정에서 오류가 발생해도 로컬 데이터는 삭제됨
    }
  }

  /// 토큰 재발급
  ///
  /// 리프레시 토큰을 사용하여 새로운 액세스 토큰을 발급받고 저장
  ///
  /// [refreshToken] 기존 리프레시 토큰
  ///
  /// Returns [AuthModel] 갱신된 토큰 정보
  Future<AuthModel?> refresh(String refreshToken) async {
    try {
      final res = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final authData = _parseAuthResponse(Map<String, dynamic>.from(res.data));

      // 새로운 토큰 자동 저장
      if (authData is ExistingUserAuth) {
        await _localStorage.saveTokens(authData.accessToken, authData.refreshToken);
      }

      return authData;
    } catch (e) {
      return null;
    }
  }

  Future<ExistingUserAuth?> onboard({
    required String signupToken,
    required String role,
    required String name,
    required String birthdate,
    String? profileImagePath,
  }) async {
    try {
      // JSON 파트를 위한 바이트 데이터
      final jsonBytes = utf8.encode(
        jsonEncode({
          'signupToken': signupToken,
          'role': role,
          'name': name,
          'birthdate': birthdate,
        }),
      );

      // FormData 생성
      final formData = FormData.fromMap({
        'payload': MultipartFile.fromBytes(
          jsonBytes,
          filename: 'request.json',
          contentType: MediaType('application', 'json'),
        ),
      });

      // 프로필 이미지가 있으면 추가
      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'profile',
            await MultipartFile.fromFile(
              profileImagePath,
              filename: p.basename(profileImagePath),
              contentType: MediaType('image', 'jpeg'),
            ),
          ),
        );
      }

      final res = await dio.post(
        "/auth/onboard",
        data: formData,
      );

      final authData = _parseAuthResponse(Map<String, dynamic>.from(res.data));

      if (authData is ExistingUserAuth) {
        await _localStorage.saveTokens(authData.accessToken, authData.refreshToken);
        return authData;
      }
    } catch (e, s) {
      print("Onboard error: $e");
      print(s);
      return null;
    }
    return null;
  }
}

// Provider 등록
final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  return AuthApi(dio, localStorage);
});
