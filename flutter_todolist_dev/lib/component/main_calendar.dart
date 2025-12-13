import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:TODO_APP_DEV/const/colors.dart';

class MainCalendar extends StatelessWidget {
  final OnDaySelected onDaySelected; // 날짜 선택 시 실행할 함수
  final DateTime selectedDate;  // 선택된 날짜

  const MainCalendar({
    required this.onDaySelected,
    required this.selectedDate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      onDaySelected: onDaySelected,
      // 날짜 선택 시 실행할 함수
      selectedDayPredicate: (date) =>  // 선택된 날짜를 구분할 로직
        date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day,
      // 달력 구현
      // MainCalendar 클래스 내에서 구현(pubspec.yaml에 추가한 table_calendar 패키지 사용)
      firstDay: DateTime(1800, 1, 1),     // 첫째 날
      lastDay: DateTime(3000, 1, 1),      // 마지막 날
      focusedDay: DateTime.now(),         // 화면에 보여지는 날
      headerStyle: HeaderStyle(           // 달력 헤더 스타일
        titleCentered: true,              // 제목 중앙에 위치하기
        formatButtonVisible: false,        // 달력 크기 선택 옵션 없애기
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16.0,
        ),
      ),
      calendarStyle: CalendarStyle(
        isTodayHighlighted: false,
        defaultDecoration: BoxDecoration(   // 기본 날짜 스타일
          borderRadius: BorderRadius.circular(6.0),
          color: LIGHT_GREY_COLOR,
          ),
          weekendDecoration: BoxDecoration(   // 주말 날짜 스타일
            borderRadius: BorderRadius.circular(6.0),
            color: LIGHT_GREY_COLOR,
          ),
          selectedDecoration: BoxDecoration(   // 선택된 날짜 스타일
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: PRIMARY_COLOR,
              width: 1.0,
              ),
          ),
          defaultTextStyle: TextStyle(   // 기본 날짜 글꼴
            fontWeight: FontWeight.w600,
            color: DARK_GREY_COLOR,
          ),
          weekendTextStyle: TextStyle(   // 주말 날짜 글꼴
            fontWeight: FontWeight.w600,
            color: DARK_GREY_COLOR,
          ),
          selectedTextStyle: TextStyle(   // 선택된 날짜 글꼴
            fontWeight: FontWeight.w600,
            color: PRIMARY_COLOR,
          ),
        ),
    );
  }
}