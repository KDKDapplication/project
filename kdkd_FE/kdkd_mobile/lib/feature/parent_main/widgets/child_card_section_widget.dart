import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/button/custom_button_Large.dart';
import 'package:kdkd_mobile/common/card/custom_card.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/parent_common/models/child_account_model.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/child_accounts_provider.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

class ChildCardSectionWidget extends ConsumerWidget {
  const ChildCardSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UiState<List<ChildAccountModel>> data = ref.watch(childAccountsProvider);

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppConst.padding,
          vertical: 24,
        ),
        child: data.when(
          idle: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          refreshing: (prev) => _Success(prev, context, isRefreshing: true),
          success: (data, isFallback, fromCache) => _Success(data, context),
          failure: (e, msg) => _Failure(onRetry: () => ref.read(childAccountsProvider.notifier).fetchChildAccounts()),
        ),
      ),
    );
  }
}

Widget _Success(List<ChildAccountModel> data, BuildContext context, {bool isRefreshing = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            '자녀 카드',
            style: AppFonts.titleMedium,
          ),
          if (isRefreshing) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
      const SizedBox(height: 16),
      if (data.isEmpty)
        CustomButtonLarge(
          text: '자녀와 연결해보세요!',
          onPressed: () {
            context.push(AppRoutes.parentMainCreateCode);
          },
        ),
      if (data.isNotEmpty)
        ...data.map(
          (account) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CustomCard(
              accountName: account.childName,
              accountNumber: account.childAccountNumber ?? "",
              balance: account.childRemain ?? 0,
              onTap: () {
                if (account.childAccountNumber == null) {
                  return;
                }
                context.push(
                  AppRoutes.parentMainHistory,
                  extra: account.childUuid,
                );
              },
            ),
          ),
        ),
    ],
  );
}

Widget _Failure({required VoidCallback onRetry}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '자녀 카드',
        style: AppFonts.titleMedium,
      ),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              '자녀 계좌 정보를 불러올 수 없습니다',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            CustomButtonLarge(
              text: '다시 시도',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    ],
  );
}
