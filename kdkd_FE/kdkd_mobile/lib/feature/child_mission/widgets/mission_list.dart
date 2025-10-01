import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/parent_mission/models/mission_model.dart';

import './mission_list_item.dart';

class MissionList extends StatelessWidget {
  final int filter;
  final List<MissionModel> missions;

  const MissionList({
    super.key,
    required this.missions,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final String filterName = filter == 0 ? '진행 중인' : "완료 된";

    if (missions.isEmpty) {
      return Center(
        child: Text(
          '$filterName 미션이 없습니다.',
          style: AppFonts.headlineLarge,
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: AppConst.padding,
      ),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        return MissionListItem(
          mission: missions[index],
        );
      },
    );
  }
}
