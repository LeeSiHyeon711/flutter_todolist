import 'package:flutter/material.dart';
import 'package:TODO_APP_DEV/component/main_calendar.dart';
import 'package:TODO_APP_DEV/component/schedule_card.dart';
import 'package:TODO_APP_DEV/component/today_banner.dart';

class HomeScreen extends StatefulWidget {
  // StatelessWidget 에서 StatefulWidget으로 전환
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(     // 시스템 UI 피해서 구현하기
        child: Column(    // 달력과 리스트를 세로로 배치치
          children: [
            // 달력 위젯 보여주기
            MainCalendar(
              selectedDate: selectedDate,  // 선택된 날짜 전달하기
              // 날짜가 선택됐을 때 실행할 함수
              onDaySelected: onDaySelected,
            ),
            SizedBox(height: 8.0),
            TodayBanner(
              selectedDate: selectedDate,
              count: 0,
            ),
            SizedBox(height: 8.0),
            ScheduleCard(  // 스케줄 카드 보여주기(예제)
              startTime: 12,
              endTime: 14,
              content: '코딩 공부하기',
            )
          ],
        ),
      ),
    );
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate){
    // 날짜 선택될 때마다 실행할 함수
    setState(() {
      this.selectedDate = selectedDate;
    });
  }
}