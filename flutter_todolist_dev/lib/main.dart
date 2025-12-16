import 'package:flutter/material.dart';
import 'package:TODO_APP_DEV/screen/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:TODO_APP_DEV/database/drift_database.dart';
import 'package:get_it/get_it.dart';
import 'package:TODO_APP_DEV/provider/schedule_provider.dart';
import 'package:TODO_APP_DEV/repository/schedule_repository.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:TODO_APP_DEV/firebase_options.dart';

void main() async {
  // 플러터 프레임워크가 준비될 때까지 대기
  WidgetsFlutterBinding.ensureInitialized();

  // 파이어ㅓ베이스 프로젝트 설정 함수
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting();

  final database = LocalDatabase();

  GetIt.I.registerSingleton<LocalDatabase>(database);

  final repository = ScheduleRepository();
  final scheduleProvider = ScheduleProvider(repository: repository);

  runApp(
    ChangeNotifierProvider(
      create: (_) => scheduleProvider,
      child: MaterialApp(
        home: HomeScreen(),
      ),
    )
  );
}