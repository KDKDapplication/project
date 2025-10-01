import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/child_collection/models/collection_model.dart';
import 'package:kdkd_mobile/feature/child_collection/models/create_collection_request.dart';
import 'package:kdkd_mobile/feature/child_collection/repositories/collection_api.dart';

class CollectionNotifier extends StateNotifier<UiState<List<CollectionModel>>> {
  final CollectionApi api;

  CollectionNotifier(this.api) : super(const Idle());

  /// 모으기 상자 목록 최초 로딩
  Future<void> fetchCollections({CollectionStatus? status}) async {
    state = const Loading();
    try {
      List<CollectionModel> collections;

      if (status == null) {
        // 전체 조회: 진행중과 완료를 모두 가져와서 합치기
        final inProgressFuture =
            api.getCollections(boxStatus: CollectionStatus.inProgress);
        final completedFuture =
            api.getCollections(boxStatus: CollectionStatus.success);

        final results = await Future.wait([inProgressFuture, completedFuture]);
        collections = [...results[0], ...results[1]];
      } else {
        collections = await api.getCollections(boxStatus: status);
      }

      state = Success(collections);
    } catch (e) {
      state = Failure(e, message: e.toString());
    }
  }

  /// 모으기 상자 목록 새로고침
  Future<void> refreshCollections({CollectionStatus? status}) async {
    final previousData = state.dataOrNull ?? [];
    state = Refreshing(previousData);
    try {
      List<CollectionModel> collections;

      if (status == null) {
        // 전체 조회: 진행중과 완료를 모두 가져와서 합치기
        final inProgressFuture =
            api.getCollections(boxStatus: CollectionStatus.inProgress);
        final completedFuture =
            api.getCollections(boxStatus: CollectionStatus.success);

        final results = await Future.wait([inProgressFuture, completedFuture]);
        collections = [...results[0], ...results[1]];
      } else {
        collections = await api.getCollections(boxStatus: status);
      }

      state = Success(collections);
    } catch (e) {
      state = Failure(e, message: e.toString());
    }
  }

  /// 새 모으기 상자 생성
  Future<String?> createCollection({
    required CreateCollectionRequest request,
    String? imageFilePath,
  }) async {
    try {
      final result = await api.createCollection(
        request: request,
        imageFilePath: imageFilePath,
      );

      // 생성 성공 후 목록 새로고침
      await fetchCollections();

      return result;
    } catch (e) {
      // 에러 발생 시에도 상태 업데이트
      state = Failure(e, message: e.toString());
      return null;
    }
  }

  /// 모으기 상자 삭제
  Future<bool> deleteCollection(String boxUuid) async {
    try {
      await api.deleteCollection(boxUuid: boxUuid);

      // 삭제 성공 후 목록 새로고침
      await fetchCollections();

      return true;
    } catch (e) {
      // 에러 발생 시에도 상태 업데이트
      state = Failure(e, message: e.toString());
      return false;
    }
  }
}

/// 전체 모으기 상자 목록 Provider
final collectionProvider =
    StateNotifierProvider<CollectionNotifier, UiState<List<CollectionModel>>>(
        (ref) {
  final api = ref.watch(collectionApiProvider);
  return CollectionNotifier(api);
});

/// 진행중인 모으기 상자만 Provider
final inProgressCollectionProvider =
    StateNotifierProvider<CollectionNotifier, UiState<List<CollectionModel>>>(
        (ref) {
  final api = ref.watch(collectionApiProvider);
  return CollectionNotifier(api);
});

/// 완료된 모으기 상자만 Provider
final completedCollectionProvider =
    StateNotifierProvider<CollectionNotifier, UiState<List<CollectionModel>>>(
        (ref) {
  final api = ref.watch(collectionApiProvider);
  return CollectionNotifier(api);
});
