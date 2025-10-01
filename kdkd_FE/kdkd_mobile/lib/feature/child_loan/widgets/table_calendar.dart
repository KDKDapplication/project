import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class TableCalendar1 extends StatefulWidget {
  const TableCalendar1({super.key});

  @override
  State<TableCalendar1> createState() => _TableCalendar1State();
}

class _TableCalendar1State extends State<TableCalendar1> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_KR',
      firstDay: DateTime.now(),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },

      // 추가
      headerStyle: HeaderStyle(
        titleCentered: true,
        titleTextFormatter: (date, locale) =>
            DateFormat.yMMMMd(locale).format(date),
        formatButtonVisible: false,
        titleTextStyle: const TextStyle(
          fontSize: 20.0,
          color: AppColors.black,
        ),
        headerPadding: const EdgeInsets.symmetric(vertical: 4.0),
        leftChevronIcon: const Icon(
          Icons.arrow_left,
          size: 40.0,
        ),
        rightChevronIcon: const Icon(
          Icons.arrow_right,
          size: 40.0,
        ),
      ),
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.violet,
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 16.0,
        ),
        selectedTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 16.0,
        ),
        selectedDecoration: BoxDecoration(
          color: AppColors.violet,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
