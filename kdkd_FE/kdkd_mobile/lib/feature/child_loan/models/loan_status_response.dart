// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

enum LoanStatus { NOT_APPLIED, WAITING_APPROVAL, ACTIVE }

extension LoanStatusExtension on LoanStatus {
  String toMap() {
    switch (this) {
      case LoanStatus.NOT_APPLIED:
        return 'NOT_APPLIED';
      case LoanStatus.WAITING_APPROVAL:
        return 'WAITING_APPROVAL';
      case LoanStatus.ACTIVE:
        return 'ACTIVE';
    }
  }

  static LoanStatus fromMap(dynamic value) {
    switch (value) {
      case 'NOT_APPLIED':
        return LoanStatus.NOT_APPLIED;
      case 'WAITING_APPROVAL':
        return LoanStatus.WAITING_APPROVAL;
      case 'ACTIVE':
        return LoanStatus.ACTIVE;
      default:
        throw ArgumentError('Invalid LoanStatus value: $value');
    }
  }
}

/// 빌리기 상태 응답 모델
class LoanStatusResponse {
  final LoanStatus loanStatus;
  final String? loanUuid;
  final int? loanAmount;
  final int? loanInterest;
  final String? loanContent;
  final DateTime? createdAt;
  final DateTime? loanDue;
  final DateTime? loanDate;
  final int? currentInterestAmount;

  LoanStatusResponse({
    this.loanStatus = LoanStatus.NOT_APPLIED,
    this.loanUuid,
    this.loanAmount,
    this.loanInterest,
    this.loanContent,
    this.createdAt,
    this.loanDue,
    this.loanDate,
    this.currentInterestAmount,
  });

  LoanStatusResponse copyWith({
    LoanStatus? loanStatus,
    String? loanUuid,
    int? loanAmount,
    int? loanInterest,
    String? loanContent,
    DateTime? createdAt,
    DateTime? loanDue,
    DateTime? loanDate,
    int? currentInterestAmount,
  }) {
    return LoanStatusResponse(
      loanStatus: loanStatus ?? this.loanStatus,
      loanUuid: loanUuid ?? this.loanUuid,
      loanAmount: loanAmount ?? this.loanAmount,
      loanInterest: loanInterest ?? this.loanInterest,
      loanContent: loanContent ?? this.loanContent,
      createdAt: createdAt ?? this.createdAt,
      loanDue: loanDue ?? this.loanDue,
      loanDate: loanDate ?? this.loanDate,
      currentInterestAmount: currentInterestAmount ?? this.currentInterestAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'loanStatus': loanStatus.toMap(),
      'loanUuid': loanUuid,
      'loanAmount': loanAmount,
      'loanInterest': loanInterest,
      'loanContent': loanContent,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'loanDue': loanDue?.millisecondsSinceEpoch,
      'loanDate': loanDate?.millisecondsSinceEpoch,
      'currentInterestAmount': currentInterestAmount,
    };
  }

  factory LoanStatusResponse.fromMap(Map<String, dynamic> map) {
    return LoanStatusResponse(
      loanStatus: LoanStatusExtension.fromMap(map['loanStatus']),
      loanUuid: map['loanUuid'] as String?,
      loanAmount: map['loanAmount'] as int?,
      loanInterest: map['loanInterest'] as int?,
      loanContent: map['loanContent'] as String?,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
      loanDue: map['loanDue'] != null ? DateTime.parse(map['loanDue'] as String) : null,
      loanDate: map['loanDate'] != null ? DateTime.parse(map['loanDate'] as String) : null,
      currentInterestAmount: map['currentInterestAmount'] as int?,
    );
  }

  String toJson() => json.encode(toMap());

  factory LoanStatusResponse.fromJson(String source) =>
      LoanStatusResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LoanStatusResponse(loanStatus: $loanStatus, loanUuid: $loanUuid, loanAmount: $loanAmount, loanInterest: $loanInterest, loanContent: $loanContent, createdAt: $createdAt, loanDue: $loanDue, loanDate: $loanDate, currentInterestAmount: $currentInterestAmount)';
  }

  @override
  bool operator ==(covariant LoanStatusResponse other) {
    if (identical(this, other)) return true;

    return other.loanStatus == loanStatus &&
        other.loanUuid == loanUuid &&
        other.loanAmount == loanAmount &&
        other.loanInterest == loanInterest &&
        other.loanContent == loanContent &&
        other.createdAt == createdAt &&
        other.loanDue == loanDue &&
        other.loanDate == loanDate &&
        other.currentInterestAmount == currentInterestAmount;
  }

  @override
  int get hashCode {
    return loanStatus.hashCode ^
        (loanUuid?.hashCode ?? 0) ^
        (loanAmount?.hashCode ?? 0) ^
        (loanInterest?.hashCode ?? 0) ^
        (loanContent?.hashCode ?? 0) ^
        (createdAt?.hashCode ?? 0) ^
        (loanDue?.hashCode ?? 0) ^
        (loanDate?.hashCode ?? 0) ^
        (currentInterestAmount?.hashCode ?? 0);
  }
}
