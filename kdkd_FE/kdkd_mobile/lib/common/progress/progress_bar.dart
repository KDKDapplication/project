import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;

  const ProgressBar({
    super.key,
    this.progress = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white, // 배경
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.grey), // 선택사항
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress, // 게이지 값 (e.g., 0.6 for 60%)
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF8A63F8),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
