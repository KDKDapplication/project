import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kdkd_mobile/feature/auth/providers/auth_provider.dart';
import 'package:kdkd_mobile/feature/auth/repositories/auth_api.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Color(0xFF9B6BFF),
      body: Stack(
        children: [
          Center(
            child: Text(
              "키득키득",
              style: TextStyle(
                fontFamily: "Chab",
                color: Colors.white,
                fontSize: 54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: 60,
            right: 60,
            child: GestureDetector(
              onTap: () {
                ref.read(authStateProvider.notifier).login(SocialType.google, context);
              },
              child: Container(
                width: 335,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/svgs/google.svg',
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "구글로 시작하기",
                      style: TextStyle(
                        fontFamily: "Pretendard",
                        color: Color(0xFF191919),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     Center(
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Text(
      //             "키득키득",
      //             style: TextStyle(
      //               fontFamily: "Chab",
      //               color: Colors.white,
      //               fontSize: 54,
      //               fontWeight: FontWeight.w500,
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //     SizedBox(height: 178),
      //     GestureDetector(
      //       onTap: () {
      //         ref.read(authStateProvider.notifier).login(SocialType.google, context);
      //       },
      //       child: Container(
      //         width: 335,
      //         height: 52,
      //         decoration: BoxDecoration(
      //           color: Colors.white,
      //           borderRadius: BorderRadius.circular(10),
      //         ),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             SvgPicture.asset(
      //               'assets/svgs/google.svg',
      //               width: 24,
      //               height: 24,
      //             ),
      //             SizedBox(width: 8),
      //             Text(
      //               "구글로 시작하기",
      //               style: TextStyle(
      //                 fontFamily: "Pretendard",
      //                 color: Color(0xFF191919),
      //                 fontSize: 16,
      //                 fontWeight: FontWeight.w600,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //     SizedBox(height: 158),
      //   ],
      // ),
    );
  }
}
