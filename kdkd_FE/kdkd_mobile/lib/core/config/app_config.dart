// lib/core/config/app_config.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  final String baseUrl;
  final bool enableLog;
  const AppConfig({required this.baseUrl, this.enableLog = false});
}

final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('AppConfig must be overridden in main.dart');
});
