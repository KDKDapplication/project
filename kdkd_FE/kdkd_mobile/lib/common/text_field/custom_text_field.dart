import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  /// 라벨 표시 여부
  final bool showLabel;

  /// 라벨 텍스트 (showLabel이 true일 때 사용)
  final String? labelText;

  /// 플레이스홀더 텍스트
  final String? placeholder;

  /// onChanged 콜백
  final ValueChanged<String>? onChanged;

  /// 현재 텍스트 필드의 값
  final String? value;

  /// 텍스트 필드가 탭될 때 호출되는 콜백
  final VoidCallback? onTap;

  /// 키보드 타입
  final TextInputType? keyboardType;

  /// 비밀번호 입력 여부
  final bool obscureText;

  /// 읽기 전용 여부
  final bool readOnly;

  /// 가로 길이
  final double? width;

  /// 세로 길이
  final double? height;

  final int maxLines;

  final TextEditingController? controller;

  /// 텍스트 정렬
  final TextAlign textAlign;

  /// 입력 최대 길이
  final int? maxLength;

  const CustomTextField({
    super.key,
    this.showLabel = false,
    this.labelText,
    this.placeholder,
    this.onChanged,
    this.value,
    this.onTap,
    this.readOnly = false,
    this.keyboardType,
    this.obscureText = false,
    this.width,
    this.height,
    this.maxLines = 1,
    this.controller,
    this.textAlign = TextAlign.left,
    this.maxLength,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 외부에서 값이 변경되었고, 현재 컨트롤러의 값과 다를 경우에만 업데이트
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
      // 커서를 텍스트 끝으로 이동
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    // 외부에서 제공된 컨트롤러가 아닐 때만 dispose
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 240,
      height: widget.height ?? 40,
      child: TextField(
        maxLines: widget.maxLines,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        readOnly: widget.readOnly,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        textAlign: widget.textAlign,
        controller: _controller,
        maxLength: widget.maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        decoration: InputDecoration(
          counterText: '',
          label: widget.showLabel ? Text(widget.labelText ?? '') : null,
          hintText: widget.placeholder,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 1.0),
          ),
        ),
      ),
    );
  }
}
