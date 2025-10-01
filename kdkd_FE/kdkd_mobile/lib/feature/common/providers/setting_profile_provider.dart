import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:kdkd_mobile/feature/common/models/setting_profile_model.dart';
import 'package:kdkd_mobile/feature/common/repositories/setting_profile_api.dart';

final settingProfileProvider = StateNotifierProvider<SettingProfileController, SettingProfileModel>(
  (ref) => SettingProfileController(ref),
);

class SettingProfileController extends StateNotifier<SettingProfileModel> {
  final Ref ref;

  SettingProfileController(this.ref) : super(SettingProfileModel.initial());

  void loadCurrentProfile() {
    final profileState = ref.read(profileProvider);
    profileState.when(
      idle: () {},
      loading: () {},
      success: (profile, _, __) {
        state = state.copyWith(
          name: profile.name ?? '',
          birthDate: profile.birthdate ?? DateTime.now(),
          profileImageUrl: profile.profileImageUrl,
          isValid: _validateForm(profile.name ?? ''),
        );
      },
      failure: (_, __) {},
    );
  }

  void setName(String name) {
    state = state.copyWith(
      name: name,
      isValid: _validateForm(name),
    );
  }

  void setBirthDate(DateTime birthDate) {
    state = state.copyWith(
      birthDate: birthDate,
    );
  }

  void setProfileImageUrl(String? imageUrl) {
    state = state.copyWith(
      profileImageUrl: imageUrl,
    );
  }

  bool _validateForm(String name) {
    return name.isNotEmpty;
  }

  bool get canComplete => state.canSave;

  Future<bool> saveProfile(BuildContext context) async {
    if (!canComplete) return false;

    try {
      final api = ref.read(settingProfileApiProvider);

      // 프로필 정보 업데이트
      final birthDateString =
          "${state.birthDate.year}-${state.birthDate.month.toString().padLeft(2, '0')}-${state.birthDate.day.toString().padLeft(2, '0')}";

      final updatedProfile = await api.patchUserProfileDetail(state.name, birthDateString);

      if (updatedProfile == null) return false;

      // 업데이트된 프로필로 profile_provider 상태 즉시 업데이트
      ref.read(profileProvider.notifier).state = Success(updatedProfile);

      // 프로필 이미지 업데이트 (필요한 경우)
      if (state.profileImageUrl != null && state.profileImageUrl!.isNotEmpty) {
        final imageSuccess = await api.patchUserProfileImage(state.profileImageUrl!);
        if (!imageSuccess) return false;

        // 이미지 업데이트 성공 시 프로필에 새 이미지 URL 반영
        final updatedProfileWithImage = updatedProfile.copyWith(
          profileImageUrl: state.profileImageUrl,
        );
        ref.read(profileProvider.notifier).state = Success(updatedProfileWithImage);
      }

      // 프로필 provider 다시 로드 (최신 데이터 확실히 가져오기)
      await ref.read(profileProvider.notifier).loadProfile();

      return true;
    } catch (e) {
      return false;
    }
  }

  void reset() {
    state = SettingProfileModel.initial();
    loadCurrentProfile();
  }
}
