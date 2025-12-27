import 'package:TODO_APP_DEV/model/schedule_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:TODO_APP_DEV/component/main_calendar.dart';
import 'package:TODO_APP_DEV/component/schedule_card.dart';
import 'package:TODO_APP_DEV/component/today_banner.dart';
import 'package:TODO_APP_DEV/component/schedule_bottom_sheet.dart';
import 'package:TODO_APP_DEV/const/colors.dart';
import 'package:TODO_APP_DEV/component/banner_ad_widget.dart';

class HomeScreen extends StatefulWidget {
  final String? userEmail; // 웹에서 이메일 전달용

  const HomeScreen({Key? key, this.userEmail}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  String? get userEmail {
    return widget.userEmail ?? FirebaseAuth.instance.currentUser?.email;
  }

  @override
  Widget build(BuildContext context) {
    // 이메일이 없으면 로그인 화면으로 리다이렉트
    if (userEmail == null) {
      return Scaffold(
        body: Center(
          child: Text('로그인이 필요합니다.'),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        // ➊ 새 일정 버튼
        backgroundColor: PRIMARY_COLOR,
        onPressed: () {
          showModalBottomSheet(
            // ➋ BottomSheet 열기
            context: context,
            isDismissible: true, // ➌ 배경 탭했을 때 BottomSheet 닫기
            isScrollControlled: true,
            builder: (_) => ScheduleBottomSheet(
              selectedDate: selectedDate, // 선택된 날짜 (selectedDate) 넘겨주기
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: _CustomFloatingActionButtonLocation(),
      body: SafeArea(
        // 시스템 UI 피해서 UI 구현하기
        child: Column(
          // 달력과 리스트를 세로로 배치
          children: [
            MainCalendar(
              selectedDate: selectedDate, // 선택된 날짜 전달하기

              // 날짜가 선택됐을 때 실행할 함수
              onDaySelected: (selectedDate, focusedDate) => onDaySelected(selectedDate, focusedDate, context),
            ),
            SizedBox(height: 8.0),
            StreamBuilder<QuerySnapshot>(
              // ListView에 적용했던 같은 쿼리
              stream: FirebaseFirestore.instance
                  .collection(
                'schedule',
              )
                  .where(
                'date',
                isEqualTo: '${selectedDate.year}${selectedDate.month.toString().padLeft(2, "0")}${selectedDate.day.toString().padLeft(2, "0")}',
              )
                  .where('author', isEqualTo: userEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                return TodayBanner(
                  selectedDate: selectedDate,

                  // ➊ 개수 가져오기
                  count: snapshot.data?.docs.length ?? 0,
                );
              },
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 91.0), // 광고 영역(75px) + FloatingActionButton 여백(16px) 높이만큼 하단 패딩
                child: StreamBuilder<QuerySnapshot>(
                  // ➊ 파이어스토어로부터 일정 정보 받아오기
                  stream: FirebaseFirestore.instance
                      .collection(
                    'schedule',
                  )
                      .where(
                    'date',
                    isEqualTo: '${selectedDate.year}${selectedDate.month.toString().padLeft(2, "0")}${selectedDate.day.toString().padLeft(2, "0")}',
                  )
                      .where('author', isEqualTo: userEmail)
                      .snapshots(),
                  builder: (context, snapshot) {
                    // Stream을 가져오는 동안 에러가 났을 때 보여줄 화면
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('일정 정보를 가져오지 못했습니다.'),
                      );
                    }

                    // 로딩 중일 때 보여줄 화면
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }

                    // ➋ ScheduleModel로 데이터 매핑하기
                    final schedules = snapshot.data!.docs
                        .map(
                          (QueryDocumentSnapshot e) => ScheduleModel.fromJson(json: (e.data() as Map<String, dynamic>)),
                    )
                        .toList();

                    return ListView.builder(
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];

                        return Dismissible(
                          key: ObjectKey(schedule.id),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (DismissDirection direction) {
                            FirebaseFirestore.instance.collection('schedule').doc(schedule.id).delete();
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
                  },
                ),
              ),
            ),
            BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  void onDaySelected(
      DateTime selectedDate,
      DateTime focusedDate,
      BuildContext context,
      ) {
    setState(() {
      this.selectedDate = selectedDate;
    });
  }
}

class _CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // 광고 영역 높이(75px) + 여백(45px) = 120px만큼 위로 올림
    final double bottom = 120.0;
    final double right = 16.0;
    return Offset(
      scaffoldGeometry.scaffoldSize.width - right - scaffoldGeometry.floatingActionButtonSize.width,
      scaffoldGeometry.scaffoldSize.height - bottom - scaffoldGeometry.floatingActionButtonSize.height,
    );
  }
}
