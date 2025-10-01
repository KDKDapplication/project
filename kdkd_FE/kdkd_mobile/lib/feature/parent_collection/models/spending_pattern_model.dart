import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:kdkd_mobile/feature/parent_collection/models/spending_item.dart';

class SpendingPatternModel {
  final String? summary;
  final SpendingItem? lastData;
  final SpendingItem? thisData;

  SpendingPatternModel({
    this.summary,
    this.lastData,
    this.thisData,
  });

  SpendingPatternModel copyWith({
    String? summary,
    SpendingItem? lastData,
    SpendingItem? thisData,
  }) {
    return SpendingPatternModel(
      summary: summary ?? this.summary,
      lastData: lastData ?? this.lastData,
      thisData: thisData ?? this.thisData,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'summary': summary,
      'lastData': lastData?.toMap(),
      'thisData': thisData?.toMap(),
    };
  }

  factory SpendingPatternModel.fromMap(Map<String, dynamic> map) {
    return SpendingPatternModel(
      summary: map['summary'] as String?,
      lastData: map['lastData'] != null
          ? SpendingItem.fromMap(map['lastData'] as Map<String, dynamic>)
          : null,
      thisData: map['thisData'] != null
          ? SpendingItem.fromMap(map['thisData'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SpendingPatternModel.fromJson(String source) =>
      SpendingPatternModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'SpendingPatternModel(summary: $summary, lastData: $lastData, thisData: $thisData)';

  @override
  bool operator ==(covariant SpendingPatternModel other) {
    if (identical(this, other)) return true;

    return other.summary == summary && other.lastData == lastData && other.thisData == thisData;
  }

  @override
  int get hashCode => summary.hashCode ^ lastData.hashCode ^ thisData.hashCode;
}
