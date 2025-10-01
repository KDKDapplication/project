import 'dart:convert';

class SpendingHistoryDetailModel {
  final String paymentUuid;
  final String storeName;
  final String storeAddress;
  final int price;
  final String childName;
  final DateTime createdAt;
  final double latitude;
  final double longitude;

  SpendingHistoryDetailModel({
    required this.paymentUuid,
    required this.storeName,
    required this.storeAddress,
    required this.price,
    required this.childName,
    required this.createdAt,
    required this.latitude,
    required this.longitude,
  });

  SpendingHistoryDetailModel copyWith({
    String? paymentUuid,
    String? storeName,
    String? storeAddress,
    int? price,
    String? childName,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
  }) {
    return SpendingHistoryDetailModel(
      paymentUuid: paymentUuid ?? this.paymentUuid,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      price: price ?? this.price,
      childName: childName ?? this.childName,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentUuid': paymentUuid,
      'storeName': storeName,
      'storeAddress': storeAddress,
      'price': price,
      'childName': childName,
      'createdAt': createdAt.toIso8601String().split('T').first, // yyyy-MM-dd
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory SpendingHistoryDetailModel.fromMap(Map<String, dynamic> map) {
    return SpendingHistoryDetailModel(
      paymentUuid: map['paymentUuid'] as String,
      storeName: map['storeName'] as String,
      storeAddress: map['storeAddress'] as String,
      price: map['price'] as int,
      childName: map['childName'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory SpendingHistoryDetailModel.fromJson(String source) => SpendingHistoryDetailModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SpendingHistoryDetailModel(paymentUuid: $paymentUuid, storeName: $storeName, storeAddress: $storeAddress, price: $price, childName: $childName, createdAt: $createdAt, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(covariant SpendingHistoryDetailModel other) {
    if (identical(this, other)) return true;

    return other.paymentUuid == paymentUuid &&
        other.storeName == storeName &&
        other.storeAddress == storeAddress &&
        other.price == price &&
        other.childName == childName &&
        other.createdAt == createdAt &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return paymentUuid.hashCode ^
        storeName.hashCode ^
        storeAddress.hashCode ^
        price.hashCode ^
        childName.hashCode ^
        createdAt.hashCode ^
        latitude.hashCode ^
        longitude.hashCode;
  }
}
