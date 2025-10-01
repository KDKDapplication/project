import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';

class RateSelectionBox extends StatefulWidget {
  final List<String> rates;
  final Function(int) onRateSelected;

  const RateSelectionBox({
    super.key,
    required this.rates,
    required this.onRateSelected,
  });

  @override
  State<RateSelectionBox> createState() => _RateSelectionBoxState();
}

class _RateSelectionBoxState extends State<RateSelectionBox> {
  int _selectedIndex = -1; // -1은 아무것도 선택되지 않음을 의미

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 322,
      height: 44,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5.5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(widget.rates.length, (index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onRateSelected(index);
            },
            child: Text(
              widget.rates[index],
              style: AppFonts.titleLarge.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : const Color(0xFFA0A0A0),
              ),
            ),
          );
        }),
      ),
    );
  }
}
