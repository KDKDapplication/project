import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/feature/child_main/repositories/auto_transfer_api.dart';

class AutoTransferNotifier extends StateNotifier<AsyncValue<int?>> {
  final AutoTransferApi _api;

  AutoTransferNotifier(this._api) : super(const AsyncValue.loading());

  Future<void> fetchAutoTransfer() async {
    state = const AsyncValue.loading();
    try {
      final amount = await _api.fetchAutoTransfer();
      state = AsyncValue.data(amount);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final autoTransferProvider = StateNotifierProvider<AutoTransferNotifier, AsyncValue<int?>>((ref) {
  final api = ref.watch(autoTransferApiProvider);
  return AutoTransferNotifier(api);
});
