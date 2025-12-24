import 'package:flutter/material.dart';
import 'package:TODO_APP_DEV/component/main_calendar.dart';
import 'package:TODO_APP_DEV/component/schedule_card.dart';
import 'package:TODO_APP_DEV/component/today_banner.dart';
import 'package:TODO_APP_DEV/component/schedule_bottom_sheet.dart';
import 'package:TODO_APP_DEV/const/colors.dart';
import 'package:provider/provider.dart';
import 'package:TODO_APP_DEV/provider/schedule_provider.dart';

class HomeScreen extends StatefulWidget {

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
  void initState() {
    super.initState();

    // HomeScreen 위젯이 완전히 빌드된 후에 일정을 요청합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ScheduleProvider>();
      final token = provider.accessToken;
      
      // accessToken이 있을 때만 일정을 요청합니다.
      if (token != null) {
        provider.getSchedules(
          date: selectedDate,
          accessToken: token,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    // 프로바이더 변경이 있을 때마다 build() 함수 재실행
    final provider = context.watch<ScheduleProvider>();

    // 선택된 날짜 가져오기
    final selectedDate = provider.selectedDate;

    // 선택된 날짜에 해당되는 일정들 가져오기
    final schedules = provider.cache[selectedDate] ?? [];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_COLOR,
        onPressed: () {
          showModalBottomSheet(
            context: context, 
            isDismissible: true, 
            builder: (_) => ScheduleBottomSheet(
              selectedDate: selectedDate,  // 선택된 날짜 (selectedDate) 넘겨주기
            ),
            // BottomSheet의 높이를 화면의 최대 높이로
            // 정의하고 스크롤 가능하게 변경
            isScrollControlled: true,
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SafeArea(     // 시스템 UI 피해서 구현하기
        child: Column(    // 달력과 리스트를 세로로 배치
          children: [
            // 달력 위젯 보여주기
            MainCalendar(
              selectedDate: selectedDate,  // 선택된 날짜 전달하기
              // 날짜가 선택됐을 때 실행할 함수
              onDaySelected: (selectedDate, focusedDate) =>
              onDaySelected(selectedDate, focusedDate, context),
            ),
            SizedBox(height: 8.0),
            TodayBanner(
              selectedDate: selectedDate,
              // provider의 cache에서 일정 개수 가져오기
              count: schedules.length,
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  return Dismissible(
                    key: ObjectKey(schedule.id),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (DismissDirection direction) {
                      // ScheduleProvider를 통해 일정 삭제하기
                      provider.deleteSchedule(
                        date: selectedDate,
                        id: schedule.id,
                        accessToken: provider.accessToken!,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8.0, left: 8.0, right: 8.0
                      ),
                      child: ScheduleCard(
                        startTime: schedule.startTime,
                        endTime: schedule.endTime,
                        content: schedule.content,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onDaySelected(DateTime selectedDate, DateTime focusedDate, BuildContext context) {
    final provider = context.read<ScheduleProvider>();
    provider.changeSelectedDate(date: selectedDate,);
    provider.getSchedules(date: selectedDate, accessToken: provider.accessToken!);
  }
}