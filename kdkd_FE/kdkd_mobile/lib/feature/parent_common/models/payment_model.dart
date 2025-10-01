class PaymentModel {
  final int accountItemSeq;
  final String merchantName;
  final int paymentBalance;
  final DateTime transactedAt;

  const PaymentModel({
    required this.accountItemSeq,
    required this.merchantName,
    required this.paymentBalance,
    required this.transactedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        accountItemSeq: (json['accountItemSeq'] as num).toInt(),
        merchantName: json['merchantName'] as String,
        paymentBalance: (json['paymentBalance'] as num).toInt(),
        transactedAt: DateTime.parse(json['transactedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'accountItemSeq': accountItemSeq,
        'merchantName': merchantName,
        'paymentBalance': paymentBalance,
        'transactedAt': transactedAt.toIso8601String(),
      };
}

class PaymentResponse {
  final int totalPages;
  final String childUuid;
  final List<PaymentModel> payments;

  const PaymentResponse({
    required this.totalPages,
    required this.childUuid,
    required this.payments,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      totalPages: json['totalPages'] as int,
      childUuid: json['childUuid'] as String,
      payments: (json['payments'] as List<dynamic>)
          .map((item) => PaymentModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPages': totalPages,
      'childUuid': childUuid,
      'payments': payments.map((payment) => payment.toJson()).toList(),
    };
  }
}