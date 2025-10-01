import 'dart:convert';

class SpendingItem {
  final int totalDays;
  final int totalAmount;
  final int etcAmount;
  final int transportationAmount;
  final int stationaryStoreAmount;
  final int convenienceStoreAmount;
  final int restaurantAmount;
  final int cultureAmount;
  final int cafeAmount;

  SpendingItem({
    required this.totalDays,
    required this.totalAmount,
    required this.etcAmount,
    required this.transportationAmount,
    required this.stationaryStoreAmount,
    required this.convenienceStoreAmount,
    required this.restaurantAmount,
    required this.cultureAmount,
    required this.cafeAmount,
  });

  SpendingItem copyWith({
    int? totalDays,
    int? totalAmount,
    int? etcAmount,
    int? transportationAmount,
    int? stationaryStoreAmount,
    int? convenienceStoreAmount,
    int? restaurantAmount,
    int? cultureAmount,
    int? cafeAmount,
  }) {
    return SpendingItem(
      totalDays: totalDays ?? this.totalDays,
      totalAmount: totalAmount ?? this.totalAmount,
      etcAmount: etcAmount ?? this.etcAmount,
      transportationAmount: transportationAmount ?? this.transportationAmount,
      stationaryStoreAmount: stationaryStoreAmount ?? this.stationaryStoreAmount,
      convenienceStoreAmount: convenienceStoreAmount ?? this.convenienceStoreAmount,
      restaurantAmount: restaurantAmount ?? this.restaurantAmount,
      cultureAmount: cultureAmount ?? this.cultureAmount,
      cafeAmount: cafeAmount ?? this.cafeAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'totalDays': totalDays,
      'totalAmount': totalAmount,
      'etcAmount': etcAmount,
      'transportationAmount': transportationAmount,
      'stationaryStoreAmount': stationaryStoreAmount,
      'convenienceStoreAmount': convenienceStoreAmount,
      'restaurantAmount': restaurantAmount,
      'cultureAmount': cultureAmount,
      'cafeAmount': cafeAmount,
    };
  }

  factory SpendingItem.fromMap(Map<String, dynamic> map) {
    return SpendingItem(
      totalDays: map['totalDays'] as int,
      totalAmount: map['totalAmount'] as int,
      etcAmount: map['etcAmount'] as int,
      transportationAmount: map['transportationAmount'] as int,
      stationaryStoreAmount: map['stationaryStoreAmount'] as int,
      convenienceStoreAmount: map['convenienceStoreAmount'] as int,
      restaurantAmount: map['restaurantAmount'] as int,
      cultureAmount: map['cultureAmount'] as int,
      cafeAmount: map['cafeAmount'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory SpendingItem.fromJson(String source) => SpendingItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SpendingItem(totalDays: $totalDays, totalAmount: $totalAmount, etcAmount: $etcAmount, transportationAmount: $transportationAmount, stationaryStoreAmount: $stationaryStoreAmount, convenienceStoreAmount: $convenienceStoreAmount, restaurantAmount: $restaurantAmount, cultureAmount: $cultureAmount, cafeAmount: $cafeAmount)';
  }

  @override
  bool operator ==(covariant SpendingItem other) {
    if (identical(this, other)) return true;

    return other.totalDays == totalDays &&
        other.totalAmount == totalAmount &&
        other.etcAmount == etcAmount &&
        other.transportationAmount == transportationAmount &&
        other.stationaryStoreAmount == stationaryStoreAmount &&
        other.convenienceStoreAmount == convenienceStoreAmount &&
        other.restaurantAmount == restaurantAmount &&
        other.cultureAmount == cultureAmount &&
        other.cafeAmount == cafeAmount;
  }

  @override
  int get hashCode {
    return totalDays.hashCode ^
        totalAmount.hashCode ^
        etcAmount.hashCode ^
        transportationAmount.hashCode ^
        stationaryStoreAmount.hashCode ^
        convenienceStoreAmount.hashCode ^
        restaurantAmount.hashCode ^
        cultureAmount.hashCode ^
        cafeAmount.hashCode;
  }
}
