import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/parent_common/models/auto_debit_model.dart';
import 'package:kdkd_mobile/feature/parent_common/repositories/auto_debit_api.dart';

final autoDebitListProvider = StateNotifierProvider<AutoDebitListController, UiState<List<AutoDebitInfo>>>(
  (ref) => AutoDebitListController(ref),
);

final autoDebitActionProvider = StateNotifierProvider<AutoDebitActionController, UiState<void>>(
  (ref) => AutoDebitActionController(ref),
);

class AutoDebitListController extends StateNotifier<UiState<List<AutoDebitInfo>>> {
  final Ref ref;

  AutoDebitListController(this.ref) : super(const Idle());

  Future<void> fetchAutoDebitList() async {
    state = const Loading();
    try {
      final api = ref.read(autoDebitApiProvider);
      final autoDebits = await api.getAutoDebitList();
      state = Success(autoDebits);
    } catch (e) {
      state = Failure(e, message: '자동이체 목록을 불러올 수 없습니다');
    }
  }

  Future<void> refresh() async {
    await fetchAutoDebitList();
  }

  void clearList() {
    state = const Idle();
  }
}

class AutoDebitActionController extends StateNotifier<UiState<void>> {
  final Ref ref;

  AutoDebitActionController(this.ref) : super(const Idle());

  Future<void> registerAutoDebit(AutoDebitRegisterRequest request) async {
    state = const Loading();
    try {
      final api = ref.read(autoDebitApiProvider);
      await api.registerAutoDebit(request);
      state = const Success(null);

      // 목록 새로고침
      ref.read(autoDebitListProvider.notifier).fetchAutoDebitList();
    } catch (e) {
      state = Failure(e, message: '자동이체 등록에 실패했습니다');
    }
  }

  Future<void> updateAutoDebit(String childUuid, AutoDebitRegisterRequest request) async {
    state = const Loading();
    try {
      final api = ref.read(autoDebitApiProvider);
      await api.updateAutoDebit(childUuid, request);
      state = const Success(null);

      // 목록 새로고침
      ref.read(autoDebitListProvider.notifier).fetchAutoDebitList();
    } catch (e) {
      state = Failure(e, message: '자동이체 수정에 실패했습니다');
    }
  }

  Future<void> deleteAutoDebit(String childUuid) async {
    state = const Loading();
    try {
      final api = ref.read(autoDebitApiProvider);
      await api.deleteAutoDebit(AutoDebitDeleteRequest(childUuid: childUuid));
      state = const Success(null);

      // 목록 새로고침
      ref.read(autoDebitListProvider.notifier).fetchAutoDebitList();
    } catch (e) {
      state = Failure(e, message: '자동이체 삭제에 실패했습니다');
    }
  }

  void resetState() {
    state = const Idle();
  }
}