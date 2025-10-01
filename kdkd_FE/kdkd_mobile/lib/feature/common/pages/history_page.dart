import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/history_list/history_consumption_widget.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/common/providers/history_provider.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  int currentMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).getConsumptions(
            month: _formatMonth(currentMonth),
          );
    });
  }

  String _formatMonth(int month) {
    final year = DateTime.now().year;
    return '$year${month.toString().padLeft(2, '0')}';
  }

  void _onMonthChanged(int newMonth) {
    setState(() {
      currentMonth = newMonth;
    });
    ref.read(historyProvider.notifier).getConsumptions(
          month: _formatMonth(newMonth),
        );
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: CustomAppBar(
          actionType: AppBarActionType.none,
          title: "계좌 거래내역",
        ),
        body: Column(
          children: [
            _HistoryAppBar(
              currentMonth: currentMonth,
              onMonthChanged: _onMonthChanged,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: historyState.when(
                idle: () => const Center(child: CircularProgressIndicator()),
                loading: () => const Center(child: CircularProgressIndicator()),
                success: (data, isFallback, fromCache) => HistoryConsumptionWidget(
                  data: data.list,
                  currentMonth: currentMonth,
                  onMonthChanged: _onMonthChanged,
                ),
                failure: (error, message) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(message ?? '오류가 발생했습니다'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(historyProvider.notifier).getConsumptions(
                                month: _formatMonth(currentMonth),
                              );
                        },
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
                refreshing: (prev) => HistoryConsumptionWidget(
                  data: prev.list,
                  currentMonth: currentMonth,
                  onMonthChanged: _onMonthChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryAppBar extends StatelessWidget {
  const _HistoryAppBar({
    this.currentMonth,
    this.onMonthChanged,
  });

  final int? currentMonth;
  final Function(int)? onMonthChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(
        horizontal: AppConst.padding,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFAEFFDC).withValues(alpha: 0.1),
            const Color(0xFF9B6BFF).withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (onMonthChanged != null)
            GestureDetector(
              onTap: () {
                final month = currentMonth ?? DateTime.now().month;
                final newMonth = month == 1 ? 12 : month - 1;
                onMonthChanged!(newMonth);
              },
              child: SvgPicture.asset(
                'assets/svgs/left_tri.svg',
                height: 24,
                width: 24,
                color: AppColors.darkGray,
              ),
            )
          else
            const SizedBox(width: 28),
          SizedBox(width: 8),
          Text(
            "${currentMonth ?? DateTime.now().month}월",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 8),
          if (onMonthChanged != null)
            GestureDetector(
              onTap: () {
                final month = currentMonth ?? DateTime.now().month;
                final newMonth = month == 12 ? 1 : month + 1;
                onMonthChanged!(newMonth);
              },
              child: SvgPicture.asset(
                'assets/svgs/right_tri.svg',
                height: 24,
                width: 24,
                color: AppColors.darkGray,
              ),
            )
          else
            const SizedBox(width: 28),
        ],
      ),
    );
  }
}
