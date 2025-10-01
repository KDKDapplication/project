import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/parent_collection/models/spending_pattern_model.dart';
import 'package:kdkd_mobile/feature/parent_collection/repositories/spending_pattern_api.dart';

final spendingPatternDataProvider =
    StateNotifierProvider<SpendingPatternController, UiState<SpendingPatternModel>>((ref) {
  return SpendingPatternController(ref);
});

final aiFeedbackProvider = StateNotifierProvider<AiFeedbackController, UiState<String>>((ref) {
  return AiFeedbackController(ref);
});

class SpendingPatternController extends StateNotifier<UiState<SpendingPatternModel>> {
  final Ref ref;

  SpendingPatternController(this.ref) : super(const Idle());

  Future<void> fetchSpendingPattern(String childUuid, String yearMonth) async {
    state = const Loading();
    try {
      final api = ref.read(spendingPatternProvider);
      final result = await api.getPattern(childUuid: childUuid, yearMonth: yearMonth);

      if (result != null) {
        state = Success(result);
      } else {
        state = const Failure('데이터를 불러올 수 없습니다', message: '데이터를 불러올 수 없습니다');
      }
    } catch (e) {
      state = Failure(e, message: '네트워크 오류가 발생했습니다');
    }
  }

  void refresh() {
    state = const Idle();
  }
}

class AiFeedbackController extends StateNotifier<UiState<String>> {
  final Ref ref;

  AiFeedbackController(this.ref) : super(const Idle());

  Future<void> fetchAiFeedback(String childUuid) async {
    state = const Loading();
    try {
      final api = ref.read(spendingPatternProvider);
      final result = await api.getAiFeedback(childUuid: childUuid);

      if (result != null) {
        state = Success(result);
      } else {
        state = const Failure('피드백을 불러올 수 없습니다', message: '피드백을 불러올 수 없습니다');
      }
    } catch (e) {
      state = Failure(e, message: '네트워크 오류가 발생했습니다');
    }
  }

  void refresh() {
    state = const Idle();
  }
}
