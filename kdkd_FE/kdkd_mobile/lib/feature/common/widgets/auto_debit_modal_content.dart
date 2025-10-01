import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/parent_common/models/auto_debit_model.dart';
import 'package:kdkd_mobile/feature/parent_common/models/child_account_model.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/auto_debit_provider.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/child_accounts_provider.dart';
import 'package:kdkd_mobile/feature/parent_common/repositories/auto_debit_api.dart';

class AutoDebitModalContent extends ConsumerStatefulWidget {
  final AutoDebitInfo? editingAutoDebit;
  final Function(bool Function())? onValidateAndSave;

  const AutoDebitModalContent({super.key, this.editingAutoDebit, this.onValidateAndSave});

  @override
  ConsumerState<AutoDebitModalContent> createState() => _AutoDebitModalContentState();
}

class _AutoDebitModalContentState extends ConsumerState<AutoDebitModalContent> {
  String? selectedChildUuid;
  int selectedDate = 1;
  int selectedHour = 9;
  int amount = 50000;

  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editingAutoDebit != null) {
      selectedChildUuid = widget.editingAutoDebit!.childUuid;
      selectedDate = widget.editingAutoDebit!.date;
      // "HH:mm:ss" 형식에서 시간만 추출
      final hourString = widget.editingAutoDebit!.hour;
      if (hourString.contains(':')) {
        selectedHour = int.parse(hourString.split(':')[0]);
      } else {
        selectedHour = int.parse(hourString);
      }
      amount = widget.editingAutoDebit!.amount;
      _amountController.text = amount.toString();
    } else {
      _amountController.text = amount.toString();
    }

    // 콜백 설정
    widget.onValidateAndSave?.call(() => validateAndSave(editingAutoDebit: widget.editingAutoDebit));
  }

  @override
  Widget build(BuildContext context) {
    final childAccounts = ref.watch(childAccountsProvider);

    return Padding(
      padding: EdgeInsets.all(AppConst.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.editingAutoDebit != null ? '자동이체 수정' : '자동이체 추가',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 자녀 선택 드롭다운
          _buildChildDropdown(childAccounts),
          const SizedBox(height: 16),

          // 날짜 선택 (1~31)
          _buildDateSelector(),
          const SizedBox(height: 16),

          // 시간 선택 (0~23)
          _buildHourSelector(),
          const SizedBox(height: 16),

          // 금액 입력
          _buildAmountInput(),
        ],
      ),
    );
  }

  Widget _buildChildDropdown(UiState childState) {
    // 수정 모드에서는 읽기 전용으로 표시
    if (widget.editingAutoDebit != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('자녀', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.shade50,
            ),
            child: Text(
              widget.editingAutoDebit!.childName,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      );
    }

    // 추가 모드에서는 드롭다운 표시
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('자녀 선택', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        childState.when(
          idle: () => const Text('자녀 정보를 불러오는 중...'),
          loading: () => const CircularProgressIndicator(),
          success: (children, isFallback, fromCache) {
            // 중복 제거된 자녀 목록 생성
            final uniqueChildren = <String, ChildAccountModel>{};
            for (final child in children) {
              uniqueChildren[child.childUuid] = child;
            }
            final uniqueChildrenList = uniqueChildren.values.toList();

            return DropdownButtonFormField<String>(
              value: selectedChildUuid,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('자녀를 선택하세요'),
              items: uniqueChildrenList.map<DropdownMenuItem<String>>((child) {
                return DropdownMenuItem<String>(
                  value: child.childUuid,
                  child: Text(child.childName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedChildUuid = value;
                });
              },
            );
          },
          failure: (error, message) => Text('오류: $message'),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('실행 날짜', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: selectedDate,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: List.generate(31, (index) {
            final date = index + 1;
            return DropdownMenuItem<int>(
              value: date,
              child: Text('매월 $date일'),
            );
          }),
          onChanged: (value) {
            setState(() {
              selectedDate = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildHourSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('실행 시간', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: selectedHour,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: List.generate(24, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Text(AutoDebitUtils.formatHour(index.toString())),
            );
          }),
          onChanged: (value) {
            setState(() {
              selectedHour = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('이체 금액', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixText: '원',
          ),
          onChanged: (value) {
            amount = int.tryParse(value) ?? 0;
          },
        ),
      ],
    );
  }

  bool validateAndSave({AutoDebitInfo? editingAutoDebit}) {
    if (selectedChildUuid == null || selectedChildUuid!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('자녀를 선택해주세요')),
      );
      return false;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 금액을 입력해주세요')),
      );
      return false;
    }

    // 자녀 계좌 목록에서 실제 UUID 찾기
    final childAccountsState = ref.read(childAccountsProvider);
    String actualChildUuid = selectedChildUuid!;

    childAccountsState.when(
      idle: () {},
      loading: () {},
      success: (children, isFallback, fromCache) {
        // childName으로 실제 childUuid 찾기
        for (final child in children) {
          if (child.childName == selectedChildUuid) {
            actualChildUuid = child.childUuid;
            break;
          }
        }
      },
      failure: (error, message) {},
    );

    print('selectedChildUuid: $selectedChildUuid');
    print('actualChildUuid: $actualChildUuid');

    final request = AutoDebitRegisterRequest(
      childUuid: actualChildUuid,
      date: selectedDate,
      hour: AutoDebitUtils.formatTimeToApi(selectedHour),
      amount: amount,
    );

    if (editingAutoDebit != null || widget.editingAutoDebit != null) {
      // 수정 - 실제 UUID 사용
      ref.read(autoDebitActionProvider.notifier).updateAutoDebit(
            actualChildUuid,
            request,
          );
    } else {
      // 추가
      ref.read(autoDebitActionProvider.notifier).registerAutoDebit(request);
    }

    return true;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
