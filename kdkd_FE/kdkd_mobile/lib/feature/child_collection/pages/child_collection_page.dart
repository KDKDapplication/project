import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/button/custom_button_add.dart';
import 'package:kdkd_mobile/common/modal/custom_bottom_modal.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/child_collection/models/collection_model.dart';
import 'package:kdkd_mobile/feature/child_collection/models/create_collection_request.dart';
import 'package:kdkd_mobile/feature/child_collection/providers/collection_provider.dart';
import 'package:kdkd_mobile/feature/child_collection/widgets/collection_add_form_1.dart';
import 'package:kdkd_mobile/feature/child_collection/widgets/collection_add_form_2.dart';
import 'package:kdkd_mobile/feature/child_mission/widgets/mission_filter_section.dart';
import 'package:kdkd_mobile/feature/parent_collection/widgets/collection_box.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

class ChildCollectionPage extends ConsumerStatefulWidget {
  const ChildCollectionPage({super.key});

  @override
  ConsumerState<ChildCollectionPage> createState() => _ChildCollectionPageState();
}

class _ChildCollectionPageState extends ConsumerState<ChildCollectionPage> {
  int _selectedFilterIndex = 0;

  // 폼 데이터 저장용 변수들
  String _boxName = '';
  String _targetAmount = '';
  String _savingAmount = '';
  String? _imageFilePath;

  @override
  void initState() {
    super.initState();
    // 페이지 진입 시 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCollections();
    });
  }

  void _loadCollections() {
    CollectionStatus status;
    switch (_selectedFilterIndex) {
      case 0:
        status = CollectionStatus.inProgress; // 진행중
        break;
      case 1:
        status = CollectionStatus.success; // 완료
        break;
      default:
        status = CollectionStatus.inProgress; // 기본값
        break;
    }
    ref.read(collectionProvider.notifier).fetchCollections(status: status);
  }

  void _showAddAccountStep1Modal() {
    // 기존 데이터로 초기화
    String tempBoxName = _boxName;
    String tempTargetAmount = _targetAmount;

    CustomBottomModal.show(
      context: context,
      confirmText: '다음',
      onConfirm: () {
        // 입력 검증
        if (tempBoxName.trim().isEmpty || tempTargetAmount.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('모든 필드를 입력해주세요.')),
          );
          return;
        }

        // 데이터 저장
        setState(() {
          _boxName = tempBoxName.trim();
          _targetAmount = tempTargetAmount.trim();
        });

        Navigator.pop(context);
        _showAddAccountStep2Modal();
      },
      child: CollectionAddForm1(
        initialBoxName: tempBoxName,
        initialTargetAmount: tempTargetAmount,
        onNameChanged: (value) {
          tempBoxName = value;
        },
        onPriceChanged: (value) {
          tempTargetAmount = value;
        },
        onBankSelected: (value) {
          // _selectedBank = value; // 사용하지 않으므로 주석 처리
        },
        onImageSelected: (String? imagePath) {
          // 이미지 선택 시 경로 저장
          setState(() {
            _imageFilePath = imagePath;
          });
        },
      ),
    );
  }

  void _showAddAccountStep2Modal() {
    // 기존 저금 금액으로 초기화
    String tempSavingAmount = _savingAmount;

    CustomBottomModal.show(
      context: context,
      confirmText: '생성',
      onConfirm: () async {
        // Step2에서 입력한 저금 금액 저장
        setState(() {
          _savingAmount = tempSavingAmount.trim();
        });

        Navigator.pop(context);

        try {
          // 로딩 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('모으기 상자를 생성중입니다...')),
          );

          // API 요청 데이터 생성
          final request = CreateCollectionRequest(
            boxName: _boxName,
            saving: _parseSavingAmount(_savingAmount),
            target: _parseTargetAmount(_targetAmount),
          );

          // API 호출
          final result = await ref.read(collectionProvider.notifier).createCollection(
                request: request,
                imageFilePath: _imageFilePath,
              );

          if (result != null) {
            // 성공 시 메시지 표시 및 데이터 초기화
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$_boxName 모으기 상자가 생성되었습니다!')),
              );
            }
            _resetFormData();
          }
        } catch (e) {
          // 실패 시 에러 메시지
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('생성 실패: ${e.toString()}')),
            );
          }
        }
      },
      child: CollectionAddForm2(
        initialSavingAmount: tempSavingAmount,
        onPriceChanged: (value) {
          tempSavingAmount = value;
        },
      ),
    );
  }

  // 숫자 파싱 헬퍼 메서드들
  int _parseSavingAmount(String amount) {
    if (amount.trim().isEmpty) return 0;
    return int.tryParse(amount.replaceAll(',', '').replaceAll('원', '')) ?? 0;
  }

  int _parseTargetAmount(String amount) {
    if (amount.trim().isEmpty) return 0;
    return int.tryParse(amount.replaceAll(',', '').replaceAll('원', '')) ?? 0;
  }

  // 폼 데이터 초기화
  void _resetFormData() {
    setState(() {
      _boxName = '';
      _targetAmount = '';
      _savingAmount = '';
      _imageFilePath = null;
      // _selectedBank = null; // 사용하지 않으므로 주석 처리
    });
  }

  @override
  Widget build(BuildContext context) {
    final collectionState = ref.watch(collectionProvider);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: MissionFilterSection(
                  selectedIndex: _selectedFilterIndex,
                  onSelect: (index) {
                    setState(() {
                      _selectedFilterIndex = index;
                    });
                    _loadCollections(); // 필터 변경 시 데이터 다시 로드
                  },
                ),
              ),
            ),
            collectionState.when(
              idle: () => const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              ),
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 100),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              success: (collections, isFallback, fromCache) {
                if (collections.isEmpty) {
                  return _buildEmptyState();
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final collection = collections[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CollectionBoxItem(
                          onTap: () {
                            context.push(AppRoutes.childCollectionDetail, extra: collection.boxUuid);
                          },
                          name: collection.boxName,
                          price: collection.target,
                          saved: collection.savedAmount,
                          image: collection.imageUrl ?? 'assets/images/collection.png',
                          isHorizontal: false,
                          showProgress: true,
                          remain: collection.remain,
                        ),
                      );
                    },
                    childCount: collections.length,
                  ),
                );
              },
              failure: (error, message) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 100),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '데이터를 불러올 수 없습니다',
                          style: AppFonts.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadCollections,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 36.0,
          right: 20.0,
          child: CustomButtonAdd(onPressed: _showAddAccountStep1Modal),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppConst.padding, vertical: 100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svgs/box.svg',
                height: 80,
                width: 80,
                color: AppColors.grayMedium,
              ),
              const SizedBox(height: 24),
              Text(
                "갖고싶은 상품을 등록해\n꾸준히 목표 금액을 달성해 보세요!",
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.grayMedium,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
