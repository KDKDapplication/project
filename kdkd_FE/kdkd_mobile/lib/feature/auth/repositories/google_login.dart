import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kdkd_mobile/feature/auth/models/auth_model.dart';
import 'package:kdkd_mobile/feature/auth/repositories/auth_api.dart';

class GoogleLogin implements ISocialLogin {
  GoogleLogin(this._api, {GoogleSignIn? googleSignIn}) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final GoogleSignIn _googleSignIn;
  final AuthApi _api; // ← 서버 호출용
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _googleSignIn.initialize(
      serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID']!,
    );

    // 인증 이벤트 로그(선택)
    _googleSignIn.authenticationEvents.listen(
      (event) => debugPrint("AuthEvent: $event"),
      onError: (err) => debugPrint("AuthEvent Error: $err"),
    );

    _initialized = true;
  }

  @override
  Future<String?> login() async {
    try {
      if (!_initialized) {
        await init();
      }

      // 기존 세션 정리 (disconnect만 호출하면 signOut도 자동으로 됨)
      await _googleSignIn.disconnect().catchError((_) {});

      final account = await _googleSignIn.authenticate();

      final auth = account.authentication;
      final idToken = auth.idToken;

      debugPrint("Google ID Token prefix: ${idToken?.substring(0, 20)}");
      return idToken; // 서버로 전달
    } catch (e, st) {
      debugPrint("Google Login Error: $e\n$st");
      return null;
    }
  }

  /// 서버까지 교환해서 결과(로그인 성공 or 온보딩 필요)를 반환
  Future<AuthModel?> loginAndExchange() async {
    final result = await _api.login(SocialType.google);
    return result; // AuthModel 또는 null
  }

  @override
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint("Google Logout Error: $e");
    }
  }
}
