import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'dart:ui' show PlatformDispatcher;
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:TODO_APP_DEV/firebase_options.dart';
import 'package:TODO_APP_DEV/screen/auth_login_screen.dart';
import 'package:TODO_APP_DEV/repository/auth_repository.dart';
import 'package:TODO_APP_DEV/repository/schedule_repository.dart';
import 'package:TODO_APP_DEV/provider/schedule_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 광고 기능 초기화하기
  MobileAds.instance.initialize();
  
  // runZonedGuarded로 전체 앱을 감싸서 예외 처리
  runZonedGuarded(
    () async {
      // 플러터 프레임워크가 준비될 때까지 대기 (같은 zone에서 호출)
      WidgetsFlutterBinding.ensureInitialized();

      // 전역 에러 핸들러 설정
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
      };

      // 비동기 에러 핸들러 설정
      PlatformDispatcher.instance.onError = (error, stack) {
        return true;
      };

      try {
        // 파이어베이스 프로젝트 설정 함수
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          
          // macOS에서 Firebase Auth persistence 끄기 (키체인 오류 방지)
          // 웹에서는 실행하지 않음
          if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
            try {
              await FirebaseAuth.instance.setPersistence(Persistence.NONE);
            } catch (e) {
              // 무시
            }
            
            // macOS에서 Google Sign-In 이전 세션 정리
            try {
              final googleSignIn = GoogleSignIn();
              await googleSignIn.signOut();
            } catch (e) {
              // 무시
            }
          }
        } catch (e) {
          // Firebase 초기화 오류는 무시하고 계속 진행
        }

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
      } catch (e) {
        // 에러 화면 표시
        runApp(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      '앱 초기화 오류',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '앱을 시작하는 중 오류가 발생했습니다.\n앱을 재시작해주세요.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    },
    (error, stack) {
      // 처리되지 않은 예외는 무시
    },
  );
}