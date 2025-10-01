class AccountInfo {
  final String accountName;
  final String accountNumber;

  AccountInfo({
    required this.accountName,
    required this.accountNumber,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) {
    return AccountInfo(
      accountName: json['accountName'] as String,
      accountNumber: json['accountNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountName': accountName,
      'accountNumber': accountNumber,
    };
  }
}
