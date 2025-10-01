import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/parent_main/models/connection_code_model.dart';
import 'package:kdkd_mobile/feature/parent_main/repositories/connection_code_api.dart';

final connectionCodeProvider = StateNotifierProvider<ConnectionCodeController, UiState<ConnectionCodeModel>>(
  (ref) => ConnectionCodeController(ref),
);

class ConnectionCodeController extends StateNotifier<UiState<ConnectionCodeModel>> {
  final Ref ref;

  ConnectionCodeController(this.ref) : super(const Idle());

  Future<void> generateCode() async {
    state = const Loading();
    try {
      final api = ref.read(connectionCodeApiProvider);
      final codeModel = await api.generateCode();

      if (codeModel != null) {
        state = Success(codeModel);
      } else {
        state = const Failure('연결 코드를 생성할 수 없습니다');
      }
    } catch (e) {
      state = Failure(e);
    }
  }

  void clearCode() {
    state = const Idle();
  }

  ConnectionCodeModel? get code => state.when(
        idle: () => null,
        loading: () => null,
        success: (code, isFallback, fromCache) => code,
        failure: (error, message) => null,
      );

  bool get hasCode => code != null;

  bool get isExpired {
    final codeModel = code;
    if (codeModel == null) return true;
    return DateTime.now().isAfter(codeModel.expiresAt);
  }

  Duration? get remainingTime {
    final codeModel = code;
    if (codeModel == null) return null;

    final now = DateTime.now();
    final expiresAt = codeModel.expiresAt;

    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }
}