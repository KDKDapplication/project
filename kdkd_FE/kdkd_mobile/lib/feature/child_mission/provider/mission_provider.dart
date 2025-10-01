import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/child_mission/repositories/mission_api.dart';
import 'package:kdkd_mobile/feature/parent_mission/models/mission_model.dart';

class MissionNotifier extends StateNotifier<UiState<List<MissionModel>>> {
  final MissionApi api;

  MissionNotifier(this.api) : super(const Idle()) {
    fetchMissions();
  }

  /// 최초 로딩
  Future<void> fetchMissions() async {
    state = const Loading();
    try {
      final data = await api.getMissions();
      state = Success(data);
    } catch (e) {
      print(e);
      state = Failure(e, message: e.toString());
    }
  }

  /// 새로고침 (기존 데이터 유지)
  Future<void> refreshMissions() async {
    final prev = state.dataOrNull ?? [];
    state = Refreshing(prev);
    try {
      final data = await api.getMissions();
      state = Success(data);
    } catch (e) {
      // state = Success(mockMissions);
      state = Failure(e, message: e.toString());
    }
  }
}

/// Provider 등록
final missionProvider = StateNotifierProvider<MissionNotifier, UiState<List<MissionModel>>>((ref) {
  final api = ref.watch(missionApiProvider);
  return MissionNotifier(api);
});
