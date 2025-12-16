import 'package:logger/logger.dart';

/// 전역 로거 인스턴스
/// 디버그 모드에서만 로그를 출력하도록 설정
final AppLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // 스택 트레이스 메서드 개수 (0으로 설정하면 간단하게 출력)
    errorMethodCount: 8, // 에러 발생 시 스택 트레이스 메서드 개수
    lineLength: 120, // 로그 라인 길이
    colors: true, // 컬러 출력 활성화
    printEmojis: true, // 이모지 출력 활성화
    printTime: true, // 시간 출력 활성화
  ),
  level: Level.debug, // 디버그 레벨 이상의 로그만 출력
);

