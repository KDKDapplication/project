import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/dropdown/custom_dropdown.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/child_accounts_provider.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/selected_child_provider.dart';

class CollectionAppBar extends ConsumerWidget {
  const CollectionAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChild = ref.watch(selectedChildProvider);
    final childAccounts = ref.watch(childAccountsProvider.notifier).accounts;

    return SliverAppBar(
      backgroundColor: AppColors.grayBG,
      pinned: true,
      titleSpacing: 0,
      elevation: 0,
      centerTitle: false,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppConst.padding),
        child: Row(
          children: [
            CustomDropdown<String>(
              value: selectedChild!.childUuid,
              onChanged: (v) => ref.read(selectedChildProvider.notifier).selectChild(v),
              items: childAccounts.map((child) {
                return DropdownMenuItem<String>(
                  value: child.childUuid,
                  child: Text(child.childName),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
