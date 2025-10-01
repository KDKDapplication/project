import 'account_balance.dart';
import 'account_info.dart';

class Account {
  final AccountInfo info;
  final AccountBalance balance;
  final String? characterImagePath; // 프론트에서 붙이는 값

  Account({
    required this.info,
    required this.balance,
    this.characterImagePath,
  });

  Account copyWith({
    AccountInfo? info,
    AccountBalance? balance,
    String? characterImagePath,
  }) {
    return Account(
      info: info ?? this.info,
      balance: balance ?? this.balance,
      characterImagePath: characterImagePath ?? this.characterImagePath,
    );
  }
}
