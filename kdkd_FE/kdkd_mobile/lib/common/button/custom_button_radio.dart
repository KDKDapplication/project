import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';

/// 라디오 버튼의 각 옵션에 대한 데이터를 담는 클래스
class RadioOptionData {
  final String? line1;
  final String? line2;
  final String? line3;

  const RadioOptionData({this.line1, this.line2, this.line3});
}

class CustomButtonRadio extends StatefulWidget {
  final List<RadioOptionData> options;
  final int initialSelection;
  final Function(int)? onChanged;

  const CustomButtonRadio({
    super.key,
    required this.options,
    this.initialSelection = 0,
    this.onChanged,
  });

  @override
  State<CustomButtonRadio> createState() => _CustomButtonRadioState();
}

class _CustomButtonRadioState extends State<CustomButtonRadio> {
  int? _groupValue;

  @override
  void initState() {
    super.initState();
    _groupValue = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.options.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: _RadioOption(
            value: index,
            groupValue: _groupValue,
            onChanged: (int? value) {
              setState(() {
                _groupValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(value!);
              }
            },
            data: widget.options[index],
          ),
        );
      }),
    );
  }
}

/// 개별 라디오 버튼과 텍스트 라벨을 렌더링하는 내부 위젯
class _RadioOption extends StatelessWidget {
  final int value;
  final int? groupValue;
  final ValueChanged<int?>? onChanged;
  final RadioOptionData data;

  const _RadioOption({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: Radio<int>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: AppColors.black,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(height: 8),
        if (data.line1 != null)
          Text(
            data.line1!,
            style: AppFonts.labelMedium.copyWith(color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
        if (data.line2 != null) const SizedBox(height: 1),
        if (data.line2 != null)
          Text(
            data.line2!,
            style: AppFonts.bodySmall.copyWith(color: AppColors.black),
            textAlign: TextAlign.center,
          ),
        if (data.line3 != null) const SizedBox(height: 1),
        if (data.line3 != null)
          Text(
            data.line3!,
            style: AppFonts.labelSmall.copyWith(color: AppColors.black),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
