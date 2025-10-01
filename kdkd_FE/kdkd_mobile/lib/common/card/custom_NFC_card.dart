import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';

class CustomNfcCard extends StatefulWidget {
  final String childName;
  final String accountNumber;
  final String characterImagePath;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const CustomNfcCard({
    super.key,
    required this.childName,
    required this.accountNumber,
    required this.characterImagePath,
    this.height = 413,
    this.width = 282,
    this.onTap,
  });

  @override
  State<CustomNfcCard> createState() => _CustomNfcCardState();
}

class _CustomNfcCardState extends State<CustomNfcCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment(0.9, -0.4),
              end: Alignment(-0.9, 0.4),
              colors: [AppColors.mint, AppColors.yellow],
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.basicShadow,
                blurRadius: 11.8,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: _buildCardContent(),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Stack(
      children: [
        // 자녀 이름
        Positioned(
          top: 27,
          left: 25,
          child: Text(
            widget.childName,
            style: AppFonts.headlineLarge.copyWith(color: AppColors.black),
          ),
        ),
        // 계좌 번호
        Positioned(
          top: 63,
          left: 25,
          child: Text(
            widget.accountNumber,
            style: AppFonts.bodySmall.copyWith(color: AppColors.black),
          ),
        ),
        // 캐릭터 이미지
        Positioned(
          left: 104,
          bottom: -70,
          child: Transform.rotate(
            angle: -0.54 * (math.pi / 180),
            child: Image.asset(
              widget.characterImagePath,
              width: 188,
              height: 188,
            ),
          ),
        ),
      ],
    );
  }
}
