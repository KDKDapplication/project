import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';

class CustomBeforeCard extends StatefulWidget {
  final VoidCallback? onTap;
  final double width;
  final double height;
  final String text;

  const CustomBeforeCard({
    super.key,
    this.onTap,
    this.width = 321,
    this.height = 180,
    this.text = '계좌를 등록해주세요',
  });

  @override
  State<CustomBeforeCard> createState() => _CustomBeforeCardState();
}

class _CustomBeforeCardState extends State<CustomBeforeCard>
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
          decoration: BoxDecoration(
            color: AppColors.violet,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.basicShadow,
                blurRadius: 11.8,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svgs/account_add.svg',
                width: 44,
                height: 44,
              ),
              const SizedBox(height: 12),
              Text(
                widget.text,
                style: AppFonts.bodySmall.copyWith(color: AppColors.grayBG),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
