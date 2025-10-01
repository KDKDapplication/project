import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/parent_common/models/auto_debit_model.dart';

/// 자동이체 관련 API 클래스
class AutoDebitApi {
  final Dio _dio;

  AutoDebitApi(this._dio);

  /// 자녀에게 주는 모든 용돈 조회
  Future<int?> getTotalAutoDebitAmount() async {
    try {
      final res = await _dio.get(
        '/parents/auto-transfer',
      );

      return res.data['totalAmount'];
    } catch (e) {
      return null;
    }
  }

  /// 자녀 자동이체 규칙 등록
  Future<void> registerAutoDebit(AutoDebitRegisterRequest request) async {
    try {
      await _dio.post(
        '/accounts/auto-transfer/register',
        data: request.toJson(),
      );
    } catch (e) {
      print(e);
      throw Exception('자동이체 등록 실패: $e');
    }
  }

  /// 부모 자동이체 목록 조회
  Future<List<AutoDebitInfo>> getAutoDebitList() async {
    try {
      final response = await _dio.get('/accounts/auto-transfer/list');

      final data = response.data;
      if (data is List) {
        return data.map((item) => AutoDebitInfo.fromJson(item as Map<String, dynamic>)).toList();
      } else if (data is Map<String, dynamic>) {
        final list = data['auto-transfers'] ?? data['autoDebits'] ?? data['data'] ?? [];
        return (list as List).map((item) => AutoDebitInfo.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('자동이체 목록 조회 실패: $e');
    }
  }

  /// 자동이체 규칙 삭제
  Future<void> deleteAutoDebit(AutoDebitDeleteRequest request) async {
    try {
      await _dio.delete(
        '/accounts/auto-transfer/delete',
        data: request.toJson(),
      );
    } catch (e) {
      throw Exception('자동이체 삭제 실패: $e');
    }
  }

  /// 자동이체 규칙 수정
  Future<void> updateAutoDebit(String childUuid, AutoDebitRegisterRequest newRequest) async {
    try {
      await _dio.patch(
        '/accounts/auto-transfer/modify',
        data: newRequest.toJson(),
      );
    } catch (e) {
      throw Exception('자동이체 수정 실패: $e');
    }
  }
}

/// AutoDebitApi Provider
final autoDebitApiProvider = Provider<AutoDebitApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AutoDebitApi(dio);
});

/// 자동이체 관련 유틸리티 함수들
class AutoDebitUtils {
  /// 날짜 유효성 검사 (1~31일)
  static bool isValidDate(int date) {
    return date >= 1 && date <= 31;
  }

  /// 시간 유효성 검사 (0~23시)
  static bool isValidHour(String hour) {
    final hourInt = int.tryParse(hour);
    return hourInt != null && hourInt >= 0 && hourInt <= 23;
  }

  /// 금액 유효성 검사 (양수)
  static bool isValidAmount(int amount) {
    return amount > 0;
  }

  /// 자동이체 요청 유효성 검사
  static bool isValidRequest(AutoDebitRegisterRequest request) {
    return isValidDate(request.date) &&
        isValidHour(request.hour) &&
        isValidAmount(request.amount) &&
        request.childUuid.isNotEmpty;
  }

  /// 시간 문자열을 12시간 형식으로 변환
  static String formatHour(String hour) {
    int hourInt;
    if (hour.contains(':')) {
      // "HH:mm:ss" 형식
      hourInt = int.tryParse(hour.split(':')[0]) ?? 0;
    } else {
      // 숫자만 있는 형식
      hourInt = int.tryParse(hour) ?? 0;
    }

    if (hourInt == 0) return '오전 12시';
    if (hourInt < 12) return '오전 $hourInt시';
    if (hourInt == 12) return '오후 12시';
    return '오후 ${hourInt - 12}시';
  }

  /// 금액을 천 단위 구분자로 포맷팅
  static String formatAmount(int amount) {
    return '${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}원';
  }

  /// 시간을 HH:mm:ss 형식으로 변환
  static String formatTimeToApi(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00:00';
  }

  /// 다음 자동이체 실행 예정일 계산
  static DateTime getNextExecutionDate(int date, String hour) {
    final now = DateTime.now();
    int hourInt;
    if (hour.contains(':')) {
      // "HH:mm:ss" 형식
      hourInt = int.tryParse(hour.split(':')[0]) ?? 0;
    } else {
      // 숫자만 있는 형식
      hourInt = int.tryParse(hour) ?? 0;
    }

    var nextDate = DateTime(now.year, now.month, date, hourInt);

    // 이번 달 해당 날짜가 이미 지났으면 다음 달로
    if (nextDate.isBefore(now)) {
      nextDate = DateTime(now.year, now.month + 1, date, hourInt);
    }

    // 다음 달에 해당 날짜가 없으면 마지막 날로 조정
    final lastDayOfMonth = DateTime(nextDate.year, nextDate.month + 1, 0).day;
    if (date > lastDayOfMonth) {
      nextDate = DateTime(nextDate.year, nextDate.month, lastDayOfMonth, hourInt);
    }

    return nextDate;
  }

  /// 자동이체 실행까지 남은 시간 텍스트
  static String getTimeUntilNextExecution(int date, String hour) {
    final nextDate = getNextExecutionDate(date, hour);
    final now = DateTime.now();
    final difference = nextDate.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 후';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 후';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 후';
    } else {
      return '곧 실행';
    }
  }
}
