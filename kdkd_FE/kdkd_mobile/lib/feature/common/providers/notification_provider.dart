import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/common/models/notification_list_model.dart';
import 'package:kdkd_mobile/feature/common/repositories/notification_api.dart';

final notificationListProvider =
    StateNotifierProvider<NotificationController, UiState<NotificationListResponse>>((ref) {
  return NotificationController(ref);
});

class NotificationController extends StateNotifier<UiState<NotificationListResponse>> {
  final Ref ref;
  int _currentPage = 0;
  static const int _display = 20;

  NotificationController(this.ref) : super(const Idle());

  Future<void> fetchNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 0;
      state = const Loading();
    } else {
      if (state is Loading) return;
      state = const Loading();
    }

    try {
      final api = ref.read(notificationApiProvider);
      final result = await api.getNotificationList(
        pageNum: _currentPage,
        display: _display,
      );

      if (result != null) {
        state = Success(result);
      } else {
        state = const Failure('데이터를 불러올 수 없습니다', message: '데이터를 불러올 수 없습니다');
      }
    } catch (e) {
      state = Failure(e, message: '네트워크 오류가 발생했습니다');
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      final api = ref.read(notificationApiProvider);
      await api.deleteNotificationList();

      // 삭제 후 목록 새로고침
      await fetchNotifications(isRefresh: true);
    } catch (e) {
      state = Failure(e, message: '알림 삭제에 실패했습니다');
    }
  }

  void refresh() {
    state = const Idle();
  }
}
