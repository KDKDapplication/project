class AccountRegisterRequest {
  final String userUuid;
  final String accountNumber;
  final String accountPassword;
  final String bankName;

  const AccountRegisterRequest({
    required this.userUuid,
    required this.accountNumber,
    required this.accountPassword,
    required this.bankName,
  });

  Map<String, dynamic> toJson() => {
        'userUuid': userUuid,
        'accountNumber': accountNumber,
        'accountPassword': accountPassword,
        'bankName': bankName,
      };
}

class AccountVerificationRequest {
  final String accountNumber;

  const AccountVerificationRequest({
    required this.accountNumber,
  });

  Map<String, dynamic> toJson() => {
        'accountNumber': accountNumber,
      };
}
