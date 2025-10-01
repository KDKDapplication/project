class UserAccountModel {
  final String accountNumber;
  final String bankName;
  final int balance;

  const UserAccountModel({
    required this.accountNumber,
    required this.bankName,
    required this.balance,
  });

  factory UserAccountModel.fromJson(Map<String, dynamic> json) {
    return UserAccountModel(
      accountNumber: json['accountNumber'] as String,
      bankName: json['bankName'] as String,
      balance: json['balance'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'bankName': bankName,
      'balance': balance,
    };
  }

  UserAccountModel copyWith({
    String? accountNumber,
    String? bankName,
    int? balance,
  }) {
    return UserAccountModel(
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      balance: balance ?? this.balance,
    );
  }

  @override
  String toString() {
    return 'UserAccountModel(accountNumber: $accountNumber, bankName: $bankName, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserAccountModel &&
        other.accountNumber == accountNumber &&
        other.bankName == bankName &&
        other.balance == balance;
  }

  @override
  int get hashCode {
    return accountNumber.hashCode ^ bankName.hashCode ^ balance.hashCode;
  }
}
