import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/format/string_format.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/parent_collection/models/spending_item.dart';
import 'package:kdkd_mobile/feature/parent_collection/providers/spending_pattern_provider.dart';
import 'package:kdkd_mobile/feature/parent_collection/widgets/analysis_summary.dart';
import 'package:kdkd_mobile/feature/parent_collection/widgets/chart_legend.dart';
import 'package:kdkd_mobile/feature/parent_collection/widgets/spending_bar_chart.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/selected_child_provider.dart';

class ParentCollectionAnalysisPage extends ConsumerStatefulWidget {
  const ParentCollectionAnalysisPage({super.key});

  @override
  ConsumerState<ParentCollectionAnalysisPage> createState() => _ParentCollectionAnalysisPageState();
}

class _ParentCollectionAnalysisPageState extends ConsumerState<ParentCollectionAnalysisPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedChild = ref.read(selectedChildProvider);
      if (selectedChild?.childUuid != null) {
        ref.read(spendingPatternDataProvider.notifier).fetchSpendingPattern(selectedChild!.childUuid, '2025-09');
        ref.read(aiFeedbackProvider.notifier).fetchAiFeedback(selectedChild.childUuid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final spendingPatternState = ref.watch(spendingPatternDataProvider);
    final aiFeedbackState = ref.watch(aiFeedbackProvider);
    const Color thisMonthColor = AppColors.primary;
    const Color lastMonthColor = AppColors.violet;

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: CustomAppBar(
          useBackspace: true,
          title: "소비패턴 분석",
          actionType: AppBarActionType.none,
        ),
        body: spendingPatternState.when(
          idle: () => const Center(child: Text('데이터를 불러오는 중...')),
          loading: () => const Center(child: CircularProgressIndicator()),
          success: (data, isFallback, fromCache) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: AppConst.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        data.summary ?? '',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Legend for the bars
                      ChartLegend(
                        thisMonthColor: thisMonthColor,
                        lastMonthColor: lastMonthColor,
                      ),
                      const SizedBox(height: 24),
                      SpendingBarChart(
                        thisMonthColor: thisMonthColor,
                        lastMonthColor: lastMonthColor,
                        thisData: data.thisData != null ? [data.thisData!] : [],
                        lastData: data.lastData != null ? [data.lastData!] : [],
                      ),
                      const SizedBox(height: 30),
                      AnalysisSummary(aiFeedbackState: aiFeedbackState),
                      const SizedBox(height: 20),

                      // 소비 내역 리스트
                      const Text(
                        '소비 내역',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (data.thisData != null)
                        _buildSpendingDetails(data.thisData!)
                      else
                        const Center(
                          child: Text(
                            '소비 내역이 없습니다',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          failure: (error, message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('오류가 발생했습니다: ${message ?? error.toString()}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final selectedChild = ref.read(selectedChildProvider);
                    if (selectedChild?.childUuid != null) {
                      ref
                          .read(spendingPatternDataProvider.notifier)
                          .fetchSpendingPattern(selectedChild!.childUuid, '2025-09');
                      ref.read(aiFeedbackProvider.notifier).fetchAiFeedback(selectedChild.childUuid);
                    }
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingDetails(SpendingItem spendingData) {
    final categoryData = [
      {'name': '편의점', 'amount': spendingData.convenienceStoreAmount},
      {'name': '카페', 'amount': spendingData.cafeAmount},
      {'name': '음식점', 'amount': spendingData.restaurantAmount},
      {'name': '문구/서점', 'amount': spendingData.stationaryStoreAmount},
      {'name': '문화', 'amount': spendingData.cultureAmount},
      {'name': '교통', 'amount': spendingData.transportationAmount},
      {'name': '기타', 'amount': spendingData.etcAmount},
    ];

    // amount 높은 순서대로 정렬
    categoryData.sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));

    return Column(
      children: categoryData.map((category) {
        if (category['amount'] as int == 0) {
          return SizedBox();
        }
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                StringFormat.formatMoney(category['amount'] as int),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
