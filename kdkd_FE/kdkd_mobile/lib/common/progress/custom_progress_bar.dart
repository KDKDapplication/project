import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';

class CustomProgressBar extends StatelessWidget {
  final double value;
  const CustomProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: _CustomProgressBar(value: value),
          size: Size(constraints.maxWidth, 8),
        );
      },
    );
  }
}

class _CustomProgressBar extends CustomPainter {
  final double value;
  _CustomProgressBar({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    // 배경 바
    final bgPaint = Paint()..color = AppColors.white;
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(100),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // 진행된 부분
    final progressPaint = Paint()..color = AppColors.mint;
    final progressRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width * value.clamp(0.0, 1.0), size.height),
      const Radius.circular(100),
    );
    canvas.drawRRect(progressRect, progressPaint);

    // ✅ 세로 그림자 (위/아래 inset)
    final verticalShadow = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.black.withOpacity(0.12), // 위쪽
          Colors.transparent,
          Colors.transparent,
          Colors.black.withOpacity(0.12), // 아래쪽
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(bgRect, verticalShadow);

    // ✅ 가로 그림자 (좌/우 inset)
    final horizontalShadow = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.black.withOpacity(0.12), // 왼쪽
          Colors.transparent,
          Colors.transparent,
          Colors.black.withOpacity(0.12), // 오른쪽
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(bgRect, horizontalShadow);
  }

  @override
  bool shouldRepaint(_CustomProgressBar oldDelegate) => oldDelegate.value != value;
}
