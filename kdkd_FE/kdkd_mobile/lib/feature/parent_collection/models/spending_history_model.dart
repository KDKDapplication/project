import 'dart:convert';

class SpendingHistoryModel {
  final String accountItemSeq;
  final String merchantName;
  final int paymentBalance;
  final DateTime transactionDateTime;

  SpendingHistoryModel({
    required this.accountItemSeq,
    required this.merchantName,
    required this.paymentBalance,
    required this.transactionDateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountItemSeq': accountItemSeq,
      'merchantName': merchantName,
      'paymentBalance': paymentBalance,
      'transactionDate': transactionDateTime.toIso8601String().split('T').first,
      'transactionTime': transactionDateTime.toIso8601String().split('T').last.replaceAll(":", "").substring(0, 6),
    };
  }

  factory SpendingHistoryModel.fromMap(Map<String, dynamic> map) {
    // "2025-07-23"
    final dateStr = map['transactionDate'] as String;
    // "080245"
    final timeStr = map['transactionTime'] as String;

    final dateParts = dateStr.split('-').map(int.parse).toList();
    final year = dateParts[0], month = dateParts[1], day = dateParts[2];

    final hour = int.parse(timeStr.substring(0, 2));
    final minute = int.parse(timeStr.substring(2, 4));
    final second = int.parse(timeStr.substring(4, 6));

    final dateTime = DateTime(year, month, day, hour, minute, second);

    return SpendingHistoryModel(
      accountItemSeq: map['accountItemSeq'] as String,
      merchantName: map['merchantName'] as String,
      paymentBalance: map['paymentBalance'] as int,
      transactionDateTime: dateTime,
    );
  }

  String toJson() => json.encode(toMap());

  factory SpendingHistoryModel.fromJson(String source) => SpendingHistoryModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SpendingHistoryModel(accountItemSeq: $accountItemSeq, merchantName: $merchantName, paymentBalance: $paymentBalance, transactionDateTime: $transactionDateTime)';
  }
}
