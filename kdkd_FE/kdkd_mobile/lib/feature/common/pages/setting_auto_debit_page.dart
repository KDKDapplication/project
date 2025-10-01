import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/button/custom_button_add.dart';
import 'package:kdkd_mobile/common/container/custom_container.dart';
import 'package:kdkd_mobile/common/modal/custom_bottom_modal.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/common/widgets/auto_debit_modal_content.dart';
import 'package:kdkd_mobile/feature/parent_common/models/auto_debit_model.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/auto_debit_provider.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/child_accounts_provider.dart';
import 'package:kdkd_mobile/feature/parent_common/repositories/auto_debit_api.dart';

class SettingAutoDebitPage extends ConsumerStatefulWidget {
  const SettingAutoDebitPage({super.key});

  @override
  ConsumerState<SettingAutoDebitPage> createState() => _SettingAutoDebitPageState();
}

class _SettingAutoDebitPageState extends ConsumerState<SettingAutoDebitPage> {
  @override
  void initState() {
    super.initState();
    // 페이지 진입 시 자동이체 목록 조회
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(autoDebitListProvider.notifier).fetchAutoDebitList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final autoDebitListState = ref.watch(autoDebitListProvider);

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: CustomAppBar(
          title: "자동이체 설정",
          useBackspace: true,
          actionType: AppBarActionType.none,
        ),
        body: Stack(
          children: [
            // 자동이체 리스트 표시
            _buildAutoDebitList(autoDebitListState),

            // 추가 버튼
            Positioned(
              bottom: 36.0,
              right: 36.0,
              child: CustomButtonAdd(
                onPressed: () => _showAddAutoDebitModal(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoDebitList(UiState<List<AutoDebitInfo>> state) {
    return state.when(
      idle: () => const Center(child: Text('자동이체 설정을 확인하세요')),
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (autoDebits, isFallback, fromCache) {
        if (autoDebits.isEmpty) {
          return _buildEmptyState();
        }
        return _buildAutoDebitListView(autoDebits);
      },
      failure: (error, message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('오류가 발생했습니다: ${message ?? error.toString()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(autoDebitListProvider.notifier).refresh(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '설정된 자동이체가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '+ 버튼을 눌러 자동이체를 설정해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoDebitListView(List<AutoDebitInfo> autoDebits) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: AppConst.padding),
      itemCount: autoDebits.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final autoDebit = autoDebits[index];
        return _buildAutoDebitCard(autoDebit);
      },
    );
  }

  Widget _buildAutoDebitCard(AutoDebitInfo autoDebit) {
    return CustomContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            autoDebit.childName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            autoDebit.autoDebitDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showEditAutoDebitModal(autoDebit),
                      child: SvgPicture.asset(
                        'assets/svgs/edit.svg',
                        height: 20,
                        width: 20,
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () => _showDeleteConfirmDialog(autoDebit),
                      child: SvgPicture.asset(
                        'assets/svgs/delete.svg',
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (autoDebit.isActive) ...[
                  const SizedBox(height: 4),
                  Text(
                    '다음 실행: ${AutoDebitUtils.getTimeUntilNextExecution(autoDebit.date, autoDebit.hour)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  ),
                ],
                Spacer(),
                Text(
                  autoDebit.autoDebitMoney,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAutoDebitModal() {
    _showAutoDebitModal();
  }

  void _showEditAutoDebitModal(AutoDebitInfo autoDebit) {
    _showAutoDebitModal(editingAutoDebit: autoDebit);
  }

  void _showAutoDebitModal({AutoDebitInfo? editingAutoDebit}) {
    final isEditing = editingAutoDebit != null;
    bool Function()? validateAndSave;

    CustomBottomModal.show(
      context: context,
      child: _buildAutoDebitModalContent(
        editingAutoDebit: editingAutoDebit,
        onValidateAndSave: (callback) => validateAndSave = callback,
      ),
      confirmText: isEditing ? '수정' : '추가',
      onConfirm: () {
        final success = validateAndSave?.call() ?? false;
        if (success) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildAutoDebitModalContent({
    AutoDebitInfo? editingAutoDebit,
    Function(bool Function())? onValidateAndSave,
  }) {
    return AutoDebitModalContent(
      editingAutoDebit: editingAutoDebit,
      onValidateAndSave: onValidateAndSave,
    );
  }

  void _showDeleteConfirmDialog(AutoDebitInfo autoDebit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('자동이체 삭제'),
        content: Text('${autoDebit.childName}의 자동이체를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              // 실제 UUID 찾기
              final childAccountsState = ref.read(childAccountsProvider);
              String actualChildUuid = autoDebit.childUuid;

              childAccountsState.when(
                idle: () {},
                loading: () {},
                success: (children, isFallback, fromCache) {
                  // childName으로 실제 childUuid 찾기
                  for (final child in children) {
                    if (child.childName == autoDebit.childName) {
                      actualChildUuid = child.childUuid;
                      break;
                    }
                  }
                },
                failure: (error, message) {},
              );

              print('Delete - childName: ${autoDebit.childName}');
              print('Delete - originalUuid: ${autoDebit.childUuid}');
              print('Delete - actualUuid: $actualChildUuid');

              ref.read(autoDebitActionProvider.notifier).deleteAutoDebit(actualChildUuid);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
