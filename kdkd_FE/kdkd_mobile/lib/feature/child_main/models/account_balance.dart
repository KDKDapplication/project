class AccountBalance {
  final int balance;

  AccountBalance({required this.balance});

  factory AccountBalance.fromJson(Map<String, dynamic> json) {
    return AccountBalance(
      balance: json['balance'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
    };
  }
}
