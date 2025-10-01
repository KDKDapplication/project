import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:kdkd_mobile/feature/auth/repositories/auth_api.dart';

class KakaoLogin implements ISocialLogin {
  @override
  Future<String?> login() async {
    // 기기에 저장된 토큰이 있는지 확인
    if (await kakao.AuthApi.instance.hasToken()) {
      try {
        // 토큰 유효성 검증
        kakao.AccessTokenInfo tokenInfo =
            await kakao.UserApi.instance.accessTokenInfo();
        print('카카오 토큰 유효성 체크 성공: ${tokenInfo.id}');

        // 유효하다면 기존 토큰 반환
        kakao.OAuthToken? token =
            await kakao.TokenManagerProvider.instance.manager.getToken();
        return token?.accessToken;
      } catch (error) {
        if (error is kakao.KakaoException && error.isInvalidTokenError()) {
          print('카카오 토큰 만료: $error');
        } else {
          print('카카오 액세스 토큰 정보 조회 실패: $error');
        }
        // 토큰이 유효하지 않은 경우, 새로운 로그인 시도
        return await _performNewLogin();
      }
    } else {
      // 발급된 토큰이 없는 경우, 새로운 로그인 시도
      print('발급된 카카오 토큰 없음');
      return await _performNewLogin();
    }
  }

  // 신규 로그인 로직
  Future<String?> _performNewLogin() async {
    // 카카오톡 설치 여부 확인
    if (await kakao.isKakaoTalkInstalled()) {
      // 카카오톡으로 로그인 시도
      try {
        kakao.OAuthToken token =
            await kakao.UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공: ${token.accessToken}');
        return token.accessToken;
      } catch (error) {
        print('카카오톡으로 로그인 실패: $error');
        // 사용자가 로그인 취소 등 예외 처리
        if (error is PlatformException && error.code == 'CANCELED') {
          return null;
        }
      }
    }
    // 카카오계정으로 로그인 시도 (카톡 미설치 또는 카톡 로그인 실패 시)
    try {
      kakao.OAuthToken token =
          await kakao.UserApi.instance.loginWithKakaoAccount();
      print('카카오계정으로 로그인 성공: ${token.accessToken}');
      return token.accessToken;
    } catch (error) {
      print('카카오계정으로 로그인 실패: $error');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await kakao.UserApi.instance.logout();
      print('카카오 로그아웃 성공');
    } catch (e) {
      print('카카오 로그아웃 실패 $e');
    }
  }
}
