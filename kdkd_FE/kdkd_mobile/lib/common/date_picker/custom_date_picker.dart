import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';

class CustomDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final String? dateFormat;
  final TextStyle? textStyle;
  final CupertinoDatePickerMode mode;
  final DateTime? minimumDate;
  final DateTime? maximumDate;

  const CustomDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.dateFormat,
    this.textStyle,
    this.mode = CupertinoDatePickerMode.date,
    this.minimumDate,
    this.maximumDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return Localizations.override(
              context: context,
              locale: const Locale('ko', 'KR'),
              child: Builder(
                builder: (context) {
                  return Container(
                    height: 250,
                    padding: const EdgeInsets.only(top: 6.0),
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    color: CupertinoColors.systemBackground.resolveFrom(context),
                    child: SafeArea(
                      top: false,
                      child: CupertinoDatePicker(
                        initialDateTime: selectedDate,
                        mode: mode,
                        use24hFormat: true,
                        minimumDate: minimumDate,
                        maximumDate: maximumDate,
                        onDateTimeChanged: onDateChanged,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      child: Container(
        child: Text(
          _formatDate(),
          style: textStyle ??
              AppFonts.titleSmall.copyWith(
                color: AppColors.blueAccent,
              ),
        ),
      ),
    );
  }

  String _formatDate() {
    final format = dateFormat ?? 'yyyy년 MM월 dd일';
    return DateFormat(format).format(selectedDate);
  }
}
