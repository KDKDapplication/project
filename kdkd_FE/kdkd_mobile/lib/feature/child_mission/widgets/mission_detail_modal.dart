import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kdkd_mobile/common/format/date_format.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/feature/parent_mission/models/mission_model.dart';

class MissionDetailModal extends StatelessWidget {
  final MissionModel mission;

  const MissionDetailModal({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '부모님',
              style: AppFonts.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            Text('의 미션', style: AppFonts.labelSmall),
            const SizedBox(width: 8),
            Text(
              DateFormatter.range(mission.createdAt, mission.endAt),
              style: AppFonts.labelSmall.copyWith(
                color: AppColors.grayMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              DateFormatter.dDay(mission.endAt),
              style: AppFonts.labelSmall.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          mission.missionName,
          style: AppFonts.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                mission.missionContent,
                style: AppFonts.labelSmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '성공보상',
                    style: AppFonts.labelSmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text('+ ${mission.reward}원', style: AppFonts.headlineMedium.copyWith(color: AppColors.primary)),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 24,
        ),
        SelectPictureWidget(),
      ],
    );
  }
}

class SelectPictureWidget extends StatefulWidget {
  final Function(String?)? onImageSelected;

  const SelectPictureWidget({
    super.key,
    this.onImageSelected,
  });

  @override
  State<SelectPictureWidget> createState() => _SelectPictureWidgetState();
}

class _SelectPictureWidgetState extends State<SelectPictureWidget> {
  String? _imageFilePath;

  Future<void> _pickImage() async {
    try {
      final pickedImageFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImageFile != null) {
        setState(() {
          _imageFilePath = pickedImageFile.path;
        });

        // 부모 위젯에 이미지 경로 전달
        widget.onImageSelected?.call(_imageFilePath);
      }
    } catch (e) {
      print('이미지 선택 에러: $e');
      // 사용자에게 에러 알림 (선택사항)
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              'assets/svgs/camera.svg',
              width: 32,
              height: 32,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Text(
            _imageFilePath != null ? '사진이 선택되었습니다' : '사진을 추가해보세요',
            style: AppFonts.bodyMedium.copyWith(
              color: _imageFilePath != null ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
