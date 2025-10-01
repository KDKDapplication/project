import 'package:flutter/material.dart';
import 'package:kdkd_mobile/common/dropdown/custom_dropdown.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/parent_common/models/child_account_model.dart';

class MissionAppBar extends StatelessWidget {
  final String? selectedChildId;
  final List<ChildAccountModel> children;
  final Function(String?) onChildChanged;
  final List<bool> isFilterSelected;
  final Function(int) onFilterPressed;

  const MissionAppBar({
    super.key,
    required this.selectedChildId,
    required this.children,
    required this.onChildChanged,
    required this.isFilterSelected,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.grayBG,
      pinned: true,
      titleSpacing: 0,
      elevation: 0,
      centerTitle: false,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppConst.padding),
        child: Row(
          children: [
            CustomDropdown<String>(
              value: selectedChildId,
              onChanged: onChildChanged,
              items: children.map((child) {
                return DropdownMenuItem<String>(
                  value: child.childUuid,
                  child: Text(child.childName),
                );
              }).toList(),
            ),
            const Spacer(),
            ToggleButtons(
              isSelected: isFilterSelected,
              onPressed: onFilterPressed,
              color: AppColors.grayMedium,
              selectedColor: AppColors.primary,
              fillColor: AppColors.white,
              borderColor: AppColors.graySoft,
              selectedBorderColor: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              constraints: const BoxConstraints(minHeight: 32.0, minWidth: 60.0),
              children: const <Widget>[
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('진행중')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('완료')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
