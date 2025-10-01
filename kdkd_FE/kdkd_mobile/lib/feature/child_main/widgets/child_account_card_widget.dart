import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/format/string_format.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:kdkd_mobile/feature/common/models/user_account_model.dart';
import 'package:kdkd_mobile/feature/common/providers/user_account_provider.dart';
import 'package:kdkd_mobile/feature/parent_main/widgets/small_vertical_card_widget.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

class ChildAccountCardWidget extends ConsumerWidget {
  const ChildAccountCardWidget({super.key, required this.hasAccountNumber});
  final bool hasAccountNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UiState profile = ref.watch(profileProvider);
    final UiState<UserAccountModel> userAccount = ref.watch(userAccountProvider);

    return Expanded(
      child: SmallVerticalCardWidget(
        onTap: () {
          // 카드 정보가 있을 때 ->
          if (hasAccountNumber) {
            context.push(AppRoutes.history);
          } else {
            // 카드 정보가 없을 때 ->
            context.push(AppRoutes.registerAccount);
          }
        },
        accountName: hasAccountNumber ? profile.dataOrNull?.name : "",
        accountNumber:
            hasAccountNumber ? StringFormat.formatAccountNumber(userAccount.dataOrNull?.accountNumber) : null,
      ),
    );
  }
}
