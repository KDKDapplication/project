import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/parent_collection/models/spending_pattern_model.dart';

class SpendingPattern {
  final Dio dio;

  SpendingPattern(this.dio);

  /// 자녀 소비 패턴 조회
  Future<SpendingPatternModel?> getPattern({required String childUuid, required String yearMonth}) async {
    try {
      final response = await dio.get(
        '/parents/$childUuid/pattern',
        queryParameters: {
          "yearMonth": yearMonth,
        },
      );

      final data = Map<String, dynamic>.from(response.data);

      return SpendingPatternModel.fromMap(data);
    } catch (e) {
      print('자녀 소비 패턴 조회 에러: $e');

      return null;
    }
  }

  /// 자녀 소비 내역 AI 피드백 조회
  Future<String?> getAiFeedback({required String childUuid}) async {
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1);
    final yearMonth = "${prevMonth.year}-${prevMonth.month.toString().padLeft(2, '0')}";

    try {
      final response = await dio.get(
        '/api/ai/$childUuid/feedback',
        queryParameters: {
          "yearMonth": yearMonth,
        },
      );

      print('123 : ${response.data}');
      return response.data;
    } catch (e) {
      print('자녀 소비 내역 AI 피드백 조회 에러: $e');
      return '소비 내역 AI 피드백 조회 실패';
    }
  }
}

final spendingPatternProvider = Provider<SpendingPattern>((ref) {
  final dio = ref.watch(dioProvider);
  return SpendingPattern(dio);
});
