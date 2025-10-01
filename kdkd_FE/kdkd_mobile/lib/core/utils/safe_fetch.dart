// lib/common/utils/safe_fetch.dart
import 'dart:convert';

import 'package:kdkd_mobile/core/network/error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'result.dart';

typedef RemoteCall<T> = Future<T> Function();
typedef ToJson<T> = Object Function(T value);
typedef FromJson<T> = T Function(Object json);

class SafeFetch {
  static Future<Result<T>> run<T>({
    required String cacheKey,
    required RemoteCall<T> remote,
    required ToJson<T> toJson,
    required FromJson<T> fromJson,
    required T Function() fallback,
  }) async {
    try {
      final data = await remote();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, jsonEncode(toJson(data)));
      return Result<T>(data);
    } catch (e) {
      final _ = mapDioError(e);
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(cacheKey);
      if (raw != null) {
        return Result<T>(
          fromJson(jsonDecode(raw)),
          isFallback: true,
          fromCache: true,
        );
      }
      return Result<T>(fallback(), isFallback: true, fromCache: false);
    }
  }
}
