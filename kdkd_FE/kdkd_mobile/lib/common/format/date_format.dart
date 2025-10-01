import 'package:intl/intl.dart';

class DateFormatter {
  static final _dateFormat = DateFormat('M월 d일 HH:mm', 'ko_KR');

  /// 시작일 ~ 종료일 범위
  static String range(DateTime start, DateTime end) {
    return '${_dateFormat.format(start)} ~ ${_dateFormat.format(end)}';
  }

  /// D-Day 계산
  static String dDay(DateTime endDay) {
    final diff = endDay.difference(DateTime.now()).inDays;

    if (diff > 0) {
      return 'D - $diff';
    } else if (diff == 0) {
      return 'D - Day';
    } else {
      return 'D + ${diff.abs()}';
    }
  }

  static String ymd(DateTime date) {
    return DateFormat('yyyy년 MM월 dd일').format(date);
  }
}
