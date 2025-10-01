import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/feature/auth/pages/login_page.dart';
import 'package:kdkd_mobile/feature/auth/pages/sign_up_step_1_page.dart';
import 'package:kdkd_mobile/feature/auth/pages/sign_up_step_2_page.dart';
import 'package:kdkd_mobile/feature/auth/pages/sign_up_step_3_page.dart';
import 'package:kdkd_mobile/feature/child_collection/models/collection_model.dart';
import 'package:kdkd_mobile/feature/child_collection/pages/child_collection_detail_page.dart';
import 'package:kdkd_mobile/feature/child_collection/pages/child_collection_edit_page.dart';
import 'package:kdkd_mobile/feature/child_loan/pages/child_loan_page.dart';
import 'package:kdkd_mobile/feature/child_main/pages/child_main_history_page.dart';
import 'package:kdkd_mobile/feature/child_main/pages/child_register_parent.dart';
import 'package:kdkd_mobile/feature/child_main/pages/child_root_page.dart';
import 'package:kdkd_mobile/feature/child_main/widgets/character_display.dart';
import 'package:kdkd_mobile/feature/common/pages/history_page.dart';
import 'package:kdkd_mobile/feature/common/pages/notification_page.dart';
import 'package:kdkd_mobile/feature/common/pages/register_account_page.dart';
import 'package:kdkd_mobile/feature/common/pages/setting_auto_debit_page.dart';
import 'package:kdkd_mobile/feature/common/pages/setting_page.dart';
import 'package:kdkd_mobile/feature/common/pages/setting_profile_page.dart';
import 'package:kdkd_mobile/feature/common/pages/splash_page.dart';
import 'package:kdkd_mobile/feature/parent_collection/pages/parent_collection_analysis_page.dart';
import 'package:kdkd_mobile/feature/parent_collection/pages/parent_collection_detail_page.dart';
import 'package:kdkd_mobile/feature/parent_collection/pages/parent_collection_history_page.dart';
import 'package:kdkd_mobile/feature/parent_collection/pages/parent_collection_spend_detail_page.dart';
import 'package:kdkd_mobile/feature/parent_main/pages/parent_main_allowance_page.dart';
import 'package:kdkd_mobile/feature/parent_main/pages/parent_main_create_code_page.dart';
import 'package:kdkd_mobile/feature/parent_main/pages/parent_main_history_page.dart';
import 'package:kdkd_mobile/feature/parent_main/pages/parent_root_page.dart';
import 'package:kdkd_mobile/feature/pay/pages/pay_page.dart';
import 'package:kdkd_mobile/feature/pay/pages/qr_scanner_page.dart';

class AppRoutes {
  static const home = '/';
  static const login = '/auth/login';
  static const signUpStep1 = '/auth/sign-up/1';
  static const signUpStep2 = '/auth/sign-up/2';
  static const signUpStep3 = '/auth/sign-up/3';
  static const splash = '/splash';
  static const notification = '/notification';

  static const parentRoot = '/parent';
  static const childRoot = '/child';

  static const history = '/history';

  static const parentMainCreateCode = '/parent/create-code';
  static const parentMainHistory = '/parent/history';
  static const parentMainAllowance = '/parent/allowance';

  static const parentMission = '/parent/mission';
  static const parentCollectionDetail = '/parent/collection/detail';
  static const parentCollectionHistory = '/parent/collection/history';
  static const parentCollectionSpendDetail = '/parent/collection/spend/detail';
  static const parentCollectionAnalysis = '/parent/collection/analysis';

  static const childMainHistory = '/child/history';
  static const childCollectionDetail = '/child/collection/detail';
  static const childCollectionEdit = '/child/collection/edit';
  static const childLoanPage = '/child/loan';
  static const childRegisterParent = '/child/register-parent';

  static const qrScnnerPage = '/qr-scanner';

  static const registerAccount = '/register/account';

  static const characterDisplay = '/characterdisplay';

  static const setting = '/setting';
  static const settingAutoDebit = '/setting/auto_debit';
  static const settingProfile = '/setting/profile';

  static const pay = '/pay';

  static const test = '/test';
}

