// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

enum CollectionStatus {
  inProgress('IN_PROGRESS'),
  success('SUCCESS');

  const CollectionStatus(this.value);
  final String value;

  static CollectionStatus fromString(String value) {
    return CollectionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => CollectionStatus.inProgress,
    );
  }
}

class SaveBoxItemInfoList {
  final String boxPayName;
  final DateTime boxTransferDate;
  final int boxAmount;
  SaveBoxItemInfoList({
    required this.boxPayName,
    required this.boxTransferDate,
    required this.boxAmount,
  });

  SaveBoxItemInfoList copyWith({
    String? boxPayName,
    DateTime? boxTransferDate,
    int? boxAmount,
  }) {
    return SaveBoxItemInfoList(
      boxPayName: boxPayName ?? this.boxPayName,
      boxTransferDate: boxTransferDate ?? this.boxTransferDate,
      boxAmount: boxAmount ?? this.boxAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'boxPayName': boxPayName,
      'boxTransferDate': boxTransferDate.millisecondsSinceEpoch,
      'boxAmount': boxAmount,
    };
  }

  factory SaveBoxItemInfoList.fromMap(Map<String, dynamic> map) {
    return SaveBoxItemInfoList(
      boxPayName: map['boxPayName'] as String,
      boxTransferDate: map['boxTransferDate'] is String
          ? DateTime.parse(map['boxTransferDate'] as String)
          : DateTime.fromMillisecondsSinceEpoch(map['boxTransferDate'] as int),
      boxAmount: (map['boxAmount'] as num).toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory SaveBoxItemInfoList.fromJson(String source) =>
      SaveBoxItemInfoList.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SaveBoxItemInfoList(boxPayName: $boxPayName, boxTransferDate: $boxTransferDate, boxAmount: $boxAmount)';

  @override
  bool operator ==(covariant SaveBoxItemInfoList other) {
    if (identical(this, other)) return true;

    return other.boxPayName == boxPayName && other.boxTransferDate == boxTransferDate && other.boxAmount == boxAmount;
  }

  @override
  int get hashCode => boxPayName.hashCode ^ boxTransferDate.hashCode ^ boxAmount.hashCode;
}

class CollectionModel {
  final String boxUuid;
  final String boxName;
  final int remain;
  final int target;
  final DateTime createdAt;
  final CollectionStatus status;
  final String? imageUrl;
  final List<SaveBoxItemInfoList> saveBoxItemInfoList;

  const CollectionModel({
    required this.boxUuid,
    required this.boxName,
    required this.remain,
    required this.target,
    required this.createdAt,
    required this.status,
    this.imageUrl,
    this.saveBoxItemInfoList = const [],
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) => CollectionModel(
        boxUuid: json['boxUuid'] as String,
        boxName: json['boxName'] as String,
        remain: (json['remain'] as num).toInt(),
        target: (json['target'] as num).toInt(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: CollectionStatus.fromString(json['status'] as String),
        imageUrl: json['imageUrl'] as String?,
        saveBoxItemInfoList: json['saveBoxItemInfoList'] != null
            ? (json['saveBoxItemInfoList'] as List)
                .map((item) => SaveBoxItemInfoList.fromMap(item as Map<String, dynamic>))
                .toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        'boxUuid': boxUuid,
        'boxName': boxName,
        'remain': remain,
        'target': target,
        'createdAt': createdAt.toIso8601String(),
        'status': status.value,
        'imageUrl': imageUrl,
        'saveBoxItemInfoList': saveBoxItemInfoList.map((item) => item.toMap()).toList(),
      };

  /// 현재 저금된 금액 (목표 - 남은 금액)
  int get savedAmount => target - remain;

  /// 진행률 (0.0 ~ 1.0)
  double get progress {
    if (target == 0) return 0.0;
    if (remain <= 0) return 1.0;
    return savedAmount / target;
  }

  /// 완료 여부
  bool get isCompleted => status == CollectionStatus.success;

  CollectionModel copyWith({
    String? boxUuid,
    String? boxName,
    int? remain,
    int? target,
    DateTime? createdAt,
    CollectionStatus? status,
    String? imageUrl,
    List<SaveBoxItemInfoList>? saveBoxItemInfoList,
  }) {
    return CollectionModel(
      boxUuid: boxUuid ?? this.boxUuid,
      boxName: boxName ?? this.boxName,
      remain: remain ?? this.remain,
      target: target ?? this.target,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      saveBoxItemInfoList: saveBoxItemInfoList ?? this.saveBoxItemInfoList,
    );
  }

  @override
  String toString() {
    return 'CollectionModel(boxUuid: $boxUuid, boxName: $boxName, remain: $remain, target: $target, createdAt: $createdAt, status: $status, imageUrl: $imageUrl, saveBoxItemInfoList: $saveBoxItemInfoList)';
  }

  @override
  bool operator ==(covariant CollectionModel other) {
    if (identical(this, other)) return true;

    return other.boxUuid == boxUuid &&
        other.boxName == boxName &&
        other.remain == remain &&
        other.target == target &&
        other.createdAt == createdAt &&
        other.status == status &&
        other.imageUrl == imageUrl &&
        listEquals(other.saveBoxItemInfoList, saveBoxItemInfoList);
  }

  @override
  int get hashCode {
    return boxUuid.hashCode ^
        boxName.hashCode ^
        remain.hashCode ^
        target.hashCode ^
        createdAt.hashCode ^
        status.hashCode ^
        imageUrl.hashCode ^
        saveBoxItemInfoList.hashCode;
  }
}
