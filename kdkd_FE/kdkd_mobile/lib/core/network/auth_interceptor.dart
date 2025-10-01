import 'package:dio/dio.dart';

typedef AccessTokenLoader = Future<String?> Function();

class AuthInterceptor extends Interceptor {
  final AccessTokenLoader loadAccessToken;
  AuthInterceptor({required this.loadAccessToken});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 인증이 필요 없는 엔드포인트들
    final authNotRequiredPaths = [
      '/auth/login/google',
      '/auth/login/kakao',
      '/auth/refresh',
      '/auth/onboard',
    ];

    final shouldSkipAuth = authNotRequiredPaths.any(
      (path) => options.path.contains(path),
    );

    if (!shouldSkipAuth) {
      final token = await loadAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    super.onRequest(options, handler);
  }
}
