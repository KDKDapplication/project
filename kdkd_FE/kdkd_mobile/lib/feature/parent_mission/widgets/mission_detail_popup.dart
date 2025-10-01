import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kdkd_mobile/common/format/date_format.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';

import '../models/mission_model.dart';

class MissionDetailPopup extends StatelessWidget {
  final MissionModel mission;

  const MissionDetailPopup({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mission.missionName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -1),
              ),
              Text(
                '+${NumberFormat('#,###').format(mission.reward)}원',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -1),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            '등록일 ${DateFormatter.ymd(mission.createdAt)}',
            style: TextStyle(color: AppColors.grayText, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: -.5),
          ),
          SizedBox(
            height: 24,
          ),
          Text(
            mission.missionContent,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: -1),
          ),
        ],
      ),
    );
  }
}
