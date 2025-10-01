import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/date_picker/custom_date_picker.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/common/text_field/custom_text_field_with_label.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:kdkd_mobile/feature/common/providers/setting_profile_provider.dart';

class SettingProfilePage extends ConsumerStatefulWidget {
  const SettingProfilePage({super.key});

  @override
  ConsumerState<SettingProfilePage> createState() => _SettingProfilePageState();
}

class _SettingProfilePageState extends ConsumerState<SettingProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    // 최신 프로필 정보 로드
    ref.read(settingProfileProvider.notifier).loadCurrentProfile();

    final settingState = ref.read(settingProfileProvider);
    _nameController.text = settingState.name;
    setState(() {
      _selectedDate = settingState.birthDate;
    });
  }

  void _onDateSelected(DateTime selectedDay) {
    setState(() {
      _selectedDate = selectedDay;
    });
    ref.read(settingProfileProvider.notifier).setBirthDate(selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final settingState = ref.watch(settingProfileProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: CustomAppBar(
            title: '프로필 수정',
            useBackspace: true,
            actionType: AppBarActionType.none,
          ),
          body: Padding(
            padding: EdgeInsets.all(AppConst.padding),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                _buildAvatarWidget(),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.violet,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        CustomTextFieldWithLabel(
                          title: "이름",
                          keyboardType: TextInputType.text,
                          controller: _nameController,
                          onChanged: (val) {
                            ref.read(settingProfileProvider.notifier).setName(val);
                          },
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '생년월일',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGray,
                                  ),
                                ),
                                CustomDatePicker(
                                  selectedDate: _selectedDate,
                                  onDateChanged: _onDateSelected,
                                  maximumDate: DateTime.now(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: settingState.canSave ? _saveProfile : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.violet,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "저장",
                      style: AppFonts.titleMedium.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWidget() {
    final profileState = ref.watch(profileProvider);
    final settingState = ref.watch(settingProfileProvider);

    // 선택된 이미지가 있으면 표시
    if (_selectedImagePath != null) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(File(_selectedImagePath!)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // 기존 프로필 이미지가 있으면 표시 (URL인 경우만, 로컬 파일 경로 제외)
    if (profileState.dataOrNull?.profileImageUrl != null && profileState.dataOrNull!.profileImageUrl!.isNotEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(profileState.dataOrNull!.profileImageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // 기본 아바타 (부모/자녀 구분 없이 동일)
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.violet,
        image: const DecorationImage(
          image: AssetImage('assets/images/kids_duck.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });

        // 선택된 이미지 경로를 provider에 저장
        ref.read(settingProfileProvider.notifier).setProfileImageUrl(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 선택에 실패했습니다')),
      );
    }
  }

  Future<void> _saveProfile() async {
    final success = await ref.read(settingProfileProvider.notifier).saveProfile(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 저장되었습니다')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필 저장에 실패했습니다')),
      );
    }
  }
}
