import 'dart:convert';

enum MissionStatus { SUCCESS, IN_PROGRESS }

extension InProgressExtension on MissionStatus {
  String toValue() {
    return toString().split('.').last;
  }

  static MissionStatus fromValue(String value) {
    try {
      return MissionStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == value.toUpperCase(),
      );
    } catch (e) {
      return MissionStatus.IN_PROGRESS;
    }
  }
}

class MissionModel {
  final String missionUuid;
  final String missionName;
  final MissionStatus missionStatus;
  final String missionContent;
  final int reward;
  final DateTime createdAt;
  final DateTime endAt;

  MissionModel({
    required this.missionUuid,
    required this.missionName,
    required this.missionStatus,
    required this.missionContent,
    required this.reward,
    required this.createdAt,
    required this.endAt,
  });

  MissionModel copyWith({
    String? missionUuid,
    String? missionName,
    MissionStatus? missionStatus,
    String? missionContent,
    int? reward,
    DateTime? createdAt,
    DateTime? endAt,
  }) {
    return MissionModel(
      missionUuid: missionUuid ?? this.missionUuid,
      missionName: missionName ?? this.missionName,
      missionStatus: missionStatus ?? this.missionStatus,
      missionContent: missionContent ?? this.missionContent,
      reward: reward ?? this.reward,
      createdAt: createdAt ?? this.createdAt,
      endAt: endAt ?? this.endAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'missionUuid': missionUuid,
      'missionName': missionName,
      'missionStatus': missionStatus.toValue(),
      'missionContent': missionContent,
      'reward': reward,
      'createdAt': createdAt.toIso8601String(), // ✅ string 형태로 저장
      'endAt': endAt.toIso8601String(), // 추가: 종료 날짜
    };
  }

  factory MissionModel.fromMap(Map<String, dynamic> map) {
    return MissionModel(
      missionUuid: map['missionUuid'] as String,
      missionName: (map['missionTitle'] ?? map['missionName']) as String,
      missionStatus: InProgressExtension.fromValue(map['missionStatus'] as String),
      missionContent: map['missionContent'] as String,
      reward: map['reward'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      endAt: DateTime.parse(map['endAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory MissionModel.fromJson(String source) => MissionModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'MissionModel(missionUuid: $missionUuid, missionName: $missionName, missionStatus: $missionStatus, missionContent: $missionContent, reward: $reward, createdAt: $createdAt, endAt: $endAt)';
  }

  @override
  bool operator ==(covariant MissionModel other) {
    if (identical(this, other)) return true;

    return other.missionUuid == missionUuid &&
        other.missionName == missionName &&
        other.missionStatus == missionStatus &&
        other.missionContent == missionContent &&
        other.reward == reward &&
        other.createdAt == createdAt &&
        other.endAt == endAt;
  }

  @override
  int get hashCode {
    return missionUuid.hashCode ^
        missionName.hashCode ^
        missionStatus.hashCode ^
        missionContent.hashCode ^
        reward.hashCode ^
        createdAt.hashCode ^
        endAt.hashCode;
  }
}
