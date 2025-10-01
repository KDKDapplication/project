import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/child_accounts_provider.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/total_auto_debit_provider.dart';
import 'package:kdkd_mobile/feature/parent_main/providers/latest_payment_provider.dart';
import 'package:kdkd_mobile/feature/parent_main/widgets/child_card_section_widget.dart';
import 'package:kdkd_mobile/feature/parent_main/widgets/monthly_and_expense_card_widget.dart';
import 'package:kdkd_mobile/feature/parent_main/widgets/parent_account_card_widget.dart';

class ParentMainPage extends ConsumerStatefulWidget {
  const ParentMainPage({super.key});

  @override
  ConsumerState<ParentMainPage> createState() => _ParentMainPageState();
}

class _ParentMainPageState extends ConsumerState<ParentMainPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      // 총 자동이체 금액 로딩
      ref.read(totalAutoDebitProvider.notifier).refresh(),
      // 최신 결제 정보 로딩
      ref.read(parentLatestPaymentProvider.notifier).getLatestPayment(),
      ref.read(childAccountsProvider.notifier).fetchChildAccounts(),
    ]);
  }

  Future<void> refreshData() async {
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final totalAutoDebit = ref.watch(totalAutoDebitProvider);
    final latestPayment = ref.watch(parentLatestPaymentProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 36, left: AppConst.padding, right: AppConst.padding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 세로 형 카드
                    ParentAccountCardWidget(),
                    SizedBox(width: 16),
                    //
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 148 / 216,
                        child: MonthlyAndExpenseCardWidget(
                          latestPayment: latestPayment.dataOrNull,
                          accountBalance: totalAutoDebit,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ChildCardSectionWidget(),
          ],
        ),
      ),
    );
  }
}
