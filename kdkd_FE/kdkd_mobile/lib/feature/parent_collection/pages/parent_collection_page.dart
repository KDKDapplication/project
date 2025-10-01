import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/feature/parent_collection/widgets/collection_content.dart';
import 'package:kdkd_mobile/feature/parent_collection/widgets/empty_children_state.dart';
import 'package:kdkd_mobile/feature/parent_common/models/child_account_model.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/auto_debit_provider.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/child_accounts_provider.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/payments_provider.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/selected_child_provider.dart';

class ParentCollectionPage extends ConsumerStatefulWidget {
  const ParentCollectionPage({super.key});

  @override
  ConsumerState<ParentCollectionPage> createState() => _ParentCollectionPageState();
}

class _ParentCollectionPageState extends ConsumerState<ParentCollectionPage> {
  @override
  void initState() {
    super.initState();

    // selectedChildProvider 상태 변경을 감시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 초기 데이터 로드
      final selectedChild = ref.read(selectedChildProvider);
      if (selectedChild?.childUuid != null) {
        _loadPaymentsForChild(selectedChild!.childUuid);
      }
    });
  }

  void _loadPaymentsForChild(String childUuid) {
    ref.read(paymentsProvider.notifier).loadPayments(
          childUuid: childUuid,
          refresh: true,
        );
  }

  Future<void> _refreshData() async {
    final selectedChild = ref.read(selectedChildProvider);
    if (selectedChild?.childUuid != null) {
      // 용돈 내역 새로고침
      _loadPaymentsForChild(selectedChild!.childUuid);

      // 자동이체 목록 새로고침
      await ref.read(autoDebitListProvider.notifier).fetchAutoDebitList();

      // 선택된 자녀 정보 새로고침 (빌리기 상태 포함)
      ref.read(selectedChildProvider.notifier).selectChild(selectedChild.childUuid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<ChildAccountModel> childAccounts = ref.watch(childAccountsProvider.notifier).accounts;

    // selectedChildProvider 변경 감시
    ref.listen<ChildAccountModel?>(selectedChildProvider, (previous, next) {
      if (next?.childUuid != null && next?.childUuid != previous?.childUuid) {
        _loadPaymentsForChild(next!.childUuid);
      }
    });

    print(childAccounts);

    // 자녀가 없을 때 빈 상태 표시
    if (childAccounts.isEmpty) {
      return const EmptyChildrenState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: const CollectionContent(),
    );
  }
}
