import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 자녀 탭 인덱스 상태 관리
final childTabProvider = StateProvider<int>((ref) => 0);

/// 자녀 탭 변경 함수들
class ChildTabNotifier {
  static void navigateToHome(WidgetRef ref) {
    ref.read(childTabProvider.notifier).state = 0;
  }

  static void navigateToCollection(WidgetRef ref) {
    ref.read(childTabProvider.notifier).state = 1;
  }

  static void navigateToMission(WidgetRef ref) {
    ref.read(childTabProvider.notifier).state = 3; // 미션은 3번 인덱스
  }

  static void navigateToProfile(WidgetRef ref) {
    ref.read(childTabProvider.notifier).state = 4; // 프로필은 4번 인덱스
  }
}