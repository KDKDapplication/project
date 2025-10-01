import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/text_field/custom_text_field_with_label.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/child_accounts_provider.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/selected_child_provider.dart';

class MissionAddForm extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController contentController;
  final TextEditingController rewardController;
  final DateTime? selectedEndDate;
  final VoidCallback onDateTap;

  const MissionAddForm({
    super.key,
    required this.nameController,
    required this.contentController,
    required this.rewardController,
    required this.selectedEndDate,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAccounts = ref.read(childAccountsProvider.notifier).accounts;
    final selectedChild = ref.watch(selectedChildProvider);

    return Padding(
      padding: EdgeInsets.all(AppConst.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 드롭 박스로 자녀 이름
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "자녀",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              DropdownButton<String>(
                value: selectedChild?.childUuid,
                hint: const Text("자녀를 선택하세요"),
                items: childAccounts.map((child) {
                  return DropdownMenuItem<String>(
                    value: child.childUuid,
                    child: Text(child.childName),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  ref.read(selectedChildProvider.notifier).selectChild(newValue);
                },
              ),
            ],
          ),
          const DottedLineSeparator(),

          // 말 그대로 미션 이름 작성하는 곳
          CustomTextFieldWithLabel(
            title: "미션 이름",
            controller: nameController,
          ),
          const DottedLineSeparator(),

          // 다른 인풋 값보다 입력하는 창이 더 큼 height가 3줄 까지 입력 가능
          CustomTextFieldWithLabel(
            title: "미션 설명",
            controller: contentController,
            maxLines: 3,
          ),
          const DottedLineSeparator(),

          // 돈이니까 100,000 형식으로 표시 그리고 마지막에 "원"
          CustomTextFieldWithLabel(
            title: "성공 보상",
            controller: rewardController,
            keyboardType: TextInputType.number,
          ),
          const DottedLineSeparator(),

          // 종료 날짜 선택
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "종료 날짜",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              GestureDetector(
                onTap: onDateTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grayBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedEndDate != null
                        ? "${selectedEndDate!.year}-${selectedEndDate!.month.toString().padLeft(2, '0')}-${selectedEndDate!.day.toString().padLeft(2, '0')}"
                        : "날짜를 선택하세요",
                    style: TextStyle(
                      color: selectedEndDate != null ? AppColors.darkGray : AppColors.grayBorder,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DottedLineSeparator extends StatelessWidget {
  const DottedLineSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: CustomPaint(
        painter: _DottedLinePainter(),
        child: Container(height: 1),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grayBorder
      ..strokeWidth = 1;
    const double dashWidth = 3;
    const double dashSpace = 3;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
