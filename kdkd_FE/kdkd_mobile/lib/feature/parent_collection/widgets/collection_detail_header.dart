import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kdkd_mobile/common/button/custom_button_round_basic.dart';
import 'package:kdkd_mobile/common/progress/custom_progress_bar.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';

class CollectionDetailHeader extends StatelessWidget {
  final Map<String, dynamic> collectionItem;
  final VoidCallback? onPressCancel;
  const CollectionDetailHeader({
    super.key,
    required this.collectionItem,
    this.onPressCancel,
  });

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount)}원';
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.grey,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.grey,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = collectionItem['name'] as String;
    final price = collectionItem['price'] as int;
    final saved = collectionItem['saved'] as int;
    final image = collectionItem['image'] as String;
    final endDate = collectionItem['endDate'] as DateTime;
    final remaining = collectionItem['remaining'] as int? ?? (price - saved);
    final progress = saved / (saved + remaining); // 전체 목표 대비 진행률

    return Column(
      children: [
        // 상품 - 배경 primary
        Container(
          height: 176,
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: AppConst.padding),
          color: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    height: 90,
                    width: 90,
                    child: _buildImage(image),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            Container(
                              width: 44.43,
                              height: 18.88,
                              decoration: BoxDecoration(
                                color: AppColors.violet,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: const Text(
                                  'D-7',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '꾸준함이 곧 선물로 돌아옵니다 🎁',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -.5,
                          ),
                        ),
                        Text(
                          '남은 금액 : ${_formatCurrency(remaining)}!',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
              CustomProgressBar(value: progress),
            ],
          ),
        ),
        SizedBox(
          height: 13,
        ),
        // 총금액, 만기일 - 배경 white
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppConst.padding, vertical: 16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '총 금액',
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.5,
                    ),
                  ),
                  Text(
                    _formatCurrency(price),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.5,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '만기일 ${DateFormat('yyyy.MM.dd').format(endDate)}',
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -.5,
                    ),
                  ),
                  CustomButtonRoundBasic(
                    onPressed: onPressCancel,
                    text: '해지',
                    width: 67,
                    height: 27,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
