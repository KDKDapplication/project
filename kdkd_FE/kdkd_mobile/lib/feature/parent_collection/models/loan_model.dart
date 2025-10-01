import 'dart:convert';

class LoanModel {
  final String loanStatus;
  final String? loanUuid;
  final int? loanAmount;
  final int? loanInterest;
  final String? loanContent;
  final DateTime? createdAt;
  final DateTime? loanDue;
  final String? signImageUrl;
  final DateTime? loanDate;
  final int? currentInterestAmount;

  LoanModel({
    required this.loanStatus,
    this.loanUuid,
    this.loanAmount,
    this.loanInterest,
    this.loanContent,
    this.createdAt,
    this.loanDue,
    this.signImageUrl,
    this.loanDate,
    this.currentInterestAmount,
  });

  LoanModel copyWith({
    String? loanStatus,
    String? loanUuid,
    int? loanAmount,
    int? loanInterest,
    String? loanContent,
    DateTime? createdAt,
    DateTime? loanDue,
    String? signImageUrl,
    DateTime? loanDate,
    int? currentInterestAmount,
  }) {
    return LoanModel(
      loanStatus: loanStatus ?? this.loanStatus,
      loanUuid: loanUuid ?? this.loanUuid,
      loanAmount: loanAmount ?? this.loanAmount,
      loanInterest: loanInterest ?? this.loanInterest,
      loanContent: loanContent ?? this.loanContent,
      createdAt: createdAt ?? this.createdAt,
      loanDue: loanDue ?? this.loanDue,
      signImageUrl: signImageUrl ?? this.signImageUrl,
      loanDate: loanDate ?? this.loanDate,
      currentInterestAmount: currentInterestAmount ?? this.currentInterestAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'loanStatus': loanStatus,
      'loanUuid': loanUuid,
      'loanAmount': loanAmount,
      'loanInterest': loanInterest,
      'loanContent': loanContent,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'loanDue': loanDue?.millisecondsSinceEpoch,
      'signImageUrl': signImageUrl,
      'loanDate': loanDate?.millisecondsSinceEpoch,
      'currentInterestAmount': currentInterestAmount,
    };
  }

  factory LoanModel.fromMap(Map<String, dynamic> map) {
    return LoanModel(
      loanStatus: map['loanStatus'] as String,
      loanUuid: map['loanUuid'] != null ? map['loanUuid'] as String : null,
      loanAmount: map['loanAmount'] != null ? map['loanAmount'] as int : null,
      loanInterest: map['loanInterest'] != null ? map['loanInterest'] as int : null,
      loanContent: map['loanContent'] != null ? map['loanContent'] as String : null,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
      loanDue: map['loanDue'] != null ? DateTime.parse(map['loanDue'] as String) : null,
      signImageUrl: map['signImageUrl'] != null ? map['signImageUrl'] as String : null,
      loanDate: map['loanDate'] != null ? DateTime.parse(map['loanDate'] as String) : null,
      currentInterestAmount: map['currentInterestAmount'] != null ? map['currentInterestAmount'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory LoanModel.fromJson(String source) => LoanModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LoanModel(loanStatus: $loanStatus, loanUuid: $loanUuid, loanAmount: $loanAmount, loanInterest: $loanInterest, loanContent: $loanContent, createdAt: $createdAt, loanDue: $loanDue, signImageUrl: $signImageUrl, loanDate: $loanDate, currentInterestAmount: $currentInterestAmount)';
  }

  @override
  bool operator ==(covariant LoanModel other) {
    if (identical(this, other)) return true;

    return other.loanStatus == loanStatus &&
        other.loanUuid == loanUuid &&
        other.loanAmount == loanAmount &&
        other.loanInterest == loanInterest &&
        other.loanContent == loanContent &&
        other.createdAt == createdAt &&
        other.loanDue == loanDue &&
        other.signImageUrl == signImageUrl &&
        other.loanDate == loanDate &&
        other.currentInterestAmount == currentInterestAmount;
  }

  @override
  int get hashCode {
    return loanStatus.hashCode ^
        loanUuid.hashCode ^
        loanAmount.hashCode ^
        loanInterest.hashCode ^
        loanContent.hashCode ^
        createdAt.hashCode ^
        loanDue.hashCode ^
        signImageUrl.hashCode ^
        loanDate.hashCode ^
        currentInterestAmount.hashCode;
  }
}
