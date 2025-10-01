import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final Widget? hint;
  final TextStyle? style;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onChanged,
      itemBuilder: (BuildContext context) {
        return items.map((item) {
          return PopupMenuItem<T>(
            value: item.value,
            child: DefaultTextStyle(
              style: style ??
                  const TextStyle(
                    color: AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -1,
                  ),
              child: item.child,
            ),
          );
        }).toList();
      },
      offset: const Offset(0, 40), // Offset to show below the button
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DefaultTextStyle(
            style: style ??
                const TextStyle(
                  color: AppColors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                ),
            child: _buildSelected(),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black, size: 24),
        ],
      ),
    );
  }

  Widget _buildSelected() {
    if (value == null) {
      return hint ?? const SizedBox.shrink();
    }

    for (final item in items) {
      if (item.value == value) {
        return item.child;
      }
    }

    return hint ?? const SizedBox.shrink();
  }
}
