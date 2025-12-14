import 'package:flutter/material.dart';
import 'package:TODO_APP_DEV/component/main_calendar.dart';
import 'package:TODO_APP_DEV/component/schedule_card.dart';
import 'package:TODO_APP_DEV/component/today_banner.dart';
import 'package:TODO_APP_DEV/component/schedule_bottom_sheet.dart';
import 'package:TODO_APP_DEV/const/colors.dart';
import 'package:get_it/get_it.dart';
import 'package:TODO_APP_DEV/database/drift_database.dart';

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
        ),
      ),
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
            Expanded(  // 남는 공간을 모두 차지하기
              // 일정 정보가 stream으로 제공되기 때문에 streambuilder 사용
              child: StreamBuilder<List<Schedule>>(
                stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDate),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) {  // 데이터가 없을 때
                    return Container();
                  }
                  // 화면에 보이는 값들만 렌더링 하는 리스트
                  return ListView.builder(
                    // 리스트에 입력할 값들의 총 개수
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      // 현재 index에 해당되는 일정
                      final schedule = snapshot.data![index];
                      return Dismissible(  // 좌우로 패딩을 추가해서 UI 개선
                      key: ObjectKey(schedule.id),  // 유니크한 키값
                      // 밀기 방향(왼쪽에서 오른쪽으로)
                      direction: DismissDirection.startToEnd,
                      // 밀었을 때 실행할 함수
                      onDismissed: (DismissDirection direction) {
                        GetIt.I<LocalDatabase>()  // 데이터베이스에서 일정 삭제
                        .removeSchedule(schedule.id);
                      },
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                          child: ScheduleCard(
                            startTime: schedule.startTime,
                            endTime: schedule.endTime,
                            content: schedule.content,
                          ),
                        ),
                      );
                    },
                  );
                }
              ),
            ),
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