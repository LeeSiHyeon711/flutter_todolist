import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:TODO_APP_DEV/firebase_options.dart';
import 'package:TODO_APP_DEV/screen/auth_screen.dart';
import 'package:TODO_APP_DEV/screen/auth_login_screen.dart';
import 'package:TODO_APP_DEV/repository/auth_repository.dart';
import 'package:TODO_APP_DEV/repository/schedule_repository.dart';
import 'package:TODO_APP_DEV/provider/schedule_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  // 플러터 프레임워크가 준비될 때까지 대기
  WidgetsFlutterBinding.ensureInitialized();

  // 파이어베이스 프로젝트 설정 함수
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting();

  final scheduleRepository = ScheduleRepository();
  final authRepository = AuthRepository();
  final scheduleProvider = ScheduleProvider(
    scheduleRepository: scheduleRepository,
    authRepository: authRepository,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => scheduleProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthLoginScreen(),
      ),
    ),
  );
}