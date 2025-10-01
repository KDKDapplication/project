import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/feature/auth/repositories/auth_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  late SharedPreferences _prefs;
  bool _initialized = false;

  // 저장 키 상수들
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _lastLoginProviderKey = 'last_login_provider';

  /// SharedPreferences 초기화
  Future<void> initialize() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  /// 초기화 확인
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('LocalStorageService가 초기화되지 않았습니다. initialize()를 먼저 호출하세요.');
    }
  }

  // ============= 토큰 관리 =============

  /// 액세스 토큰과 리프레시 토큰 저장
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    _ensureInitialized();
    await Future.wait([
      _prefs.setString(_accessTokenKey, accessToken),
      _prefs.setString(_refreshTokenKey, refreshToken),
    ]);
  }

  /// 액세스 토큰 저장
  Future<void> saveAccessToken(String accessToken) async {
    _ensureInitialized();
    await _prefs.setString(_accessTokenKey, accessToken);
  }

  /// 리프레시 토큰 저장
  Future<void> saveRefreshToken(String refreshToken) async {
    _ensureInitialized();
    await _prefs.setString(_refreshTokenKey, refreshToken);
  }

  /// 액세스 토큰 가져오기
  String? getAccessToken() {
    _ensureInitialized();
    return _prefs.getString(_accessTokenKey);
  }

  /// 리프레시 토큰 가져오기
  String? getRefreshToken() {
    _ensureInitialized();
    return _prefs.getString(_refreshTokenKey);
  }

  /// 모든 토큰 삭제
  Future<void> clearTokens() async {
    _ensureInitialized();
    await Future.wait([
      _prefs.remove(_accessTokenKey),
      _prefs.remove(_refreshTokenKey),
    ]);
  }

  /// 토큰 존재 여부 확인
  bool hasTokens() {
    _ensureInitialized();
    final accessToken = _prefs.getString(_accessTokenKey);
    final refreshToken = _prefs.getString(_refreshTokenKey);
    return accessToken != null && refreshToken != null;
  }

  // ============= 소셜 로그인 Provider 관리 =============

  /// 마지막 로그인 provider 저장
  Future<void> saveLastLoginProvider(SocialType provider) async {
    _ensureInitialized();
    await _prefs.setString(_lastLoginProviderKey, provider.name);
  }

  /// 저장된 마지막 로그인 provider 가져오기
  SocialType? getLastLoginProvider() {
    _ensureInitialized();
    final providerName = _prefs.getString(_lastLoginProviderKey);
    if (providerName == null) return null;

    try {
      return SocialType.values.firstWhere(
        (e) => e.name == providerName,
      );
    } catch (e) {
      return null;
    }
  }

  /// 마지막 로그인 provider 정보 삭제
  Future<void> clearLastLoginProvider() async {
    _ensureInitialized();
    await _prefs.remove(_lastLoginProviderKey);
  }

  // ============= 전체 데이터 관리 =============

  /// 모든 저장된 데이터 삭제 (로그아웃 시 사용)
  Future<void> clearAll() async {
    _ensureInitialized();
    await Future.wait([
      clearTokens(),
      clearLastLoginProvider(),
    ]);
  }

  /// 저장된 데이터 존재 여부 확인
  bool hasUserData() {
    _ensureInitialized();
    return hasTokens() || getLastLoginProvider() != null;
  }
}

// Provider 등록
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});
