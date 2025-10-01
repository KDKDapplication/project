import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';

import '../models/transaction_history.dart';
import '../repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TransactionRepository(dio);
});

class TransactionHistoryNotifier extends StateNotifier<UiState<TransactionHistory>> {
  final TransactionRepository _repository;

  TransactionHistoryNotifier(this._repository) : super(const Idle());

  Future<void> fetchTransactionHistory({
    String? accountNumber,
    String? startDate,
    String? endDate,
    int? page,
    int? size,
  }) async {
    state = const Loading();
    try {
      final transactionHistory = await _repository.fetchTransactionHistory(
        accountNumber: accountNumber,
        startDate: startDate,
        endDate: endDate,
        page: page,
        size: size,
      );
      state = Success(transactionHistory);
    } catch (e) {
      state = Failure(e);
    }
  }

  void clearHistory() {
    state = const Idle();
  }
}

final transactionHistoryProvider =
    StateNotifierProvider<TransactionHistoryNotifier, UiState<TransactionHistory>>(
  (ref) => TransactionHistoryNotifier(ref.watch(transactionRepositoryProvider)),
);