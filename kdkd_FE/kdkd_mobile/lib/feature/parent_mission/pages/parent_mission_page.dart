import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/button/custom_button_add.dart';
import 'package:kdkd_mobile/common/container/custom_container.dart';
import 'package:kdkd_mobile/common/modal/custom_bottom_modal.dart';
import 'package:kdkd_mobile/common/modal/custom_popup_modal.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/child_accounts_provider.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/selected_child_provider.dart';
import 'package:kdkd_mobile/feature/parent_mission/models/mission_model.dart';
import 'package:kdkd_mobile/feature/parent_mission/providers/mission_filter_provider.dart';
import 'package:kdkd_mobile/feature/parent_mission/providers/mission_provider.dart';
import 'package:kdkd_mobile/feature/parent_mission/widgets/mission_add_form.dart';
import 'package:kdkd_mobile/feature/parent_mission/widgets/mission_app_bar.dart';
import 'package:kdkd_mobile/feature/parent_mission/widgets/mission_detail_popup.dart';
import 'package:kdkd_mobile/feature/parent_mission/widgets/mission_list.dart';

class ParentMissionPage extends ConsumerWidget {
  const ParentMissionPage({super.key});

  void _showAddMissionModal(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final contentController = TextEditingController();
    final rewardController = TextEditingController();
    final ValueNotifier<DateTime?> selectedEndDate = ValueNotifier<DateTime?>(null);

    Future<void> selectDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        locale: const Locale('ko', 'KR'),
      );
      if (picked != null) {
        selectedEndDate.value = picked;
      }
    }

    CustomBottomModal.show(
      context: context,
      confirmText: '등록',
      onConfirm: () {
        final selectedChild = ref.read(selectedChildProvider);

        // 필수 필드 검증
        if (selectedChild == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('자녀를 선택해주세요')),
          );
          return;
        }

        if (nameController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('미션 이름을 입력해주세요')),
          );
          return;
        }

        if (contentController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('미션 설명을 입력해주세요')),
          );
          return;
        }

        if (rewardController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('성공 보상을 입력해주세요')),
          );
          return;
        }

        if (selectedEndDate.value == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('종료 날짜를 선택해주세요')),
          );
          return;
        }

        final reward = int.tryParse(rewardController.text) ?? 0;
        ref.read(missionProvider.notifier).createMission(
              missionName: nameController.text,
              missionContent: contentController.text,
              reward: reward,
              endAt: selectedEndDate.value!,
            );
        context.pop();
      },
      child: ValueListenableBuilder<DateTime?>(
        valueListenable: selectedEndDate,
        builder: (context, endDate, child) {
          return MissionAddForm(
            nameController: nameController,
            contentController: contentController,
            rewardController: rewardController,
            selectedEndDate: endDate,
            onDateTap: selectDate,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAccounts = ref.read(childAccountsProvider.notifier).accounts;
    final selectedChild = ref.watch(selectedChildProvider);
    final missionState = ref.watch(missionProvider);
    final filterStatus = ref.watch(missionFilterProvider);
    final isSelected = ref.watch(missionFilterSelectedProvider);

    // 자녀가 없을 때 빈 상태 표시
    if (childAccounts.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(36),
            child: CustomContainer(
              width: double.infinity,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "등록 된 자녀가 없습니다",
                    style: AppFonts.titleMedium.copyWith(
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return missionState.when(
      idle: () => const Center(child: Text('Loading...')),
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (missions, isFallback, fromCache) {
        // 필터링 로직
        var filteredMissions = missions;

        if (filterStatus == MissionStatus.SUCCESS) {
          filteredMissions = missions.where((m) => m.missionStatus == MissionStatus.SUCCESS).toList();
        } else if (filterStatus == MissionStatus.IN_PROGRESS) {
          filteredMissions = missions.where((m) => m.missionStatus == MissionStatus.IN_PROGRESS).toList();
        }

        filteredMissions.sort((a, b) {
          if (a.missionStatus == b.missionStatus) return 0;
          if (a.missionStatus == MissionStatus.IN_PROGRESS) return -1;
          return 1;
        });

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                MissionAppBar(
                  selectedChildId: selectedChild?.childUuid,
                  children: childAccounts,
                  onChildChanged: (String? newValue) {
                    ref.read(selectedChildProvider.notifier).selectChild(newValue);
                  },
                  isFilterSelected: isSelected,
                  onFilterPressed: (int index) {
                    final newSelected = List<bool>.filled(isSelected.length, false);
                    newSelected[index] = true;
                    ref.read(missionFilterSelectedProvider.notifier).state = newSelected;

                    // index 0: 진행중(PROGRESS), index 1: 완료(SUCCESS)
                    if (index == 0) {
                      ref.read(missionFilterProvider.notifier).state = MissionStatus.IN_PROGRESS;
                    } else if (index == 1) {
                      ref.read(missionFilterProvider.notifier).state = MissionStatus.SUCCESS;
                    }
                  },
                ),
                // 필터링된 미션이 없을 때 빈 상태 표시
                if (filteredMissions.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppConst.padding),
                      child: CustomContainer(
                        width: double.infinity,
                        height: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              filterStatus == MissionStatus.IN_PROGRESS ? "진행중인 미션이 없습니다" : "완료한 미션이 없습니다",
                              style: AppFonts.titleMedium.copyWith(
                                color: AppColors.darkGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  MissionList(
                    missions: filteredMissions,
                    onItemTap: (mission) => _handleMissionTap(context, ref, mission),
                  ),
              ],
            ),
            Positioned(
              bottom: 36.0,
              right: 36.0,
              child: CustomButtonAdd(onPressed: () => _showAddMissionModal(context, ref)),
            ),
          ],
        );
      },
      failure: (error, message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message ?? 'Failed to load missions',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(missionProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMissionTap(BuildContext context, WidgetRef ref, MissionModel mission) {
    if (mission.missionStatus == MissionStatus.SUCCESS) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 완료된 미션입니다.')),
      );
      return;
    }

    CustomPopupModal.show(
      context: context,
      child: MissionDetailPopup(mission: mission),
      popupType: PopupType.completeAndDelete,
      confirmText: '삭제',
      onConfirm: () {
        ref.read(missionProvider.notifier).deleteMission(mission.missionUuid);
        Navigator.pop(context);
      },
      confirmText2: '성공',
      onConfirm2: () {
        ref.read(missionProvider.notifier).successMission(mission.missionUuid);
        Navigator.pop(context);
      },
    );
  }
}
