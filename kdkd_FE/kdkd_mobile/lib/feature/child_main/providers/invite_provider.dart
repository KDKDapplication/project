import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/child_main/repositories/invite_api.dart';

class InviteNotifier extends StateNotifier<UiState<InviteResponse>> {
  final InviteApi api;

  InviteNotifier(this.api) : super(const Idle());

  /// 초대 코드로 부모와 연결
  Future<void> activateInvite(String code) async {
    state = const Loading();
    try {
      final response = await api.activateInvite(code);
      state = Success(response);
    } catch (e) {
      state = Failure(e, message: e.toString());
    }
  }

  /// 상태 초기화
  void reset() {
    state = const Idle();
  }
}

/// Provider 등록
final inviteProvider = StateNotifierProvider<InviteNotifier, UiState<InviteResponse>>((ref) {
  final api = ref.watch(inviteApiProvider);
  return InviteNotifier(api);
});