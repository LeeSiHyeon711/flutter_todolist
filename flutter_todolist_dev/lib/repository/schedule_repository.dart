import 'dart:async';
import 'package:TODO_APP_DEV/model/schedule_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleRepository {
  final _firestore = FirebaseFirestore.instance;
  final _collection = 'schedule';

  Future<List<ScheduleModel>> getSchedules({
    required DateTime date,
  }) async {
    // 날짜를 YYYYMMDD 형식으로 변환
    final dateString = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    
    // Firestore에서 해당 날짜의 일정 조회
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('date', isEqualTo: dateString)
        .get();

    return querySnapshot.docs
        .map((doc) => ScheduleModel.fromJson(json: doc.data()))
        .toList();
  }

  Future<String> createSchedule({
    required ScheduleModel schedule,
  }) async {
    // Firestore에 일정 추가
    await _firestore
        .collection(_collection)
        .doc(schedule.id)
        .set(schedule.toJson());

    return schedule.id;
  }

  Future<String> deleteSchedule({
    required String id,
  }) async {
    // Firestore에서 일정 삭제
    await _firestore
        .collection(_collection)
        .doc(id)
        .delete();

    return id;
  }
}