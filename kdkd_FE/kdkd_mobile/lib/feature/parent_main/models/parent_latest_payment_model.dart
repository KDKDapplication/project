import 'dart:convert';

class ParentLatestPaymentModel {
  final String childUuid;
  final String childName;
  final int accountItemSeq;
  final String merchantName;
  final int paymentBalance;
  final DateTime transactedAt;

  ParentLatestPaymentModel({
    required this.childUuid,
    required this.childName,
    required this.accountItemSeq,
    required this.merchantName,
    required this.paymentBalance,
    required this.transactedAt,
  });

  ParentLatestPaymentModel copyWith({
    String? childUuid,
    String? childName,
    int? accountItemSeq,
    String? merchantName,
    int? paymentBalance,
    DateTime? transactedAt,
  }) {
    return ParentLatestPaymentModel(
      childUuid: childUuid ?? this.childUuid,
      childName: childName ?? this.childName,
      accountItemSeq: accountItemSeq ?? this.accountItemSeq,
      merchantName: merchantName ?? this.merchantName,
      paymentBalance: paymentBalance ?? this.paymentBalance,
      transactedAt: transactedAt ?? this.transactedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'childUuid': childUuid,
      'childName': childName,
      'accountItemSeq': accountItemSeq,
      'merchantName': merchantName,
      'paymentBalance': paymentBalance,
      'transactedAt': transactedAt.millisecondsSinceEpoch,
    };
  }

  factory ParentLatestPaymentModel.fromMap(Map<String, dynamic> map) {
    return ParentLatestPaymentModel(
      childUuid: map['childUuid'] as String,
      childName: map['childName'] as String,
      accountItemSeq: map['accountItemSeq'] as int,
      merchantName: map['merchantName'] as String,
      paymentBalance: map['paymentBalance'] as int,
      transactedAt: DateTime.parse(map['transactedAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory ParentLatestPaymentModel.fromJson(String source) =>
      ParentLatestPaymentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ParentLatestPaymentModel(childUuid: $childUuid, childName: $childName, accountItemSeq: $accountItemSeq, merchantName: $merchantName, paymentBalance: $paymentBalance, transactedAt: $transactedAt)';
  }

  @override
  bool operator ==(covariant ParentLatestPaymentModel other) {
    if (identical(this, other)) return true;

    return other.childUuid == childUuid &&
        other.childName == childName &&
        other.accountItemSeq == accountItemSeq &&
        other.merchantName == merchantName &&
        other.paymentBalance == paymentBalance &&
        other.transactedAt == transactedAt;
  }

  @override
  int get hashCode {
    return childUuid.hashCode ^
        childName.hashCode ^
        accountItemSeq.hashCode ^
        merchantName.hashCode ^
        paymentBalance.hashCode ^
        transactedAt.hashCode;
  }
}
