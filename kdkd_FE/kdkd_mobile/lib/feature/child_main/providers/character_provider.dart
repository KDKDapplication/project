import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/child_main/models/character_model.dart';
import 'package:kdkd_mobile/feature/child_main/repositories/character_api.dart';

class CharacterNotifier extends StateNotifier<UiState<CharacterModel>> {
  final CharacterApi api;

  CharacterNotifier(this.api) : super(const Idle());

  /// Character data initial loading
  Future<void> fetchCharacterData() async {
    state = const Loading();
    try {
      final character = await api.getCharacterData();
      if (character != null) {
        state = Success(character);
      } else {
        state = const Failure(
          'CHARACTER_NOT_FOUND',
          message: 'Character information not found',
        );
      }
    } catch (e) {
      state = Failure(
        e,
        message: 'Failed to load character data: ${e.toString()}',
      );
    }
  }

  /// Character data refresh
  Future<void> refreshCharacterData() async {
    // UiState에 따라 이전 데이터 확인
    final previousData = switch (state) {
      Success(data: final data) => data,
      Refreshing(previous: final previous) => previous,
      _ => null,
    };

    if (previousData != null) {
      state = Refreshing(previousData);
    } else {
      state = const Loading();
    }

    try {
      final character = await api.getCharacterData();
      if (character != null) {
        state = Success(character);
      } else {
        state = const Failure(
          'CHARACTER_NOT_FOUND',
          message: 'Character information not found',
        );
      }
    } catch (e) {
      state = Failure(
        e,
        message: 'Failed to load character data: ${e.toString()}',
      );
    }
  }
}

/// Character data Provider
final characterProvider = StateNotifierProvider<CharacterNotifier, UiState<CharacterModel>>((ref) {
  final api = ref.watch(characterApiProvider);
  return CharacterNotifier(api);
});
