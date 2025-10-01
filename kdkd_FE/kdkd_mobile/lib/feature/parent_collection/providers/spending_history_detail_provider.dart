// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:kdkd_mobile/common/state/ui_state.dart';
// import 'package:kdkd_mobile/feature/parent_collection/models/spending_history_detail_model.dart';
// import 'package:kdkd_mobile/feature/parent_common/repositories/child_accounts_api.dart';

// class SpendingHistoryDetailController extends StateNotifier<UiState<SpendingHistoryDetailModel>> {
//   final ChildAccountsApi _api;

//   SpendingHistoryDetailController(this._api) : super(const Idle());

//   Future<void> fetchSpendingDetailHistory(String childUuid, String accountItemSeq) async {
//     state = const Loading();

//     try {
//       final data = await _api.getPaymentDetail(childUuid, accountItemSeq);
//       state = Success(data);
//     } catch (e) {
//       state = Failure(e, message: 'Failed to load spending detail history');
//     }
//   }

//   Future<void> refresh(String childUuid, String accountItemSeq) async {
//     await fetchSpendingDetailHistory(childUuid, accountItemSeq);
//   }

//   void reset() {
//     state = const Idle();
//   }
// }

// final spendingHistoryDetailProvider =
//     StateNotifierProvider<SpendingHistoryDetailController, UiState<SpendingHistoryDetailModel>>((ref) {
//   final api = ref.watch(childAccountsApiProvider);
//   return SpendingHistoryDetailController(api);
// });
