import 'dart:convert';

import 'package:kdkd_mobile/feature/child_loan/models/loan_status_response.dart';

class ChildAccountModel {
  final String childUuid;
  final int? accountSeq;
  final String childName;
  final String? childAccountNumber;
  final int? childRemain;

  final bool? isAutoDebit;
  final int? autoDebitMoney;
  final int? autoDebitDay;
  final String? autoDebitTime;

  final LoanStatus? loanStatus;
  final String? loanUuid;
  final int? loanMoney;
  final DateTime? loanDay;

  ChildAccountModel({
    required this.childUuid,
    this.accountSeq,
    required this.childName,
    this.childAccountNumber,
    this.childRemain,
    this.isAutoDebit,
    this.autoDebitMoney,
    this.autoDebitDay,
    this.autoDebitTime,
    this.loanStatus,
    this.loanUuid,
    this.loanMoney,
    this.loanDay,
  });

  ChildAccountModel copyWith({
    String? childUuid,
    int? accountSeq,
    String? childName,
    String? childAccountNumber,
    int? childRemain,
    bool? isAutoDebit,
    int? autoDebitMoney,
    int? autoDebitDay,
    String? autoDebitTime,
    LoanStatus? loanStatus,
    String? loanUuid,
    int? loanMoney,
    DateTime? loanDay,
  }) {
    return ChildAccountModel(
      childUuid: childUuid ?? this.childUuid,
      accountSeq: accountSeq ?? this.accountSeq,
      childName: childName ?? this.childName,
      childAccountNumber: childAccountNumber ?? this.childAccountNumber,
      childRemain: childRemain ?? this.childRemain,
      isAutoDebit: isAutoDebit ?? this.isAutoDebit,
      autoDebitMoney: autoDebitMoney ?? this.autoDebitMoney,
      autoDebitDay: autoDebitDay ?? this.autoDebitDay,
      autoDebitTime: autoDebitTime ?? this.autoDebitTime,
      loanStatus: loanStatus ?? this.loanStatus,
      loanUuid: loanUuid ?? this.loanUuid,
      loanMoney: loanMoney ?? this.loanMoney,
      loanDay: loanDay ?? this.loanDay,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'childUuid': childUuid,
      'accountSeq': accountSeq,
      'childName': childName,
      'childAccountNumber': childAccountNumber,
      'childRemain': childRemain,
      'isAutoDebit': isAutoDebit,
      'autoDebitMoney': autoDebitMoney,
      'autoDebitDay': autoDebitDay,
      'autoDebitTime': autoDebitTime,
      'loanStatus': loanStatus?.toMap(),
      'loanUuid': loanUuid,
      'loanMoney': loanMoney,
      'loanDay': loanDay?.toIso8601String(),
    };
  }

  factory ChildAccountModel.fromMap(Map<String, dynamic> map) {
    return ChildAccountModel(
      childUuid: map['childUuid'] as String,
      accountSeq: (map['accountSeq'] as num?)?.toInt(),
      childName: map['childName'] as String,
      childAccountNumber: map['childAccountNumber'] as String?,
      childRemain: (map['childRemain'] as num?)?.toInt(),
      isAutoDebit: map['isAutoDebit'] as bool?,
      autoDebitMoney: (map['autoDebitMoney'] as num?)?.toInt(),
      autoDebitDay: (map['autoDebitDay'] as num?)?.toInt(),
      autoDebitTime: map['autoDebitTime'] as String?,
      loanStatus: map['loanStatus'] != null ? LoanStatusExtension.fromMap(map['loanStatus']) : null,
      loanUuid: map['loanUuid'] as String?,
      loanMoney: (map['loanMoney'] as num?)?.toInt(),
      loanDay: map['loanDay'] != null ? DateTime.tryParse(map['loanDay'].toString()) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChildAccountModel.fromJson(String source) =>
      ChildAccountModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChildAccountModel(childUuid: $childUuid, accountSeq: $accountSeq, childName: $childName, childAccountNumber: $childAccountNumber, childRemain: $childRemain, isAutoDebit: $isAutoDebit, autoDebitMoney: $autoDebitMoney, autoDebitDay: $autoDebitDay, autoDebitTime: $autoDebitTime, loanStatus: $loanStatus, loanUuid: $loanUuid, loanMoney: $loanMoney, loanDay: $loanDay)';
  }

  @override
  bool operator ==(covariant ChildAccountModel other) {
    if (identical(this, other)) return true;

    return other.childUuid == childUuid &&
        other.accountSeq == accountSeq &&
        other.childName == childName &&
        other.childAccountNumber == childAccountNumber &&
        other.childRemain == childRemain &&
        other.isAutoDebit == isAutoDebit &&
        other.autoDebitMoney == autoDebitMoney &&
        other.autoDebitDay == autoDebitDay &&
        other.autoDebitTime == autoDebitTime &&
        other.loanStatus == loanStatus &&
        other.loanUuid == loanUuid &&
        other.loanMoney == loanMoney &&
        other.loanDay == loanDay;
  }

  @override
  int get hashCode {
    return childUuid.hashCode ^
        accountSeq.hashCode ^
        childName.hashCode ^
        childAccountNumber.hashCode ^
        childRemain.hashCode ^
        isAutoDebit.hashCode ^
        autoDebitMoney.hashCode ^
        autoDebitDay.hashCode ^
        autoDebitTime.hashCode ^
        loanStatus.hashCode ^
        loanUuid.hashCode ^
        loanMoney.hashCode ^
        loanDay.hashCode;
  }
}
