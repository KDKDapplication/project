/// 빌리기 신청 요청 모델
class RequestLoanInfo {
  final int loanAmount;
  final DateTime loanDue;
  final int loanInterest;
  final String loanContent;

  RequestLoanInfo({
    required this.loanAmount,
    required this.loanDue,
    required this.loanInterest,
    required this.loanContent,
  });

  Map<String, dynamic> toMap() {
    return {
      'loanAmount': loanAmount,
      'lonaDue': loanDue.toIso8601String().split('T')[0],
      'loanInterest': loanInterest,
      'loanContent': loanContent,
    };
  }

  factory RequestLoanInfo.fromMap(Map<String, dynamic> map) {
    return RequestLoanInfo(
      loanAmount: map['loanAmount'] as int,
      loanDue: DateTime.parse(map['lonaDue'] as String),
      loanInterest: map['loanInterest'] as int,
      loanContent: map['loanContent'] as String,
    );
  }
}
