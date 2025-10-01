import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/parent_common/models/payment_detail_model.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/payments_detail_provider.dart';

class ParentCollectionSpendDetailPage extends ConsumerStatefulWidget {
  final String childUuid;
  final int accountItemSeq;

  const ParentCollectionSpendDetailPage({
    super.key,
    required this.childUuid,
    required this.accountItemSeq,
  });

  @override
  ConsumerState<ParentCollectionSpendDetailPage> createState() => _ParentCollectionSpendDetailPageState();
}

class _ParentCollectionSpendDetailPageState extends ConsumerState<ParentCollectionSpendDetailPage> {
  String? address;

  @override
  void initState() {
    super.initState();

    // 페이지 로드 시 상세 정보 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentDetailProvider.notifier).getPaymentDetail(
            widget.childUuid,
            widget.accountItemSeq,
          );
    });
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // 한국어 설정
      await setLocaleIdentifier('ko_KR');

      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // 더 상세한 주소 구성
        List<String> addressParts = [];

        if (place.administrativeArea?.isNotEmpty == true) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.locality?.isNotEmpty == true) {
          addressParts.add(place.locality!);
        }
        if (place.subLocality?.isNotEmpty == true) {
          addressParts.add(place.subLocality!);
        }
        if (place.thoroughfare?.isNotEmpty == true) {
          addressParts.add(place.thoroughfare!);
        }
        if (place.subThoroughfare?.isNotEmpty == true) {
          addressParts.add(place.subThoroughfare!);
        }

        String finalAddress =
            addressParts.isNotEmpty ? addressParts.join(' ') : '${place.name ?? ''} ${place.street ?? ''}'.trim();

        setState(() {
          address = finalAddress.isNotEmpty ? finalAddress : '상세 주소를 확인할 수 없습니다';
        });
      } else {
        setState(() {
          address = '주소를 찾을 수 없습니다';
        });
      }
    } catch (e) {
      setState(() {
        address = '주소를 찾을 수 없습니다';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final UiState<PaymentDetailModel> detailState = ref.watch(paymentDetailProvider);

    return Scaffold(
      appBar: CustomAppBar(
        useBackspace: true,
        actionType: AppBarActionType.none,
      ),
      body: detailState.when(
        idle: () => const Center(child: Text('Loading...')),
        loading: () => const Center(child: CircularProgressIndicator()),
        success: (data, isFallback, fromCache) {
          // 주소 정보가 없으면 역지오코딩 실행
          if (address == null) {
            _getAddressFromCoordinates(data.latitude, data.longitude);
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Map(
                  latitude: data.latitude,
                  longitude: data.longitude,
                  storeName: data.merchantName,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppConst.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.merchantName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "주소",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -.5,
                          color: AppColors.grayMedium,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address ?? '주소를 불러오는 중...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('yyyy.MM.dd HH시 mm분').format(data.transactedAt),
                        style: const TextStyle(
                          color: AppColors.grayMedium,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${NumberFormat('#,###').format(data.paymentBalance)}원',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        failure: (error, message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message ?? 'Failed to load detail',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(paymentDetailProvider.notifier).refresh(
                        widget.childUuid,
                        widget.accountItemSeq,
                      );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Map extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String storeName;

  const _Map({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.storeName,
  });

  @override
  Widget build(BuildContext context) {
    final location = NLatLng(latitude, longitude);
    final safeAreaPadding = MediaQuery.paddingOf(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConst.padding, vertical: 24),
      child: SizedBox(
        height: 320,
        child: NaverMap(
          options: NaverMapViewOptions(
            contentPadding: safeAreaPadding,
            initialCameraPosition: NCameraPosition(target: location, zoom: 16),
          ),
          onMapReady: (controller) {
            final marker = NMarker(
              id: "store_location",
              position: location,
              caption: NOverlayCaption(text: storeName),
            );
            controller.addOverlay(marker);
          },
        ),
      ),
    );
  }
}