/// 공통 전환: 기본 슬라이드
CustomTransitionPage<T> _slidePage<T>({
  required Widget child,
  required LocalKey key,
  Offset begin = const Offset(1, 0), // 오른쪽 → 왼쪽
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: begin, end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

/// 페이드 전환 (원하면 라우트별로 사용)
CustomTransitionPage<T> _bottomUpPage<T>({
  required Widget child,
  required LocalKey key,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(0, 1), // 아래에서 시작 (y=1)
        end: Offset.zero, // 원래 위치 (y=0)
      ).chain(CurveTween(curve: Curves.easeInOut));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (context, state) => _slidePage(child: const LoginPage(), key: state.pageKey),
    ),
    GoRoute(
      path: AppRoutes.signUpStep1,
      pageBuilder: (context, state) => _slidePage(child: const SignUpStep1Page(), key: state.pageKey),
    ),
    GoRoute(
      path: AppRoutes.signUpStep2,
      pageBuilder: (context, state) => _slidePage(child: const SignUpStep2Page(), key: state.pageKey),
    ),
    GoRoute(
      path: AppRoutes.signUpStep3,
      pageBuilder: (context, state) => _slidePage(child: const SignUpStep3Page(), key: state.pageKey),
    ),
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (context, state) => _slidePage(child: const SplashPage(), key: state.pageKey),
    ),
    GoRoute(
      path: AppRoutes.notification,
      pageBuilder: (context, state) => _slidePage(child: const NotificationPage(), key: state.pageKey),
    ),
    GoRoute(
      path: AppRoutes.history,
      pageBuilder: (context, state) => _slidePage(child: const HistoryPage(), key: state.pageKey),
    ),
    GoRoute(
      path: AppRoutes.parentRoot,
      pageBuilder: (context, state) => _slidePage(child: const ParentRootPage(), key: state.pageKey),
    ),
    GoRoute(
      path: AppRoutes.registerAccount,
      pageBuilder: (context, state) => _slidePage(
        child: const RegisterAccountPage(),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.parentMainCreateCode,
      pageBuilder: (context, state) => _slidePage(
        child: const ParentMainCreateCodePage(),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.parentMainHistory,
      pageBuilder: (context, state) => _slidePage(
        child: ParentMainHistoryPage(
          childUuid: state.extra as String,
        ),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.parentMainAllowance,
      pageBuilder: (context, state) => _slidePage(
        child: ParentMainAllowancePage(),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.parentCollectionDetail,
      pageBuilder: (context, state) => _slidePage(
        child: const ParentCollectionDetailPage(),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.parentCollectionHistory,
      pageBuilder: (context, state) => _slidePage(
        child: ParentCollectionHistoryPage(
          childUuid: state.extra as String,
        ),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.parentCollectionSpendDetail,
      pageBuilder: (context, state) {
        final childUuid = state.uri.queryParameters['childUuid'] ?? '';

        final accountItemSeqStr = state.uri.queryParameters['accountItemSeq'] ?? '0';
        final accountItemSeq = int.tryParse(accountItemSeqStr) ?? 0;

        return _slidePage(
          child: ParentCollectionSpendDetailPage(
            childUuid: childUuid,
            accountItemSeq: accountItemSeq,
          ),
          key: state.pageKey,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.parentCollectionAnalysis,
      pageBuilder: (context, state) => _slidePage(
        child: const ParentCollectionAnalysisPage(),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.childRoot,
      pageBuilder: (context, state) => _slidePage(
        child: const ChildRootPage(),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.childMainHistory,
      pageBuilder: (context, state) => _slidePage(
        child: const ChildMainHistoryPage(),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.childCollectionDetail,
      pageBuilder: (context, state) => _slidePage(
        child: ChildCollectionDetailPage(
          boxUuid: state.extra as String?,
        ),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.childCollectionEdit,
      pageBuilder: (context, state) => _slidePage(
        child: ChildCollectionEditPage(
          collection: state.extra as CollectionModel,
        ),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.childLoanPage,
      pageBuilder: (context, state) => _slidePage(
        child: const ChildLoanPage(),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.characterDisplay,
      pageBuilder: (context, state) => _bottomUpPage(
        child: const CharacterDisplay(),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.childRegisterParent,
      pageBuilder: (context, state) => _slidePage(
        child: const ChildRegisterParent(),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.setting,
      pageBuilder: (context, state) => _slidePage(
        child: const SettingPage(),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.settingAutoDebit,
      pageBuilder: (context, state) => _slidePage(
        child: const SettingAutoDebitPage(),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.settingProfile,
      pageBuilder: (context, state) => _slidePage(
        child: const SettingProfilePage(),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.qrScnnerPage,
      pageBuilder: (context, state) => _slidePage(
        child: const QrScannerPage(),
        key: state.pageKey,
      ),
    ),
    GoRoute(
      path: AppRoutes.pay,
      pageBuilder: (context, state) => _bottomUpPage(child: const PayPage(), key: state.pageKey),
    ),
  ],
);
