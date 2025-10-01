class AccountRegisterResponse {
  final String message;
  final bool success;
  final String? accountId;

  const AccountRegisterResponse({
    required this.message,
    required this.success,
    this.accountId,
  });

  factory AccountRegisterResponse.fromJson(Map<String, dynamic> json) {
    return AccountRegisterResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      accountId: json['accountId'],
    );
  }
}

class AccountVerificationResponse {
  final bool isValid;
  final String message;
  final AccountDetails? account;

  const AccountVerificationResponse({
    required this.isValid,
    required this.message,
    this.account,
  });

  factory AccountVerificationResponse.fromJson(Map<String, dynamic> json) {
    return AccountVerificationResponse(
      isValid: json['isValid'] ?? false,
      message: json['message'] ?? '',
      account: json['account'] != null
          ? AccountDetails.fromJson(json['account'])
          : null,
    );
  }
}

class AccountDetails {
  final String accountNumber;
  final String bankName;
  final String accountHolderName;
  final double balance;

  const AccountDetails({
    required this.accountNumber,
    required this.bankName,
    required this.accountHolderName,
    required this.balance,
  });

  factory AccountDetails.fromJson(Map<String, dynamic> json) {
    return AccountDetails(
      accountNumber: json['accountNumber'] ?? '',
      bankName: json['bankName'] ?? '',
      accountHolderName: json['accountHolderName'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }
}
