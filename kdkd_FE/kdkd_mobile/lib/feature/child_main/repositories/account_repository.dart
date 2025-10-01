import 'package:dio/dio.dart';

import '../models/account_balance.dart';
import '../models/account_info.dart';

class AccountRepository {
  final Dio _dio;

  AccountRepository(this._dio);

  // 🔹 API path를 상수로 관리
  static const String _accountsPath = "/accounts";

  /// 계좌 기본 정보 목록 조회 (GET /accounts)
  Future<List<AccountInfo>> fetchAccounts() async {
    try {
      final response = await _dio.get(_accountsPath);
      final data = response.data as List<dynamic>;
      return data.map((json) => AccountInfo.fromJson(json)).toList();
    } on DioException catch (e) {
      // DioError → DioException (dio 5.x 부터 이름 변경됨)
      throw Exception("계좌 목록 불러오기 실패: ${e.message}");
    } catch (e) {
      throw Exception("알 수 없는 에러 발생 (계좌 목록 조회): $e");
    }
  }

  /// 특정 계좌 잔액 조회 (GET /accounts/{accountNumber}/balance)
  Future<AccountBalance> fetchBalance(String accountNumber) async {
    try {
      final response = await _dio.get("$_accountsPath/$accountNumber/balance");
      return AccountBalance.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception("잔액 조회 실패 (계좌번호: $accountNumber): ${e.message}");
    } catch (e) {
      throw Exception("알 수 없는 에러 발생 (잔액 조회): $e");
    }
  }
}
