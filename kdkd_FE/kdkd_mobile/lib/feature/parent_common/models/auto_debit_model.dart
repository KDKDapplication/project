/// 자동이체 등록 요청 모델
class AutoDebitRegisterRequest {
  final String childUuid;
  final int date;
  final String hour;
  final int amount;

  const AutoDebitRegisterRequest({
    required this.childUuid,
    required this.date,
    required this.hour,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'childUuid': childUuid,
        'date': date,
        'hour': hour,
        'amount': amount,
      };

  factory AutoDebitRegisterRequest.fromJson(Map<String, dynamic> json) => AutoDebitRegisterRequest(
        childUuid: json['childUuid'] as String,
        date: json['date'] as int,
        hour: json['hour'] as String,
        amount: json['amount'] as int,
      );

  @override
  String toString() {
    return 'AutoDebitRegisterRequest(childUuid: $childUuid, date: $date, hour: $hour, amount: $amount)';
  }

  AutoDebitRegisterRequest copyWith({
    String? childUuid,
    int? date,
    String? hour,
    int? amount,
  }) {
    return AutoDebitRegisterRequest(
      childUuid: childUuid ?? this.childUuid,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      amount: amount ?? this.amount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutoDebitRegisterRequest &&
        other.childUuid == childUuid &&
        other.date == date &&
        other.hour == hour &&
        other.amount == amount;
  }

  @override
  int get hashCode {
    return childUuid.hashCode ^ date.hashCode ^ hour.hashCode ^ amount.hashCode;
  }
}

/// 자동이체 삭제 요청 모델
class AutoDebitDeleteRequest {
  final String childUuid;

  const AutoDebitDeleteRequest({
    required this.childUuid,
  });

  Map<String, dynamic> toJson() => {
        'childUuid': childUuid,
      };

  factory AutoDebitDeleteRequest.fromJson(Map<String, dynamic> json) => AutoDebitDeleteRequest(
        childUuid: json['childUuid'] as String,
      );

  @override
  String toString() {
    return 'AutoDebitDeleteRequest(childUuid: $childUuid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutoDebitDeleteRequest && other.childUuid == childUuid;
  }

  @override
  int get hashCode {
    return childUuid.hashCode;
  }
}

/// 자동이체 정보 모델
class AutoDebitInfo {
  final String childUuid;
  final String childName;
  final int date;
  final String hour;
  final int amount;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AutoDebitInfo({
    required this.childUuid,
    required this.childName,
    required this.date,
    required this.hour,
    required this.amount,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AutoDebitInfo.fromJson(Map<String, dynamic> json) => AutoDebitInfo(
        childUuid: (json['childUuid'] ?? json['childName']) as String,
        childName: json['childName'] as String,
        date: json['date'] as int,
        hour: json['hour'] as String,
        amount: json['amount'] as int,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      );

  Map<String, dynamic> toJson() => {
        'childUuid': childUuid,
        'childName': childName,
        'date': date,
        'hour': hour,
        'amount': amount,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  /// 자동이체 실행 날짜 텍스트 반환 (예: "매월 15일")
  String get dateText => '매월 $date일';

  /// 자동이체 실행 시간 텍스트 반환 (예: "오전 9시")
  String get hourText {
    int hourInt;
    if (hour.contains(':')) {
      // "HH:mm:ss" 형식
      hourInt = int.tryParse(hour.split(':')[0]) ?? 0;
    } else {
      // 숫자만 있는 형식
      hourInt = int.tryParse(hour) ?? 0;
    }

    if (hourInt == 0) return '오전 12시';
    if (hourInt < 12) return '오전 $hourInt시';
    if (hourInt == 12) return '오후 12시';
    return '오후 ${hourInt - 12}시';
  }

  /// 금액 포맷팅 (예: "50,000원")
  String get amountText {
    return '${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}원';
  }

  /// 자동이체 설정 요약 텍스트
  String get autoDebitDate => '$dateText $hourText';
  String get autoDebitMoney => amountText;

  AutoDebitInfo copyWith({
    String? childUuid,
    String? childName,
    int? date,
    String? hour,
    int? amount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AutoDebitInfo(
      childUuid: childUuid ?? this.childUuid,
      childName: childName ?? this.childName,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      amount: amount ?? this.amount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AutoDebitInfo(childUuid: $childUuid, childName: $childName, date: $date, hour: $hour, amount: $amount, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AutoDebitInfo &&
        other.childUuid == childUuid &&
        other.childName == childName &&
        other.date == date &&
        other.hour == hour &&
        other.amount == amount &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return childUuid.hashCode ^
        childName.hashCode ^
        date.hashCode ^
        hour.hashCode ^
        amount.hashCode ^
        isActive.hashCode;
  }
}

/// 자동이체 목록 응답 모델
class AutoDebitListResponse {
  final List<AutoDebitInfo> autoDebits;
  final int totalCount;

  const AutoDebitListResponse({
    required this.autoDebits,
    required this.totalCount,
  });

  factory AutoDebitListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['autoDebits'] ?? json['data'] ?? [];
    return AutoDebitListResponse(
      autoDebits: list.map((item) => AutoDebitInfo.fromJson(item as Map<String, dynamic>)).toList(),
      totalCount: json['totalCount'] as int? ?? list.length,
    );
  }

  Map<String, dynamic> toJson() => {
        'autoDebits': autoDebits.map((item) => item.toJson()).toList(),
        'totalCount': totalCount,
      };

  @override
  String toString() {
    return 'AutoDebitListResponse(autoDebits: ${autoDebits.length} items, totalCount: $totalCount)';
  }
}
