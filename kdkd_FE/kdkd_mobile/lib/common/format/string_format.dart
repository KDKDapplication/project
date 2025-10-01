class StringFormat {
  static String formatAccountNumber(String? accountNumber) {
    if (accountNumber == null || accountNumber.isEmpty) {
      return '';
    }

    if (accountNumber.length == 16) {
      return '${accountNumber.substring(0, 4)}-${accountNumber.substring(4, 8)}-${accountNumber.substring(8, 12)}-${accountNumber.substring(12, 16)}';
    }

    return accountNumber;
  }

  static String formatMoney(int? amount) {
    if (amount == null) {
      return '0원';
    }

    return '${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}원';
  }

  static String formatTime(String? time) {
    if (time == null || time.isEmpty || time.length != 6) {
      return '';
    }

    final hour = int.parse(time.substring(0, 2));
    final minute = int.parse(time.substring(2, 4));

    if (hour == 0) {
      return '오전 12시 $minute분';
    } else if (hour < 12) {
      return '오전 $hour시 $minute분';
    } else if (hour == 12) {
      return '오후 12시 $minute분';
    } else {
      return '오후 ${hour - 12}시 $minute분';
    }
  }

  static String formatCardAccount(String source) {
    if (source == "CARD") {
      return "카드 결제";
    } else {
      return "계좌";
    }
  }
}
