import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/format/string_format.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:kdkd_mobile/feature/common/providers/user_account_provider.dart';
import 'package:kdkd_mobile/feature/parent_main/widgets/small_vertical_card_widget.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

class ParentAccountCardWidget extends ConsumerWidget {
  const ParentAccountCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UiState profile = ref.watch(profileProvider);
    final UiState userAccount = ref.watch(userAccountProvider);

    return Expanded(
      child: SmallVerticalCardWidget(
        onTap: () {
          // 카드 정보가 있을 때 ->
          if (userAccount.dataOrNull != null) {
            context.push(AppRoutes.history);
          } else {
            // 카드 정보가 없을 때 ->
            context.push(AppRoutes.registerAccount);
          }
        },
        accountName: profile.dataOrNull?.name ?? "이름",
        accountNumber: StringFormat.formatAccountNumber(userAccount.dataOrNull?.accountNumber),
      ),
    );
  }
}
