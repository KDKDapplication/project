import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/auth/models/profile_model.dart';
import 'package:kdkd_mobile/feature/auth/repositories/profile_api.dart';

final profileProvider = StateNotifierProvider<ProfileController, UiState<Profile>>(
  (ref) => ProfileController(ref),
);

class ProfileController extends StateNotifier<UiState<Profile>> {
  final Ref ref;

  ProfileController(this.ref) : super(const Idle()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const Loading();
    try {
      final profileApi = ref.read(profileApiProvider);
      final profile = await profileApi.getMyProfile();

      if (profile != null) {
        state = Success(profile);
      } else {
        state = const Failure('프로필을 불러올 수 없습니다');
      }
    } catch (e) {
      state = Failure(e);
    }
  }

  void clearProfile() {
    state = const Idle();
  }

  bool get isParent => state.when(
        idle: () => false,
        loading: () => false,
        success: (profile, isFallback, fromCache) => profile.r == role.PARENT,
        failure: (error, message) => false,
      );

  String get uuid => state.when(
        idle: () => '',
        loading: () => '',
        success: (profile, isFallback, fromCache) => profile.uuid,
        failure: (error, message) => '',
      );
}
