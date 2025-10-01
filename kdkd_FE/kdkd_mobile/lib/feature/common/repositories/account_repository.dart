import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:kdkd_mobile/feature/common/models/account_register_request.dart';
import 'package:kdkd_mobile/feature/common/models/account_register_response.dart';
import 'package:kdkd_mobile/feature/common/models/user_account_model.dart';

class AccountRepository {
  final Dio _dio;
  final Ref _ref;

  AccountRepository(this._dio, this._ref);

  // 🔹 API endpoints
  static const String _accountFirstPath = "/accounts/account-first";
  static const String _accountSecondPath = "/accounts/account-second";
  static const String _userAccountPath = "/accounts/me";
  static const String _accountHolderPath = "/api/banks/demand-deposit/account/holder";

  /// 아이 계좌 등록 (POST /accounts/account-first)
  Future<bool> registerChildAccount({
    required String userUuid,
    required String accountNumber,
    required String accountPassword,
    required String bankName,
  }) async {
    try {
      // 1
      final request = AccountRegisterRequest(
        userUuid: userUuid,
        accountNumber: accountNumber,
        accountPassword: accountPassword,
        bankName: bankName,
      );

      await _dio.post(
        _accountSecondPath,
        data: request.toJson(),
      );

      // 2 - 먼저 사용자 조회
      final profileState = _ref.read(profileProvider);
      final email = profileState.when(
        idle: () => '',
        loading: () => '',
        success: (profile, isFallback, fromCache) => profile.email ?? '',
        failure: (error, message) => '',
      );

      print("Email: $email");
      await _dio.get(
        "/api/ssafy/member/search",
        queryParameters: {"userEmail": email},
        // queryParameters: {"userEmail": "leejiwoo0126@gmail.com"},
      );

      // 3
      await _dio.post(_accountFirstPath, data: {"accountNumber": accountNumber});

      return true;
      // return AccountRegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e, "계좌 등록");
    } catch (e) {
      return false;
    }
  }

  /// 계좌 검증 (POST /accounts/account-second)
  Future<AccountVerificationResponse> verifyAccount({
    required String accountNumber,
  }) async {
    try {
      final request = AccountVerificationRequest(
        accountNumber: accountNumber,
      );

      final response = await _dio.post(
        _accountSecondPath,
        data: request.toJson(),
      );

      return AccountVerificationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e, "계좌 검증");
    } catch (e) {
      throw Exception("알 수 없는 에러 발생 (계좌 검증): $e");
    }
  }

  /// 사용자 계좌 정보 조회 (GET /accounts/me)
  Future<UserAccountModel?> getUserAccount() async {
    try {
      final response = await _dio.get(_userAccountPath);
      final data = Map<String, dynamic>.from(response.data);

      return UserAccountModel(
        accountNumber: data['accountNumber'],
        balance: data['balance'],
        bankName: "싸피은행",
      );
    } on DioException catch (e) {
      throw _handleDioException(e, "사용자 계좌 조회");
    } catch (e) {
      return null;
    }
  }

  /// 1원 송금
  Future<void> oneWonSend(String accountNo) async {
    try {
      await _dio.post(
        'accounts/one-won-send',
        queryParameters: {
          "accountNo": accountNo,
        },
      );
    } catch (e) {
      print('1원 송금 실패');
    }
  }

  /// 1원 송금 인증
  /// !! TODO 인증 확인 해야함 자동으로 되게
  Future<void> oneWonSendVerification(String accountNo, String authCode) async {
    try {
      await _dio.post(
        'accounts/one-won-verification',
        queryParameters: {
          "accountNo": accountNo,
          "authCode": authCode,
        },
      );
    } catch (e) {
      print('1원 송금 인증 실패');
    }
  }

  /// DioException 공통 처리
  Exception _handleDioException(DioException e, String operation) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception("$operation 실패: 연결 시간 초과");
      case DioExceptionType.sendTimeout:
        return Exception("$operation 실패: 요청 시간 초과");
      case DioExceptionType.receiveTimeout:
        return Exception("$operation 실패: 응답 시간 초과");
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? e.message;
        return Exception("$operation 실패 ($statusCode): $message");
      case DioExceptionType.cancel:
        return Exception("$operation 취소됨");
      case DioExceptionType.unknown:
        return Exception("$operation 실패: 네트워크 연결을 확인해주세요");
      default:
        return Exception("$operation 실패: ${e.message}");
    }
  }

  /// 계좌번호 포맷팅 (0000-00-0000000000)
  String formatAccountNumber(String accountNumber) {
    final numbersOnly = accountNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbersOnly.length >= 11) {
      return '${numbersOnly.substring(0, 4)}-${numbersOnly.substring(4, 6)}-${numbersOnly.substring(6)}';
    } else if (numbersOnly.length >= 6) {
      return '${numbersOnly.substring(0, 4)}-${numbersOnly.substring(4, 6)}-${numbersOnly.substring(6)}';
    } else if (numbersOnly.length >= 4) {
      return '${numbersOnly.substring(0, 4)}-${numbersOnly.substring(4)}';
    }

    return numbersOnly;
  }

  /// 계좌번호 유효성 검사
  bool isValidAccountNumber(String accountNumber) {
    final numbersOnly = accountNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return numbersOnly.length >= 10 && numbersOnly.length <= 16;
  }

  /// 비밀번호 유효성 검사 (4자리 숫자)
  bool isValidPassword(String password) {
    return RegExp(r'^\d{4}$').hasMatch(password);
  }
}
