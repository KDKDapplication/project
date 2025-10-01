import 'package:flutter/material.dart';

class CustomToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onToggle;
  final Color backgroundColor;
  final Color textColor;
  final bool isParent;

  const CustomToggle({
    super.key,
    required this.selectedIndex,
    required this.onToggle,
    required this.backgroundColor,
    required this.textColor,
    this.isParent = true,
  });

  @override
  Widget build(BuildContext context) {
    const double width = 250;
    const double height = 60;

    return Center(
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(5), // 내부 공간감을 위한 패딩
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade200,
              Colors.white,
            ],
            stops: const [0.0, 0.5],
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 슬라이딩되는 배경
            AnimatedAlign(
              alignment: selectedIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                width: width / 2,
                height: height,
                decoration: BoxDecoration(
                  color: backgroundColor, // 보라색
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            // 텍스트 버튼
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => onToggle(0),
                    style: TextButton.styleFrom(shape: const StadiumBorder()),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isParent ? (selectedIndex == 0 ? Colors.white : Colors.black) : Colors.black,
                      ),
                      child: const Text("결제"),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => onToggle(1),
                    style: TextButton.styleFrom(shape: const StadiumBorder()),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isParent ? (selectedIndex == 1 ? Colors.white : Colors.black) : Colors.black,
                      ),
                      child: const Text("태깅"),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
