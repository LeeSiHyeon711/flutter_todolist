import 'package:flutter/material.dart';
import 'package:TODO_APP_DEV/screen/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:TODO_APP_DEV/database/drift_database.dart';
import 'package:get_it/get_it.dart';
import 'package:TODO_APP_DEV/provider/schedule_provider.dart';
import 'package:TODO_APP_DEV/repository/schedule_repository.dart';
import 'package:provider/provider.dart';

void main() async {
  // 플러터 프레임워크가 준비될 때까지 대기
  WidgetsFlutterBinding.ensureInitialized();

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