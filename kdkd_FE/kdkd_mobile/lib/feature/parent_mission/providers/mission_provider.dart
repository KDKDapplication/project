import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/selected_child_provider.dart';
import 'package:kdkd_mobile/feature/parent_mission/models/mission_model.dart';
import 'package:kdkd_mobile/feature/parent_mission/repositories/mission_api.dart';

class MissionController extends StateNotifier<UiState<List<MissionModel>>> {
  final MissionApi _api;
  final Ref _ref;

  MissionController(this._api, this._ref) : super(const Idle()) {
    _ref.listen(selectedChildProvider, (prev, next) {
      if (next != null && next.childUuid != prev?.childUuid) {
        fetchMissions(next.childUuid);
      } else if (next == null) {
        state = const Success([]);
      }
    });

    // 초기 선택된 자녀가 있으면 바로 데이터 로드
    final initialChild = _ref.read(selectedChildProvider);
    if (initialChild != null) {
      fetchMissions(initialChild.childUuid);
    }
  }

  Future<void> fetchMissions(String childUuid) async {
    if (state is! Loading) {
      state = const Loading();
    }

    try {
      final missions = await _api.getMissionList(childUuid);
      state = Success(missions);
    } catch (e) {
      state = Failure(e, message: 'Failed to load missions');
    }
  }

  Future<void> createMission({
    required String missionName,
    required String missionContent,
    required int reward,
    required DateTime endAt,
  }) async {
    final selectedChild = _ref.read(selectedChildProvider);
    if (selectedChild == null) return;

    try {
      await _api.createMission(
        childUuid: selectedChild.childUuid,
        missionName: missionName,
        missionContent: missionContent,
        reward: reward,
        endAt: endAt,
      );

      // 미션 생성 후 목록 새로고침
      await fetchMissions(selectedChild.childUuid);
    } catch (e) {
      state = Failure(e, message: 'Failed to create mission');
    }
  }

  Future<void> deleteMission(String missionUuid) async {
    final selectedChild = _ref.read(selectedChildProvider);
    if (selectedChild == null) return;

    try {
      await _api.deleteMission(missionUuid: missionUuid);

      // 미션 삭제 후 목록 새로고침
      await fetchMissions(selectedChild.childUuid);
    } catch (e) {
      state = Failure(e, message: 'Failed to delete mission');
    }
  }

  Future<void> successMission(String missionUuid) async {
    final selectedChild = _ref.read(selectedChildProvider);
    if (selectedChild == null) return;

    try {
      await _api.successMission(missionUuid: missionUuid);

      // 미션 삭제 후 목록 새로고침
      await fetchMissions(selectedChild.childUuid);
    } catch (e) {
      state = Failure(e, message: 'Failed to delete mission');
    }
  }

  Future<void> refresh() async {
    final selectedChild = _ref.read(selectedChildProvider);
    if (selectedChild != null) {
      await fetchMissions(selectedChild.childUuid);
    }
  }
}

final missionProvider = StateNotifierProvider<MissionController, UiState<List<MissionModel>>>((ref) {
  final api = ref.watch(missionApiProvider);
  return MissionController(api, ref);
});
