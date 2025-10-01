// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:kdkd_mobile/common/state/ui_state.dart';
// import 'package:kdkd_mobile/feature/parent_collection/models/spending_history_model.dart';
// import 'package:kdkd_mobile/feature/parent_common/providers/selected_child_provider.dart';
// import 'package:kdkd_mobile/feature/parent_common/repositories/child_accounts_api.dart';

// class SpendingHistoryController extends StateNotifier<UiState<List<SpendingHistoryModel>>> {
//   final ChildAccountsApi _api;
//   final Ref _ref;

//   SpendingHistoryController(this._api, this._ref) : super(const Idle()) {
//     _ref.listen(selectedChildProvider, (prev, next) {
//       if (next != null && next.childUuid != prev?.childUuid) {
//         fetchSpendingHistory(next.childUuid);
//       } else if (next == null) {
//         state = const Success([]);
//       }
//     });

//     // 초기 선택된 자녀가 있으면 바로 데이터 로드
//     final initialChild = _ref.read(selectedChildProvider);
//     if (initialChild != null) {
//       fetchSpendingHistory(initialChild.childUuid);
//     }
//   }

//   Future<void> fetchSpendingHistory(String childUuid) async {
//     if (state is! Loading) {
//       state = const Loading();
//     }

//     try {
//       final data = await _api.getSpendingHistory(childUuid);

//       state = Success(data);
//     } catch (e) {
//       state = Failure(e, message: 'Failed to load spending history');
//     }
//   }

//   Future<void> refresh() async {
//     final selectedChild = _ref.read(selectedChildProvider);
//     if (selectedChild != null) {
//       await fetchSpendingHistory(selectedChild.childUuid);
//     }
//   }
// }

// final spendingHistoryProvider =
//     StateNotifierProvider<SpendingHistoryController, UiState<List<SpendingHistoryModel>>>((ref) {
//   final api = ref.watch(childAccountsApiProvider);
//   return SpendingHistoryController(api, ref);
// });
