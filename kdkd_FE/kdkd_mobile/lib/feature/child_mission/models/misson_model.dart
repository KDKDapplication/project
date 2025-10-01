enum BoxStatus {
  IN_PROGRESS,
  SUCCESS,
}

class MissionModel {
  final String boxUuid;
  final String boxName;
  final int remain;
  final int target;
  final DateTime createdAt;
  final BoxStatus status;
  final String? imageUrl;

  const MissionModel({
    required this.boxUuid,
    required this.boxName,
    required this.remain,
    required this.target,
    required this.createdAt,
    required this.status,
    this.imageUrl,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      boxUuid: json['boxUuid'] as String,
      boxName: json['boxName'] as String,
      remain: json['remain'] as int,
      target: json['target'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: BoxStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BoxStatus.IN_PROGRESS,
      ),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'boxUuid': boxUuid,
      'boxName': boxName,
      'remain': remain,
      'target': target,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'imageUrl': imageUrl,
    };
  }

  MissionModel copyWith({
    String? boxUuid,
    String? boxName,
    int? remain,
    int? target,
    DateTime? createdAt,
    BoxStatus? status,
    String? imageUrl,
  }) {
    return MissionModel(
      boxUuid: boxUuid ?? this.boxUuid,
      boxName: boxName ?? this.boxName,
      remain: remain ?? this.remain,
      target: target ?? this.target,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'MissionModel(boxUuid: $boxUuid, boxName: $boxName, remain: $remain, target: $target, createdAt: $createdAt, status: $status, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MissionModel &&
        other.boxUuid == boxUuid &&
        other.boxName == boxName &&
        other.remain == remain &&
        other.target == target &&
        other.createdAt == createdAt &&
        other.status == status &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return boxUuid.hashCode ^
        boxName.hashCode ^
        remain.hashCode ^
        target.hashCode ^
        createdAt.hashCode ^
        status.hashCode ^
        imageUrl.hashCode;
  }
}