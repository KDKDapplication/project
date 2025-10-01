import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/selected_child_provider.dart';
import 'package:kdkd_mobile/feature/parent_common/repositories/auto_debit_api.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

class CollectionAutoDebit extends ConsumerWidget {
  final bool isAutoDebit;
  final Function(bool) onChanged;

  const CollectionAutoDebit({super.key, required this.isAutoDebit, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChild = ref.watch(selectedChildProvider);
    final Flex body;

    if (selectedChild == null || selectedChild.isAutoDebit == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (!selectedChild.isAutoDebit!) {
      body = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '용돈 관리 하기',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: -.5,
            ),
          ),
          SvgPicture.asset(
            'assets/svgs/arrow.svg',
            height: 16,
            width: 16,
            color: AppColors.white,
          ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '매월 ${selectedChild.autoDebitDay?.toString() ?? '-'}일',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -.5,
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                selectedChild.autoDebitTime != null ? AutoDebitUtils.formatHour(selectedChild.autoDebitTime!) : '',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                selectedChild.autoDebitMoney != null
                    ? '${selectedChild.autoDebitMoney.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},').replaceAll('원', '')}원'
                    : '-',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -.5,
                ),
              ),
              Spacer(),
              const Text(
                '용돈 관리',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -.5,
                ),
              ),
              SvgPicture.asset(
                'assets/svgs/arrow.svg',
                height: 16,
                width: 16,
                color: AppColors.white,
              ),
            ],
          ),
        ],
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppConst.padding, 0, AppConst.padding, 16),
        child: GestureDetector(
          onTap: () => context.push(AppRoutes.settingAutoDebit),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: body,
          ),
        ),
      ),
    );
  }
}
