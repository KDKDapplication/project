import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kdkd_mobile/common/format/date_format.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/feature/parent_mission/models/mission_model.dart';

class FeaturedMissionCard extends StatelessWidget {
  const FeaturedMissionCard({
    super.key,
    required this.featureMission,
  });

  final MissionModel featureMission;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      // margin: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: AppColors.grayBorder,
          ),
        ),
        image: DecorationImage(
          image: AssetImage('assets/images/mission_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽 텍스트 영역
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(33),
                    color: AppColors.yellow,
                  ),
                  child: Text(
                    "HOT",
                    style: AppFonts.labelMedium.copyWith(
                      color: AppColors.redError,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormatter.range(featureMission.createdAt, featureMission.endAt),
                  style: AppFonts.labelSmall.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  featureMission.missionName,
                  style: AppFonts.titleLarge,
                ),
                Spacer(),
                Text(
                  featureMission.missionContent,
                  style: AppFonts.labelSmall.copyWith(fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
          // 오른쪽 보상 금액
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${NumberFormat('#,###').format(featureMission.reward)} 원",
                style: AppFonts.displaySmall.copyWith(
                  letterSpacing: -1,
                  fontSize: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedMissionCardDelegate extends SliverPersistentHeaderDelegate {
  final MissionModel featureMission;
  final Function(MissionModel) onTap;
  final double height;

  _FeaturedMissionCardDelegate({
    required this.featureMission,
    required this.onTap,
    required this.height,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return GestureDetector(
      onTap: () => onTap(featureMission),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: AppColors.grayBorder,
            ),
          ),
          image: const DecorationImage(
            image: AssetImage('assets/images/mission_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 왼쪽 텍스트 영역
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(33),
                      color: AppColors.yellow,
                    ),
                    child: Text(
                      "HOT",
                      style: AppFonts.labelMedium.copyWith(
                        color: AppColors.redError,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '9월 5일 09:00 ~ 9월 5일 11:59',
                    style: AppFonts.labelSmall.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    featureMission.missionName,
                    style: AppFonts.titleLarge,
                  ),
                  const Spacer(),
                  Text(
                    featureMission.missionContent,
                    style: AppFonts.labelSmall.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // 오른쪽 보상 금액
            Expanded(
              flex: 4,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "+ ${featureMission.reward} 원",
                  style: AppFonts.displaySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _FeaturedMissionCardDelegate oldDelegate) {
    return featureMission != oldDelegate.featureMission || height != oldDelegate.height;
  }
}
