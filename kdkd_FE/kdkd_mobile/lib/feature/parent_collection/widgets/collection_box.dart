import 'package:flutter/material.dart';
import 'package:kdkd_mobile/common/progress/custom_progress_bar.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';

class CollectionBoxItem extends StatelessWidget {
  final String name;
  final int price;
  final int saved;
  final String image;
  final bool isHorizontal;
  final bool showProgress;
  final VoidCallback onTap;
  final int? remain;

  const CollectionBoxItem({
    super.key,
    required this.name,
    required this.price,
    required this.saved,
    required this.image,
    this.isHorizontal = true,
    this.showProgress = false,
    required this.onTap,
    this.remain,
  });

  @override
  Widget build(BuildContext context) {
    final progress = remain! / price;
    final remaining = remain ?? (price - saved);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 145,
        margin: isHorizontal
            ? const EdgeInsets.only(right: 8)
            : EdgeInsets.symmetric(
                horizontal: AppConst.padding,
              ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xffF4F4F4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    height: 90,
                    width: 90,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: image.startsWith('http')
                          ? Image.network(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/collection.png'),
                            )
                          : Image.asset(
                              image,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
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
                        Text(
                          '꾸준함이 곧 선물로 돌아옵니다 🎁',
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '남은 금액 : ${(price - remaining).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원!',
                              style: const TextStyle(
                                color: AppColors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showProgress)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: CustomProgressBar(value: progress),
              ),
          ],
        ),
      ),
    );
  }
}
