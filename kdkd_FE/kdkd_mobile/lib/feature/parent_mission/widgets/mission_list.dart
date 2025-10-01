import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/child_mission/widgets/mission_list_item.dart';
import 'package:kdkd_mobile/feature/parent_mission/models/mission_model.dart';

class MissionList extends StatelessWidget {
  final List<MissionModel> missions;
  final Function(MissionModel) onItemTap;

  const MissionList({super.key, required this.missions, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppConst.padding, vertical: 24.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final mission = missions[index];
            return MissionListItem(
              mission: mission,
              onTap: () => onItemTap(mission),
            );
          },
          childCount: missions.length,
        ),
      ),
    );
  }
}
