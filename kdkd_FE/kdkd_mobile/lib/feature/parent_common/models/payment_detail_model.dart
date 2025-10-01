// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PaymentDetailModel {
  final double latitude;
  final double longitude;
  final String categoryName;
  final String merchantName;
  final DateTime transactedAt;
  final int paymentBalance;

  const PaymentDetailModel({
    required this.latitude,
    required this.longitude,
    required this.categoryName,
    required this.merchantName,
    required this.transactedAt,
    required this.paymentBalance,
  });

  PaymentDetailModel copyWith({
    double? latitude,
    double? longitude,
    String? categoryName,
    String? merchantName,
    DateTime? transactedAt,
    int? paymentBalance,
  }) {
    return PaymentDetailModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      categoryName: categoryName ?? this.categoryName,
      merchantName: merchantName ?? this.merchantName,
      transactedAt: transactedAt ?? this.transactedAt,
      paymentBalance: paymentBalance ?? this.paymentBalance,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'categoryName': categoryName,
      'merchantName': merchantName,
      'transactedAt': transactedAt.toIso8601String(),
      'paymentBalance': paymentBalance,
    };
  }

  factory PaymentDetailModel.fromMap(Map<String, dynamic> map) {
    return PaymentDetailModel(
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      categoryName: map['categoryName'] as String,
      merchantName: map['merchantName'] as String,
      transactedAt: DateTime.parse(map['transactedAt'] as String),
      paymentBalance: map['paymentBalance'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentDetailModel.fromJson(String source) =>
      PaymentDetailModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PaymentDetailModel(latitude: $latitude, longitude: $longitude, categoryName: $categoryName, merchantName: $merchantName, transactedAt: $transactedAt, paymentBalance: $paymentBalance)';
  }

  @override
  bool operator ==(covariant PaymentDetailModel other) {
    if (identical(this, other)) return true;

    return other.latitude == latitude &&
        other.longitude == longitude &&
        other.categoryName == categoryName &&
        other.merchantName == merchantName &&
        other.transactedAt == transactedAt &&
        other.paymentBalance == paymentBalance;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^
        longitude.hashCode ^
        categoryName.hashCode ^
        merchantName.hashCode ^
        transactedAt.hashCode ^
        paymentBalance.hashCode;
  }
}
