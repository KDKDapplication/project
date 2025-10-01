import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/modal/custom_popup_modal.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/auth/models/profile_model.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:kdkd_mobile/feature/child_mission/provider/mission_provider.dart';
import 'package:kdkd_mobile/feature/child_mission/widgets/featured_mission_card.dart';
import 'package:kdkd_mobile/feature/child_mission/widgets/mission_detail_modal.dart';
import 'package:kdkd_mobile/feature/child_mission/widgets/mission_filter_section.dart';
import 'package:kdkd_mobile/feature/child_mission/widgets/mission_list.dart';
import 'package:kdkd_mobile/feature/parent_mission/models/mission_model.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

class ChildMissionPage extends ConsumerStatefulWidget {
  const ChildMissionPage({super.key});

  @override
  ConsumerState<ChildMissionPage> createState() => _ChildMissionPageState();
}

class _ChildMissionPageState extends ConsumerState<ChildMissionPage> {
  int _selectedFilterIndex = 0; // 0: 진행중, 1: 완료

  // void _handleMissionTap(MissionModel mission) {
  //   CustomPopupModal.show(
  //     context: context,
  //     child: MissionDetailModal(mission: mission),
  //     buttonType: mission.missionStatus == MissionStatus.SUCCESS ? AppColors.mint : AppColors.redError,
  //     confirmText: mission.missionStatus == MissionStatus.IN_PROGRESS ? '완료' : "닫기",
  //     onConfirm: () {
  //       Navigator.pop(context);
  //     },
  //   );
  // }

  // void _handleFeatureMissionTap(MissionModel mission) {
  //   CustomPopupModal.show(
  //     context: context,
  //     child: MissionDetailModal(mission: mission),
  //     confirmText: '완료',
  //     onConfirm: () {
  //       Navigator.pop(context);
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final UiState<List<MissionModel>> missionsState = ref.watch(missionProvider);
    final UiState<Profile> profileState = ref.watch(profileProvider);

    return missionsState.when(
      idle: () => const Center(child: CircularProgressIndicator()),
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (data, isRefreshing, isIdle) {
        final List<MissionModel> filteredMissions = data.where((m) {
          final isCompleted = m.missionStatus == MissionStatus.SUCCESS;
          return _selectedFilterIndex == 0 ? !isCompleted : isCompleted;
        }).toList();

        final List<MissionModel> inProgressMissions = data
            .where(
              (m) => m.missionStatus == MissionStatus.IN_PROGRESS,
            )
            .toList();

        final MissionModel? featureMission = inProgressMissions.isNotEmpty
            ? inProgressMissions.reduce(
                (curr, next) => curr.reward >= next.reward ? curr : next,
              )
            : null;

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(missionProvider.notifier).refreshMissions();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (featureMission != null) ...[
                      FeaturedMissionCard(
                        featureMission: featureMission,
                      ),
                    ],
                    const SizedBox(height: 16),
                    MissionFilterSection(
                      selectedIndex: _selectedFilterIndex,
                      onSelect: (index) {
                        setState(() {
                          _selectedFilterIndex = index;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: MissionList(
                  filter: _selectedFilterIndex,
                  missions: filteredMissions,
                ),
              ),
            ],
          ),
        );
      },
      failure: (e, m) => _buildFailureWidget(profileState),
    );
  }

  Widget _buildFailureWidget(UiState<Profile> profileState) {
    return profileState.when(
      idle: () => _buildNetworkErrorWidget(),
      loading: () => _buildNetworkErrorWidget(),
      success: (profile, isFallback, fromCache) {
        // 부모와 연결되지 않은 경우
        if (profile.isConnected == false) {
          return _buildParentNotConnectedWidget();
        }
        // 부모와 연결되었지만 미션 로드 실패한 경우
        return _buildNetworkErrorWidget();
      },
      failure: (error, message) => _buildNetworkErrorWidget(),
    );
  }

  Widget _buildParentNotConnectedWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '부모님과 연결이 필요합니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '부모님께 코드를 요청하고\n입력하여 연결해주세요.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grayMedium,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.push(AppRoutes.childRegisterParent);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding:  EdgeInsets.symmetric(horizontal: AppConst.padding, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('코드 입력하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.redError,
          ),
          const SizedBox(height: 16),
          Text(
            '미션을 불러오는데 실패했습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '네트워크 연결을 확인하고 다시 시도해주세요.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grayMedium,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(missionProvider.notifier).fetchMissions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
