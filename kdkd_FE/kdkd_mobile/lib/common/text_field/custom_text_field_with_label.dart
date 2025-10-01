import 'package:flutter/material.dart';
import 'package:kdkd_mobile/common/text_field/custom_text_field.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';

enum InputFormatType { none, phone, money, account, password }

class CustomTextFieldWithLabel extends StatefulWidget {
  const CustomTextFieldWithLabel({
    super.key,
    required this.title,
    this.value,
    this.controller,
    this.onChanged,
    this.onTap,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.autoFormat = false,
    this.inputFormatType,
    this.maxLines = 1,
    this.suffix,
  });

  final String title;
  final String? value;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool autoFormat;
  final InputFormatType? inputFormatType;
  final int maxLines;
  final String? suffix;

  @override
  State<CustomTextFieldWithLabel> createState() =>
      _CustomTextFieldWithLabelState();
}

class _CustomTextFieldWithLabelState extends State<CustomTextFieldWithLabel> {
  late TextEditingController _internalController;
  bool _isUsingInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      String initialValue = widget.value ?? '';
      if (widget.autoFormat &&
          widget.inputFormatType != null &&
          initialValue.isNotEmpty) {
        initialValue = _formatInput(initialValue);
      }
      _internalController = TextEditingController(text: initialValue);
      _isUsingInternalController = true;
    } else {
      _internalController = widget.controller!;
      _isUsingInternalController = false;
    }
  }

  @override
  void didUpdateWidget(CustomTextFieldWithLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && _isUsingInternalController) {
      String newValue = widget.value ?? '';
      if (widget.autoFormat &&
          widget.inputFormatType != null &&
          newValue.isNotEmpty) {
        newValue = _formatInput(newValue);
      }
      _internalController.text = newValue;
    }
  }

  @override
  void dispose() {
    if (_isUsingInternalController) {
      _internalController.dispose();
    }
    super.dispose();
  }

  /// ✅ autoFormat 여부와 상관없이 password는 항상 적용
  InputFormatType _getInputFormatType() {
    if (widget.inputFormatType == InputFormatType.password) {
      return InputFormatType.password;
    }
    if (!widget.autoFormat || widget.inputFormatType == null) {
      return InputFormatType.none;
    }
    return widget.inputFormatType!;
  }

  // 📱 Phone: 010-1234-5678
  String _formatPhoneNumber(String value) {
    String numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length > 11) numbers = numbers.substring(0, 11);

    if (numbers.length <= 3) return numbers;
    if (numbers.length <= 7) {
      return '${numbers.substring(0, 3)}-${numbers.substring(3)}';
    }
    return '${numbers.substring(0, 3)}-${numbers.substring(3, 7)}-${numbers.substring(7)}';
  }

  // 💰 Money: 1,000,000
  String _formatMoney(String value) {
    String numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.isEmpty) return '';
    int number = int.parse(numbers);
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  String _formatAccount(String value) {
    String numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length > 16) numbers = numbers.substring(0, 16);

    if (numbers.length <= 4) return numbers;
    if (numbers.length <= 8) {
      return '${numbers.substring(0, 4)}-${numbers.substring(4)}';
    }
    if (numbers.length <= 12) {
      return '${numbers.substring(0, 4)}-${numbers.substring(4, 8)}-${numbers.substring(8)}';
    }
    return '${numbers.substring(0, 4)}-${numbers.substring(4, 8)}-${numbers.substring(8, 12)}-${numbers.substring(12)}';
  }

  // 🔒 Password: 최대 4자리
  String _formatPassword(String value) {
    String numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length > 4) numbers = numbers.substring(0, 4);
    return numbers;
  }

  String _formatInput(String value) {
    switch (_getInputFormatType()) {
      case InputFormatType.phone:
        return _formatPhoneNumber(value);
      case InputFormatType.money:
        return _formatMoney(value);
      case InputFormatType.account:
        return _formatAccount(value);
      case InputFormatType.password:
        return _formatPassword(value);
      case InputFormatType.none:
        return value;
    }
  }

  void _handleTextChange(String value) {
    if (!widget.autoFormat &&
        _getInputFormatType() != InputFormatType.password) {
      widget.onChanged?.call(value);
      return;
    }

    String formatted = _formatInput(value);

    if (formatted != _internalController.text) {
      _internalController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    // ✅ raw value 전달
    final formatType = _getInputFormatType();
    if (formatType == InputFormatType.account ||
        formatType == InputFormatType.money ||
        formatType == InputFormatType.phone ||
        formatType == InputFormatType.password) {
      final numbersOnly = formatted.replaceAll(RegExp(r'[^0-9]'), '');
      widget.onChanged?.call(numbersOnly);
    } else {
      widget.onChanged?.call(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPassword = _getInputFormatType() == InputFormatType.password;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: widget.maxLines > 1
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGray,
          ),
        ),
        Row(
          children: [
            CustomTextField(
              textAlign: TextAlign.end,
              controller: _internalController,
              onChanged: _handleTextChange,
              onTap: widget.onTap,
              readOnly: widget.readOnly,
              keyboardType: widget.keyboardType,
              obscureText: isPassword ? true : widget.obscureText,
              maxLength: isPassword ? 4 : null,
              maxLines: widget.maxLines,
              height: widget.maxLines > 1 ? (widget.maxLines * 20.0 + 20) : 40,
            ),
            if (widget.suffix != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  widget.suffix!,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
