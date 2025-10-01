import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/feature/parent_common/repositories/auto_debit_api.dart';

class TotalAutoDebitNotifier extends StateNotifier<int?> {
  final AutoDebitApi _autoDebitApi;

  TotalAutoDebitNotifier(this._autoDebitApi) : super(null);

  Future<void> loadTotalAutoDebit() async {
    try {
      final amount = await _autoDebitApi.getTotalAutoDebitAmount();
      state = amount;
    } catch (error) {
      state = null;
    }
  }

  Future<void> refresh() async {
    await loadTotalAutoDebit();
  }
}

/// 총 자동이체 금액 Provider
final totalAutoDebitProvider = StateNotifierProvider<TotalAutoDebitNotifier, int?>((ref) {
  final autoDebitApi = ref.watch(autoDebitApiProvider);
  return TotalAutoDebitNotifier(autoDebitApi);
});
