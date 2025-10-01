import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/history_list/history_list_widget.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/payments_provider.dart';

class ParentCollectionHistoryPage extends ConsumerStatefulWidget {
  final String childUuid;

  const ParentCollectionHistoryPage({super.key, required this.childUuid});

  @override
  ConsumerState<ParentCollectionHistoryPage> createState() => _ParentCollectionHistoryPageState();
}

class _ParentCollectionHistoryPageState extends ConsumerState<ParentCollectionHistoryPage> {
  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
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
    );
  }
}
