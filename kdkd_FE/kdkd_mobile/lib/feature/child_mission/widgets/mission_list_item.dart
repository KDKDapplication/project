import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/feature/parent_mission/models/mission_model.dart';

class MissionListItem extends StatelessWidget {
  final MissionModel mission;
  final VoidCallback? onTap;

  const MissionListItem({
    super.key,
    required this.mission,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.basicShadow,
              blurRadius: 11.8,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
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
                    style: AppFonts.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
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
                    Text(
                      '+ ${NumberFormat('#,###').format(mission.reward)}원',
                      style: AppFonts.headlineMedium.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
