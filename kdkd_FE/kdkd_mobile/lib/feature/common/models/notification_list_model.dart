import 'dart:convert';

class NotificationItem {
  final String alertUuid;
  final String content;
  final DateTime createdAt;
  final String senderName;

  NotificationItem({
    required this.alertUuid,
    required this.content,
    required this.createdAt,
    required this.senderName,
  });

  NotificationItem copyWith({
    String? alertUuid,
    String? content,
    DateTime? createdAt,
    String? senderName,
  }) {
    return NotificationItem(
      alertUuid: alertUuid ?? this.alertUuid,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'alertUuid': alertUuid,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'senderName': senderName,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      alertUuid: map['alertUuid'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      senderName: map['senderName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationItem.fromJson(String source) =>
      NotificationItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NotificationItem(alertUuid: $alertUuid, content: $content, createdAt: $createdAt, senderName: $senderName)';
  }

  @override
  bool operator ==(covariant NotificationItem other) {
    if (identical(this, other)) return true;

    return other.alertUuid == alertUuid &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.senderName == senderName;
  }

  @override
  int get hashCode {
    return alertUuid.hashCode ^
        content.hashCode ^
        createdAt.hashCode ^
        senderName.hashCode;
  }
}

class NotificationListResponse {
  final List<NotificationItem> alerts;
  final int totalPages;

  NotificationListResponse({
    required this.alerts,
    required this.totalPages,
  });

  NotificationListResponse copyWith({
    List<NotificationItem>? alerts,
    int? totalPages,
  }) {
    return NotificationListResponse(
      alerts: alerts ?? this.alerts,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'alerts': alerts.map((x) => x.toMap()).toList(),
      'totalPages': totalPages,
    };
  }

  factory NotificationListResponse.fromMap(Map<String, dynamic> map) {
    return NotificationListResponse(
      alerts: List<NotificationItem>.from(
        (map['alerts'] as List).map<NotificationItem>(
          (x) => NotificationItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
      totalPages: map['totalPages'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationListResponse.fromJson(String source) =>
      NotificationListResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NotificationListResponse(alerts: $alerts, totalPages: $totalPages)';
  }

  @override
  bool operator ==(covariant NotificationListResponse other) {
    if (identical(this, other)) return true;

    return other.alerts == alerts &&
        other.totalPages == totalPages;
  }

  @override
  int get hashCode {
    return alerts.hashCode ^ totalPages.hashCode;
  }
}
