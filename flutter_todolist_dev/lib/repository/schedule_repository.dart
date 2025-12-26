import 'dart:async';
import 'package:TODO_APP_DEV/model/schedule_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ScheduleRepository {
  final _dio = Dio();
  final _targetUrl = 'http://${_getHost()}:3000/schedule';
  
  static String _getHost() {
    if (kIsWeb) {
      return 'localhost';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return '10.0.2.2';
    }
    return 'localhost';
  }

  Future<List<ScheduleModel>> getSchedules({
    required String accessToken,
    required DateTime date,
  }) async {
    final resp = await _dio.get(
      _targetUrl,
      queryParameters: {
        'date':
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
      },
      options: Options(
        headers: {
          'authorization': 'Bearer $accessToken',
        },
      ),
    );
    
    if (resp.data is! List) {
      return [];
    }
    
    return List<ScheduleModel>.from(
      (resp.data as List).map((x) => ScheduleModel.fromJson(json: x as Map<String, dynamic>)),
    );
  }

  Future<String?> createSchedule({
    required ScheduleModel schedule,
    required String accessToken,
  }) async {
    final json = schedule.toJson();
    final resp = await _dio.post(
      _targetUrl,
      data: json,
      options: Options(
        headers: {
          'authorization': 'Bearer $accessToken',
        },
      ),
    );
    return resp.data?['id'] as String?;
  }

  Future<String?> deleteSchedule({
    required String accessToken,
    required String id,
  }) async {
    final resp = await _dio.delete(
      _targetUrl,
      data: {'id': id},
      options: Options(
        headers: {
          'authorization': 'Bearer $accessToken',
        },
      ),
    );
    return resp.data?['id'] as String?;
  }
}