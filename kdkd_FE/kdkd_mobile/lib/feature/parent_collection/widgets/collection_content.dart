import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/feature/parent_collection/widgets/collection_analysis_button.dart';
import 'package:kdkd_mobile/feature/parent_collection/widgets/collection_app_bar.dart';
import 'package:kdkd_mobile/feature/parent_collection/widgets/collection_auto_debit.dart';
import 'package:kdkd_mobile/feature/parent_collection/widgets/collection_loan.dart';
import 'package:kdkd_mobile/feature/parent_collection/widgets/collection_spending_history.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/selected_child_provider.dart';

class CollectionContent extends ConsumerWidget {
  const CollectionContent({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChild = ref.watch(selectedChildProvider);
    const double buttonAreaHeight = 60.0;
    const double buttonAreaMargin = 30.0;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            /// 자녀 선택 드롭 박스
            CollectionAppBar(),

            /// 자동 이체 관련 박스
            CollectionAutoDebit(
              isAutoDebit: selectedChild?.isAutoDebit ?? false,
              onChanged: (val) {
                ref.read(selectedChildProvider.notifier).updateAutoDebit(val);
              },
            ),

            /// 빌리기 관련 박스
            CollectionLoan(selectedChild: selectedChild),

            /// 지출 내역 관련 박스
            const CollectionSpendingHistory(),

            /// 마진
            const SliverToBoxAdapter(
              child: SizedBox(height: buttonAreaHeight + buttonAreaMargin),
            ),
          ],
        ),
        if (selectedChild?.childAccountNumber != null)

          /// 소비 패턴
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CollectionAnalysisButton(
              buttonAreaHeight: buttonAreaHeight,
              buttonAreaMargin: buttonAreaMargin,
            ),
          ),
      ],
    );
  }
}
