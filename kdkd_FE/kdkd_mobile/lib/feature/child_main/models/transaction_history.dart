import 'transaction.dart';

class TransactionHistory {
  final String totalCount;
  final List<Transaction> list;

  TransactionHistory({
    required this.totalCount,
    required this.list,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    final rec = json['REC'] as Map<String, dynamic>;
    return TransactionHistory(
      totalCount: rec['totalCount'] ?? '0',
      list: (rec['list'] as List<dynamic>?)
              ?.map((item) => Transaction.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'REC': {
        'totalCount': totalCount,
        'list': list.map((transaction) => transaction.toJson()).toList(),
      },
    };
  }
}