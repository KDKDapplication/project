class Transaction {
  final String transactionUniqueNo;
  final String transactionDate;
  final String transactionTime;
  final String transactionType;
  final String transactionTypeName;
  final String transactionAccountNo;
  final String transactionBalance;
  final String transactionAfterBalance;
  final String transactionSummary;
  final String transactionMemo;

  Transaction({
    required this.transactionUniqueNo,
    required this.transactionDate,
    required this.transactionTime,
    required this.transactionType,
    required this.transactionTypeName,
    required this.transactionAccountNo,
    required this.transactionBalance,
    required this.transactionAfterBalance,
    required this.transactionSummary,
    required this.transactionMemo,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionUniqueNo: json['transactionUniqueNo'] ?? '',
      transactionDate: json['transactionDate'] ?? '',
      transactionTime: json['transactionTime'] ?? '',
      transactionType: json['transactionType'] ?? '',
      transactionTypeName: json['transactionTypeName'] ?? '',
      transactionAccountNo: json['transactionAccountNo'] ?? '',
      transactionBalance: json['transactionBalance'] ?? '',
      transactionAfterBalance: json['transactionAfterBalance'] ?? '',
      transactionSummary: json['transactionSummary'] ?? '',
      transactionMemo: json['transactionMemo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionUniqueNo': transactionUniqueNo,
      'transactionDate': transactionDate,
      'transactionTime': transactionTime,
      'transactionType': transactionType,
      'transactionTypeName': transactionTypeName,
      'transactionAccountNo': transactionAccountNo,
      'transactionBalance': transactionBalance,
      'transactionAfterBalance': transactionAfterBalance,
      'transactionSummary': transactionSummary,
      'transactionMemo': transactionMemo,
    };
  }
}