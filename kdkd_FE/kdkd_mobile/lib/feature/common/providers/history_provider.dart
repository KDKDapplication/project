import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/common/models/history_model.dart';
import 'package:kdkd_mobile/feature/common/repositories/history_api.dart';

class HistoryNotifier extends StateNotifier<UiState<HistoryModel>> {
  final HistoryApi _api;

  HistoryNotifier(this._api) : super(const Idle());

  Future<void> getConsumptions({
    required String month,
    String? day,
    SourceType sourceType = SourceType.ALL,
  }) async {
    state = const Loading();
    try {
      final result = await _api.getConsumptions(
        month: month,
        day: day,
        sourceType: sourceType,
      );

      // 최신순으로 정렬
      final sortedList = result.list
        ..sort((a, b) {
          final dateA = DateTime.parse('${a.date} ${a.time}');
          final dateB = DateTime.parse('${b.date} ${b.time}');
          return dateB.compareTo(dateA); // 최신순 (내림차순)
        });

      final sortedResult = HistoryModel(
        totalCount: result.totalCount,
        list: sortedList,
      );

      state = Success(sortedResult);
    } catch (e) {
      state = Failure(e, message: 'Failed to load consumption history');
    }
  }

  Future<void> refreshConsumptions({
    required String month,
    String? day,
    SourceType sourceType = SourceType.ALL,
  }) async {
    if (state is Success<HistoryModel>) {
      state = Refreshing((state as Success<HistoryModel>).data);
    }

    try {
      final result = await _api.getConsumptions(
        month: month,
        day: day,
        sourceType: sourceType,
      );

      // 최신순으로 정렬
      final sortedList = result.list
        ..sort((a, b) {
          final dateA = DateTime.parse('${a.date} ${a.time}');
          final dateB = DateTime.parse('${b.date} ${b.time}');
          return dateB.compareTo(dateA); // 최신순 (내림차순)
        });

      final sortedResult = HistoryModel(
        totalCount: result.totalCount,
        list: sortedList,
      );

      state = Success(sortedResult);
    } catch (e) {
      state = Failure(e, message: 'Failed to refresh consumption history');
    }
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, UiState<HistoryModel>>((ref) {
  final api = ref.watch(historyApiProvider);
  return HistoryNotifier(api);
});
