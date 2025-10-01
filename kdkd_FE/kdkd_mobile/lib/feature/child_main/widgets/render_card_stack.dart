import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/card/custom_card.dart';
import 'package:kdkd_mobile/common/card/custom_card_initial.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

class RenderCardStack extends StatelessWidget {
  const RenderCardStack({
    super.key,
    required this.stackHeight,
    required this.savingsAccounts,
    required this.onCardSwiped,
  });

  final double stackHeight;
  final List<Map<String, dynamic>> savingsAccounts;
  final VoidCallback onCardSwiped;

  @override
  Widget build(BuildContext context) {
    if (savingsAccounts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36.0),
        child: CustomCardInitial(
          onTap: () => context.push(AppRoutes.registerAccount),
        ),
      );
    } else {}

    return RawGestureDetector(
      gestures: {
        VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer(), (VerticalDragGestureRecognizer instance) {
          instance.onEnd = (details) {
            if (details.primaryVelocity! < -500) {
              onCardSwiped();
            }
          };
        }),
      },
      // onVerticalDragEnd: (details) {
      //   // 위로 스와이프하는 동작을 감지 (velocity가 음수)
      //   if (details.primaryVelocity! < -500) {
      //     onCardSwiped();
      //   }
      // },
      child: SizedBox(
        height: stackHeight, // 계산된 높이를 Stack에 적용
        child: Stack(
          children: List.generate(savingsAccounts.length, (index) {
            final account = savingsAccounts[index];

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              key: ValueKey(account['accountNumber']),
              top: (index * 16.0),
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: CustomCard(
                  onTap: () {
                    print('123');
                    context.push(AppRoutes.childMainHistory);
                  },
                  accountName: account["accountName"]!,
                  accountNumber: account["accountNumber"]!,
                  balance: account["balance"]!,
                  characterImagePath:
                      (account["characterImagePath"] as String).isEmpty ? null : account["characterImagePath"],
                  color: account["color"],
                ),
              ),
            );
          }).reversed.toList(),
        ),
      ),
    );
  }
}
