class LoanInfo {
  final double loanAmount;
  final double interestRate;
  final String loanContent;
  final DateTime loanDate;
  final DateTime loanDue;
  final String signatureImage;

  LoanInfo({
    required this.loanAmount,
    required this.interestRate,
    required this.loanContent,
    required this.loanDate,
    required this.loanDue,
    required this.signatureImage,
  });

  factory LoanInfo.fromJson(Map<String, dynamic> json) {
    return LoanInfo(
      loanAmount: (json['loanAmount'] ?? 0).toDouble(),
      interestRate: (json['interestRate'] ?? 0).toDouble(),
      loanContent: json['loanContent'] ?? '',
      loanDate: DateTime.parse(json['loanDate']),
      loanDue: DateTime.parse(json['loanDue']),
      signatureImage: json['signatureImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loanAmount': loanAmount,
      'interestRate': interestRate,
      'loanContent': loanContent,
      'loanDate': loanDate.toIso8601String().split('T')[0],
      'loanDue': loanDue.toIso8601String().split('T')[0],
      'signatureImage': signatureImage,
    };
  }

  int get remainingDays {
    final now = DateTime.now();
    final difference = loanDue.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  String get formattedLoanAmount {
    return '${loanAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }
}