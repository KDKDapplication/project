import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/history_list/history_list_widget.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/allowance_payments_provider.dart';

class ParentMainAllowancePage extends ConsumerStatefulWidget {
  const ParentMainAllowancePage({super.key});

  @override
  ConsumerState<ParentMainAllowancePage> createState() => _ParentMainAllowancePageState();
}

class _ParentMainAllowancePageState extends ConsumerState<ParentMainAllowancePage> {
  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allowancePaymentsProvider.notifier).loadAllowancePayments(
            refresh: true,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowanceState = ref.watch(allowancePaymentsProvider);

    if (allowanceState.isLoading && allowanceState.payments.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (allowanceState.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('오류: ${allowanceState.error}'),
              ElevatedButton(
                onPressed: () {
                  ref.read(allowancePaymentsProvider.notifier).loadAllowancePayments(
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
      appbarTitle: "용돈 지급 내역",
      data: allowanceState.payments,
    );
  }
}
