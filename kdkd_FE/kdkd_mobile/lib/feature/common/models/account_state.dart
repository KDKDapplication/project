class AccountFormState {
  final String bank;
  final String accountNumber;
  final String password;
  final bool isLoading;
  final String? error;
  final bool isRegistered;
  final bool isOneWonSent;
  final String authCode;

  const AccountFormState({
    this.bank = '',
    this.accountNumber = '',
    this.password = '',
    this.isLoading = false,
    this.error,
    this.isRegistered = false,
    this.isOneWonSent = false,
    this.authCode = '',
  });

  AccountFormState copyWith({
    String? bank,
    String? accountNumber,
    String? password,
    bool? isLoading,
    String? error,
    bool? isRegistered,
    bool? isOneWonSent,
    String? authCode,
  }) {
    return AccountFormState(
      bank: bank ?? this.bank,
      accountNumber: accountNumber ?? this.accountNumber,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isRegistered: isRegistered ?? this.isRegistered,
      isOneWonSent: isOneWonSent ?? this.isOneWonSent,
      authCode: authCode ?? this.authCode,
    );
  }

  bool get isValid =>
      bank.isNotEmpty &&
      accountNumber.replaceAll(RegExp(r'[^0-9]'), '').length >= 10 &&
      password.length == 4;

  @override
  String toString() {
    return 'AccountFormState('
        'bank: $bank, '
        'accountNumber: $accountNumber, '
        'password: $password, '
        'isLoading: $isLoading, '
        'error: $error, '
        'isRegistered: $isRegistered, '
        'isOneWonSent: $isOneWonSent, '
        'authCode: $authCode, '
        'isValid: $isValid'
        ')';
  }
}
