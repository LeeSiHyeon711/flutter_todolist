import 'package:TODO_APP_DEV/model/schedule_model.dart';
import 'package:TODO_APP_DEV/repository/schedule_repository.dart';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ScheduleProvider extends ChangeNotifier {
  final ScheduleRepository repository;  // API 요청 로직을 담은 클래스

  DateTime selectedDate = DateTime.utc(  // 선택한 날짜
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  Map<DateTime, List<ScheduleModel>> cache = {};  // 일정 정보를 저장해둘 변수

  ScheduleProvider({
    required this.repository,
  }) : super() {
    getSchedules(date: selectedDate);
  }

  void getSchedules({
    required DateTime date,
  }) async {
    final resp = await repository.getSchedules(date: date);  // GET 메서드 보내기

    // 선택한 날짜의 일정들 업데이트하기
    cache.update(date, (value) => resp, ifAbsent: () => resp);

    notifyListeners();
  }

  void createSchedule({
    required ScheduleModel schedule,
  }) async {
    final targetDate = schedule.date;

    final uuid = Uuid();

    final tempId = uuid.v4();  // 유일한 ID값을 생성합니다.
    final newSchedule = schedule.copyWith(
      id: tempId,  // 임시 ID를 지정합니다.
    );

    cache.update(
      targetDate,
      (value) => [
        ...value,
        newSchedule,
      ]..sort(
        (a, b) => a.startTime.compareTo(
          b.startTime,
        ),
      ),
      // 날짜에 해당되는 값이 없다면 새로운 리스트에 새로운 일정 하나만 추가
      ifAbsent: () => [newSchedule],
    );

    notifyListeners();  // 캐시 업데이트 반영하기

    try {
      // API 요청을 합니다.
      final savedSchedule = await repository.createSchedule(schedule: schedule);

      cache.update(
        targetDate,
        (value) => value.map((e) => e.id == tempId ? e.copyWith(id: savedSchedule,): e).toList(),
      );
    } catch (e) {
      // 실패 시 임시 ID를 제거하고 캐시 업데이트
      cache.update(
        targetDate,
        (value) => value.where((e) => e.id != tempId).toList(),
      );
    }

    notifyListeners();
  }

  void deleteSchedule({
    required DateTime date,
    required String id,
  }) async {
    final targetSchedule = cache[date]!.firstWhere((e) => e.id == id);  // 삭제할 일정 기억

    cache.update(  // 캐시에서 데이터 삭제
      date,
      (value) => value.where((e) => e.id != id).toList(),
      ifAbsent: () => [],
    );  // 긍정적 응답(응답 전에 캐시 먼저 업데이트)

    notifyListeners();  // 캐시 업데이트 반영하기

    try {
      await repository.deleteSchedule(id: id);  // 삭제 함수 실행
    } catch (e) {
      // 삭제 실패 시 캐시 롤백하기
      cache.update(
        date, (value) => [...value, targetSchedule]..sort(
          (a, b) => a.startTime.compareTo(
            b.startTime,
          ),
        ),
      );
    }
    notifyListeners();
  }

  void changeSelectedDate({
    required DateTime date,
  }) {
    selectedDate = date;
    notifyListeners();
  }
}