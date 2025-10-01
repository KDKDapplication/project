import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/history_list/history_list_widget.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/payments_provider.dart';

class ParentMainHistoryPage extends ConsumerStatefulWidget {
  final String childUuid;

  const ParentMainHistoryPage({super.key, required this.childUuid});

  @override
  ConsumerState<ParentMainHistoryPage> createState() => _ParentMainHistoryPageState();
}

class _ParentMainHistoryPageState extends ConsumerState<ParentMainHistoryPage> {
  int currentMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentsProvider.notifier).loadPayments(
            childUuid: widget.childUuid,
            refresh: true,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentsState = ref.watch(paymentsProvider);

    if (paymentsState.isLoading && paymentsState.data.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (paymentsState.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('오류: ${paymentsState.error}'),
              ElevatedButton(
                onPressed: () {
                  ref.read(paymentsProvider.notifier).loadPayments(
                        childUuid: widget.childUuid,
                        refresh: true,
                      );
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    return HistoryListWidget(
      appbarTitle: "소비 내역",
      data: paymentsState.data,
      currentMonth: currentMonth,
      onMonthChanged: (int newMonth) {
        setState(() {
          currentMonth = newMonth;
        });

        // 월 형식을 YYYY-MM으로 변환
        final now = DateTime.now();
        final targetMonth = DateTime(now.year, newMonth);
        final monthString = "${targetMonth.year}-${targetMonth.month.toString().padLeft(2, '0')}";

        // PaymentsProvider의 changeMonth 메서드 사용
        ref.read(paymentsProvider.notifier).changeMonth(monthString);
      },
    );
  }
}
