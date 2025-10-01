import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';

class MissionFilterSection extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const MissionFilterSection({super.key, required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppConst.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildFilterButton(0, '진행중'),
          const SizedBox(width: 8),
          _buildFilterButton(1, '완료'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(int index, String text) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onSelect(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.violet : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.btnShadow.withOpacity(.25),
                    offset: Offset(0, 2),
                    blurRadius: 5.5,
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: AppFonts.labelMedium.copyWith(
            color: isSelected ? Colors.black : AppColors.grayMedium,
          ),
        ),
      ),
    );
  }
}
