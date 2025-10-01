import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/button/custom_button_Large.dart';
import 'package:kdkd_mobile/common/container/custom_container.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/auth/models/profile_model.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:kdkd_mobile/feature/child_main/models/account_info.dart';
import 'package:kdkd_mobile/feature/child_main/models/loan_info.dart';
import 'package:kdkd_mobile/feature/child_main/models/transaction.dart';
import 'package:kdkd_mobile/feature/child_main/providers/auto_transfer_provider.dart';
import 'package:kdkd_mobile/feature/child_main/providers/latest_payment_provider.dart';
import 'package:kdkd_mobile/feature/child_main/providers/transaction_provider.dart';
import 'package:kdkd_mobile/feature/child_main/widgets/child_account_card_widget.dart';
import 'package:kdkd_mobile/feature/child_main/widgets/monthly_and_expense_card_widget.dart';
import 'package:kdkd_mobile/feature/child_mission/provider/mission_provider.dart';
import 'package:kdkd_mobile/feature/child_mission/widgets/mission_list_item.dart';
import 'package:kdkd_mobile/feature/common/providers/user_account_provider.dart';
import 'package:kdkd_mobile/feature/parent_mission/models/mission_model.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

class ChildMainPage extends ConsumerStatefulWidget {
  const ChildMainPage({super.key});

  @override
  ConsumerState<ChildMainPage> createState() => _ChildMainPageState();
}

class _ChildMainPageState extends ConsumerState<ChildMainPage> {
  final PageController _missionPageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  // Account data
  AccountInfo? accountInfo;

  // Loan data
  LoanInfo? loanInfo;

  @override
  void initState() {
    super.initState();

    // 거래 내역 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      ref.read(transactionHistoryProvider.notifier).fetchTransactionHistory(),
      ref.read(profileProvider.notifier).loadProfile(),
      ref.read(userAccountProvider.notifier).loadUserAccount(),
      ref.read(autoTransferProvider.notifier).fetchAutoTransfer(),
      ref.read(childLatestPaymentProvider.notifier).getLatestPayment(),
    ]);
  }

  void _startMissionCarousel(List<MissionModel> missions) {
    _timer?.cancel();
    if (missions.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        if (_currentPage < missions.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        _missionPageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      });
    }
  }

  Widget _buildCharacterDisplay() {
    return Center(
      child: GestureDetector(
        onTap: () {
          context.push(AppRoutes.characterDisplay);
        },
        child: CustomContainer(
          height: 94,
          // width: 320,
          borderRadius: 16,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                "assets/images/background.jpg",
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black.withValues(alpha: 0.4),
              ),
              Center(
                child: Text(
                  "키덕이는 지금 . . .",
                  style: AppFonts.titleMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 36),
        CustomButtonLarge(
          text: "부모님과 연결해보세요!",
          onPressed: () {
            context.push(AppRoutes.childRegisterParent);
          },
        ),
        const SizedBox(height: 20),
        _buildCharacterDisplay(),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionHistoryProvider);
    final profileState = ref.watch(profileProvider);
    final missionState = ref.watch(missionProvider);
    final userAccount = ref.watch(userAccountProvider);
    final bool hasAccountNumber = userAccount.dataOrNull?.accountNumber != null;
    final latestPayment = ref.watch(childLatestPaymentProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 36, left: AppConst.padding, right: AppConst.padding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChildAccountCardWidget(
                      hasAccountNumber: hasAccountNumber,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 148 / 216,
                        child: MonthlyAndExpenseCardWidget(
                          latestPayment: latestPayment.dataOrNull,
                          hasAccountNumber: hasAccountNumber,
                          accountBalance: userAccount.when(
                            idle: () => null,
                            loading: () => null,
                            success: (account, isFallback, fromCache) => account.balance,
                            failure: (error, message) => null,
                          ),
                          recentTransactions: transactionState.when(
                            success: (data, isFallback, fromCache) => data.list.take(5).toList(),
                            loading: () => <Transaction>[],
                            failure: (error, message) => <Transaction>[],
                            idle: () => <Transaction>[],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (loanInfo != null)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 36),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppConst.padding),
                      child: Text(
                        "강오리님은 빌리기중입니다 남은 기간은 D-${loanInfo!.remainingDays}일 입니다",
                        style: AppFonts.thinbasic,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppConst.padding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "빌린금액",
                            style: AppFonts.titleLarge,
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Text(
                            loanInfo!.formattedLoanAmount,
                            style: AppFonts.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: (AppConst.padding)),
              sliver: SliverToBoxAdapter(
                child: profileState.when(
                  idle: () => _buildDefaultContent(),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  success: (profile, isFallback, fromCache) {
                    if (profile.r == role.CHILD && profile.isConnected != true) {
                      // 부모가 등록되지 않은 경우
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 36),
                          CustomButtonLarge(
                            text: "부모님과 연결해보세요!",
                            onPressed: () {
                              context.push(AppRoutes.childRegisterParent);
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildCharacterDisplay(),
                          const SizedBox(height: 40),
                        ],
                      );
                    } else {
                      // 부모가 등록된 경우 - 미션 컴포넌트 표시
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 36),
                          Text(
                            "미션 천국",
                            style: AppFonts.titleMedium,
                          ),
                          const SizedBox(height: 20),
                          missionState.when(
                            idle: () => const SizedBox.shrink(),
                            loading: () => const SizedBox(
                              height: 190,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            success: (missions, isFallback, fromCache) {
                              if (missions.isEmpty) {
                                // 미션이 없는 경우
                                return Container(
                                  height: 190,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "부모님께 미션을 요청해 보세요.",
                                    style: AppFonts.titleSmall.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              } else {
                                // 미션이 있는 경우 - 카루셀 시작
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _startMissionCarousel(missions);
                                });

                                return SizedBox(
                                  height: 190,
                                  child: PageView.builder(
                                    clipBehavior: Clip.none,
                                    controller: _missionPageController,
                                    itemCount: missions.length,
                                    itemBuilder: (context, index) {
                                      final mission = missions[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: MissionListItem(
                                          mission: mission,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                            failure: (error, message) => Container(
                              height: 190,
                              alignment: Alignment.center,
                              child: Text(
                                "미션을 불러올 수 없습니다.",
                                style: AppFonts.titleSmall.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildCharacterDisplay(),
                          const SizedBox(height: 40),
                        ],
                      );
                    }
                  },
                  failure: (error, message) => _buildDefaultContent(),
                ),
              ),
            ),
            // SliverToBoxAdapter(child: CharacterDisplay()),
            // const SliverToBoxAdapter(child: SizedBox(height: 36)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _missionPageController.dispose();
    super.dispose();
  }
}
