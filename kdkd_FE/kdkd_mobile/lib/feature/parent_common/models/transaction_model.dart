import 'dart:convert';

/// 통합된 결제/거래 모델
class TransactionModel {
  final String transactionId;
  final String merchantName;
  final int amount;
  final DateTime transactionDateTime;
  final TransactionType type;
  final String? categoryName;
  final String? description;

  const TransactionModel({
    required this.transactionId,
    required this.merchantName,
    required this.amount,
    required this.transactionDateTime,
    required this.type,
    this.categoryName,
    this.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        transactionId: json['accountItemSeq']?.toString() ?? json['paymentUuid'] as String,
        merchantName: json['merchantName'] as String,
        amount: (json['paymentBalance'] ?? json['price']) as int,
        transactionDateTime: _parseDateTime(json),
        type: TransactionType.payment,
        categoryName: json['categoryName'] as String?,
        description: json['description'] as String?,
      );

  static DateTime _parseDateTime(Map<String, dynamic> json) {
    if (json['transactedAt'] != null) {
      return DateTime.parse(json['transactedAt'] as String);
    } else if (json['createdAt'] != null) {
      return DateTime.parse(json['createdAt'] as String);
    } else if (json['transactionDate'] != null && json['transactionTime'] != null) {
      final dateStr = json['transactionDate'] as String;
      final timeStr = json['transactionTime'] as String;

      final dateParts = dateStr.split('-').map(int.parse).toList();
      final year = dateParts[0], month = dateParts[1], day = dateParts[2];

      final hour = int.parse(timeStr.substring(0, 2));
      final minute = int.parse(timeStr.substring(2, 4));
      final second = int.parse(timeStr.substring(4, 6));

      return DateTime(year, month, day, hour, minute, second);
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'transactionId': transactionId,
        'merchantName': merchantName,
        'amount': amount,
        'transactionDateTime': transactionDateTime.toIso8601String(),
        'type': type.name,
        'categoryName': categoryName,
        'description': description,
      };

  TransactionModel copyWith({
    String? transactionId,
    String? merchantName,
    int? amount,
    DateTime? transactionDateTime,
    TransactionType? type,
    String? categoryName,
    String? description,
  }) {
    return TransactionModel(
      transactionId: transactionId ?? this.transactionId,
      merchantName: merchantName ?? this.merchantName,
      amount: amount ?? this.amount,
      transactionDateTime: transactionDateTime ?? this.transactionDateTime,
      type: type ?? this.type,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(transactionId: $transactionId, merchantName: $merchantName, amount: $amount, transactionDateTime: $transactionDateTime, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel &&
        other.transactionId == transactionId &&
        other.merchantName == merchantName &&
        other.amount == amount &&
        other.transactionDateTime == transactionDateTime &&
        other.type == type;
  }

  @override
  int get hashCode {
    return transactionId.hashCode ^
        merchantName.hashCode ^
        amount.hashCode ^
        transactionDateTime.hashCode ^
        type.hashCode;
  }
}

/// 상세 거래 정보 모델
class TransactionDetailModel extends TransactionModel {
  final double? latitude;
  final double? longitude;
  final String? storeAddress;
  final String? childName;

  const TransactionDetailModel({
    required super.transactionId,
    required super.merchantName,
    required super.amount,
    required super.transactionDateTime,
    required super.type,
    super.categoryName,
    super.description,
    this.latitude,
    this.longitude,
    this.storeAddress,
    this.childName,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    final base = TransactionModel.fromJson(json);
    return TransactionDetailModel(
      transactionId: base.transactionId,
      merchantName: json['storeName'] ?? base.merchantName,
      amount: base.amount,
      transactionDateTime: base.transactionDateTime,
      type: base.type,
      categoryName: base.categoryName,
      description: base.description,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      storeAddress: json['storeAddress'] as String?,
      childName: json['childName'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'latitude': latitude,
        'longitude': longitude,
        'storeAddress': storeAddress,
        'childName': childName,
      };

  @override
  TransactionDetailModel copyWith({
    String? transactionId,
    String? merchantName,
    int? amount,
    DateTime? transactionDateTime,
    TransactionType? type,
    String? categoryName,
    String? description,
    double? latitude,
    double? longitude,
    String? storeAddress,
    String? childName,
  }) {
    return TransactionDetailModel(
      transactionId: transactionId ?? this.transactionId,
      merchantName: merchantName ?? this.merchantName,
      amount: amount ?? this.amount,
      transactionDateTime: transactionDateTime ?? this.transactionDateTime,
      type: type ?? this.type,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      storeAddress: storeAddress ?? this.storeAddress,
      childName: childName ?? this.childName,
    );
  }
}

/// 거래 타입 열거형
enum TransactionType {
  payment,
  allowance,
  loan,
  deposit,
  withdrawal;

  String get displayName {
    switch (this) {
      case TransactionType.payment:
        return '결제';
      case TransactionType.allowance:
        return '용돈';
      case TransactionType.loan:
        return '대출';
      case TransactionType.deposit:
        return '입금';
      case TransactionType.withdrawal:
        return '출금';
    }
  }
}

/// 거래 응답 모델
class TransactionResponse {
  final int totalPages;
  final String childUuid;
  final List<TransactionModel> transactions;

  const TransactionResponse({
    required this.totalPages,
    required this.childUuid,
    required this.transactions,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      totalPages: json['totalPages'] as int? ?? 0,
      childUuid: json['childUuid'] as String,
      transactions: (json['payments'] ?? json['transactions'] ?? [])
          .map<TransactionModel>((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPages': totalPages,
      'childUuid': childUuid,
      'transactions': transactions.map((transaction) => transaction.toJson()).toList(),
    };
  }
}