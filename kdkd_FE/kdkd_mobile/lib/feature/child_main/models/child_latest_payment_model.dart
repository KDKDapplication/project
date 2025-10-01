import 'dart:convert';

class ChildLatestPaymentModel {
  final String childUuid;
  final String childName;
  final int accountItemSeq;
  final String merchantName;
  final int paymentBalance;
  final DateTime transactedAt;

  ChildLatestPaymentModel({
    required this.childUuid,
    required this.childName,
    required this.accountItemSeq,
    required this.merchantName,
    required this.paymentBalance,
    required this.transactedAt,
  });

  ChildLatestPaymentModel copyWith({
    String? childUuid,
    String? childName,
    int? accountItemSeq,
    String? merchantName,
    int? paymentBalance,
    DateTime? transactedAt,
  }) {
    return ChildLatestPaymentModel(
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

  factory ChildLatestPaymentModel.fromMap(Map<String, dynamic> map) {
    return ChildLatestPaymentModel(
      childUuid: map['childUuid'] as String,
      childName: map['childName'] as String,
      accountItemSeq:
          map['accountItemSeq'] is int ? map['accountItemSeq'] as int : int.parse(map['accountItemSeq'].toString()),
      merchantName: map['merchantName'] as String,
      paymentBalance:
          map['paymentBalance'] is int ? map['paymentBalance'] as int : int.parse(map['paymentBalance'].toString()),
      transactedAt: DateTime.parse(map['transactedAt'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChildLatestPaymentModel.fromJson(String source) =>
      ChildLatestPaymentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChildLatestPaymentModel(childUuid: $childUuid, childName: $childName, accountItemSeq: $accountItemSeq, merchantName: $merchantName, paymentBalance: $paymentBalance, transactedAt: $transactedAt)';
  }

  @override
  bool operator ==(covariant ChildLatestPaymentModel other) {
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
