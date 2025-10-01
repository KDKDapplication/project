import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/config/app_config.dart';
import 'package:kdkd_mobile/core/storage/local_storage_service.dart';

import 'auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final cfg = ref.watch(appConfigProvider);
  final localStorage = ref.watch(localStorageServiceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: cfg.baseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      loadAccessToken: () async {
        await localStorage.initialize();
        return localStorage.getAccessToken();
      },
    ),
  );

  if (cfg.enableLog) {
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
  return dio;
});
