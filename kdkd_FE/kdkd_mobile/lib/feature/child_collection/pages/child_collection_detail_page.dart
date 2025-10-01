import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/modal/custom_popup_modal.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/feature/child_collection/models/collection_model.dart';
import 'package:kdkd_mobile/feature/child_collection/providers/collection_provider.dart';
import 'package:kdkd_mobile/feature/child_collection/repositories/collection_api.dart';
import 'package:kdkd_mobile/feature/parent_collection/widgets/collection_detail_header.dart';
import 'package:kdkd_mobile/feature/parent_collection/widgets/deposit_history_list.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

class ChildCollectionDetailPage extends ConsumerWidget {
  final String? boxUuid;

  const ChildCollectionDetailPage({
    super.key,
    this.boxUuid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (boxUuid == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          useBackspace: true,
          actionType: AppBarActionType.none,
        ),
        body: const Center(
          child: Text('잘못된 접근입니다.'),
        ),
      );
    }

    return FutureBuilder<CollectionModel>(
      future: ref.read(collectionApiProvider).getCollectionDetail(boxUuid!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomAppBar(
              useBackspace: true,
              actionType: AppBarActionType.none,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomAppBar(
              useBackspace: true,
              actionType: AppBarActionType.none,
            ),
            body: Center(
              child: Text('에러: ${snapshot.error}'),
            ),
          );
        }

        final collection = snapshot.data!;

        // 기존 형식으로 변환 (CollectionDetailHeader가 기대하는 형식)
        final collectionItem = {
          'name': collection.boxName,
          'price': collection.remain, // 현재까지 모은 금액 (총 금액으로 표시)
          'saved': collection.remain, // 현재까지 모은 금액
          'image': collection.imageUrl ?? 'assets/images/collection.png',
          'endDate': DateTime(2025, 12, 31), // TODO: API에서 endDate 제공 시 수정
          'remaining': collection.target - collection.remain, // 남은 금액
        };

        // saveBoxItemInfoList를 depositHistory 형식으로 변환
        final depositHistory = collection.saveBoxItemInfoList
            .map(
              (item) => {
                'date':
                    '${item.boxTransferDate.month.toString().padLeft(2, '0')}.${item.boxTransferDate.day.toString().padLeft(2, '0')}',
                'amount': item.boxAmount,
                'memo': item.boxPayName,
              },
            )
            .toList();

        void showCancelModal() {
          CustomPopupModal.show(
            popupType: PopupType.two,
            context: context,
            confirmText: '더모으기',
            confirmText2: '해지하기',
            onConfirm: () {
              Navigator.pop(context); // 모달 닫기
            },
            onConfirm2: () async {
              final success = await ref.read(collectionProvider.notifier).deleteCollection(boxUuid!);
              Navigator.pop(context); // 모달 닫기

              if (success) {
                context.pop(); // 상세 페이지 닫기
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('모으기 상자가 해지되었습니다')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('해지에 실패했습니다')),
                );
              }
            },
            child: CancelModal(),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            useBackspace: true,
            actionType: AppBarActionType.edit,
            onActionPressed: () {
              context.push(AppRoutes.childCollectionEdit, extra: collection);
            },
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                backgroundColor: AppColors.grayBG,
                elevation: 0,
                titleSpacing: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: CollectionDetailHeader(
                    collectionItem: collectionItem,
                    onPressCancel: showCancelModal,
                  ),
                ),
                toolbarHeight: 320,
              ),
              DepositHistoryList(depositHistory: depositHistory),
            ],
          ),
        );
      },
    );
  }
}

class CancelModal extends StatelessWidget {
  const CancelModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '정말 해지 하시겠어요?',
          style: AppFonts.displaySmall.copyWith(color: AppColors.primary),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          '만기까지 8일 남았아요!',
          style: AppFonts.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '조금만 더 모으면 갖고 싶은 건 가까워지고,\n습관은 평생 힘이 돼요.',
          style: AppFonts.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
