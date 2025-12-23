import 'package:TODO_APP_DEV/model/schedule_model.dart';
import 'package:TODO_APP_DEV/repository/schedule_repository.dart';
import 'package:TODO_APP_DEV/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';


class ScheduleProvider extends ChangeNotifier {
  final ScheduleRepository scheduleRepository;  // API 요청 로직을 담은 클래스
  final AuthRepository authRepository;  // 인증 요청 로직을 담은 클래스

  String? accessToken;
  String? refreshToken;

  DateTime selectedDate = DateTime.utc(  // 선택한 날짜
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  Map<DateTime, List<ScheduleModel>> cache = {};  // 일정 정보를 저장해둘 변수

  ScheduleProvider({
    required this.scheduleRepository,
    required this.authRepository,
  }) : super() {}

  void getSchedules({
    required DateTime date,
    required String accessToken,
  }) async {
    final schedules = await scheduleRepository.getSchedules(date: date, accessToken: accessToken);
    cache[date] = schedules;
    notifyListeners();
  }

  void createSchedule({
    required ScheduleModel schedule,
    required String accessToken,
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
      final savedSchedule = await scheduleRepository.createSchedule(schedule: schedule, accessToken: accessToken);

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
    required String accessToken,
  }) async {
    final targetSchedule = cache[date]!.firstWhere((e) => e.id == id);  // 삭제할 일정 기억

    cache.update(  // 캐시에서 데이터 삭제
      date,
      (value) => value.where((e) => e.id != id).toList(),
      ifAbsent: () => [],
    );  // 긍정적 응답(응답 전에 캐시 먼저 업데이트)

    notifyListeners();  // 캐시 업데이트 반영하기

    try {
      await scheduleRepository.deleteSchedule(accessToken: accessToken, id: id);  // 삭제 함수 실행
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

  void updateTokens({
    String? refreshToken,
    String? accessToken,
  }) {
    // refreshToken이 입력됐을 경우 refreshToken 업데이느
    if (refreshToken != null) {
      this.refreshToken = refreshToken;
    }
    
    // accessToken이 입력됐을 경우 accessToken 업데이트
    if (accessToken != null) {
      this.accessToken = accessToken;
    }

    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    // AuthRepository에 미리 구현해둔 register 함수를 실행합니다.
    final resp = await authRepository.register(
      email: email,
      password: password,
    );

    // 반환받을 토큰을 기반으로 토큰 프로퍼티를 업데이트합니다.
    updateTokens(
      refreshToken: resp.refreshToken,
      accessToken: resp.accessToken,
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final resp = await authRepository.login(
      email: email,
      password: password,
    );

    updateTokens(
      refreshToken: resp.refreshToken,
      accessToken: resp.accessToken,
    );
  }

  void logout() {
    // refreshToken과 accessToken을 null로 업데이트해서 로그아웃 상태로 만듭니다.
    refreshToken = null;
    accessToken = null;
    // 로그아웃과 동시에 일정 정보 캐시도 모두 삭제됩니다.
    cache.clear();
    notifyListeners();
  }

  void rotateToken({
    required String refreshToken,
    required bool isRefreshToken,
  }) async {
    // isRefreshToken이 true일 경우 refreshToken 재발급
    // false일 경우 accessToken 재발급
    if (isRefreshToken) {
      final token = await authRepository.rotateRefreshToken(refreshToken: refreshToken);

      this.refreshToken = token;
    } else {
      final token = await authRepository.rotateAccessToken(refreshToken: refreshToken);

      accessToken = token;
    }

    notifyListeners();
  }
}