# TODO App (Flutter)

일정 관리 애플리케이션입니다. 캘린더를 통해 일정을 생성, 조회, 삭제할 수 있습니다.

## 주요 기능

- 📅 **캘린더 기반 일정 관리**: 날짜별 일정 생성, 조회, 삭제
- 🔐 **Google 로그인**: Firebase Authentication을 통한 Google Sign-In
- ☁️ **Firebase Firestore**: 실시간 데이터 동기화
- 📱 **다중 플랫폼 지원**: Android, iOS, Web, macOS
- 📢 **광고 배너**: 플랫폼별 광고 표시 (Google Mobile Ads)
- 🎨 **직관적인 UI**: Material Design 기반 사용자 인터페이스

## 기술 스택

### 핵심 패키지
- `flutter`: Flutter SDK
- `provider`: 상태 관리
- `firebase_core`: Firebase 초기화
- `firebase_auth`: Firebase 인증
- `cloud_firestore`: Firebase Firestore 데이터베이스
- `google_sign_in`: Google 로그인
- `google_mobile_ads`: 광고 배너

### 기타 패키지
- `table_calendar`: 캘린더 위젯
- `dio`: HTTP 클라이언트
- `intl`: 날짜/시간 포맷팅
- `uuid`: 고유 ID 생성
- `logger`: 로깅

## 시작하기

### 사전 요구사항
- Flutter SDK (3.10.4 이상)
- Firebase 프로젝트 설정
- Google Sign-In 설정 (OAuth Client ID)
- Google Mobile Ads 계정 (광고 사용 시)

### 설치 및 실행

1. **의존성 설치**
```bash
flutter pub get
```

2. **Firebase 설정**
   - `firebase_options.dart` 파일이 올바르게 생성되어 있는지 확인
   - 각 플랫폼별 `GoogleService-Info.plist` (iOS/macOS) 및 `google-services.json` (Android) 파일 확인

3. **앱 실행**
```bash
# 특정 플랫폼 실행
flutter run

# 웹 실행
flutter run -d chrome

# iOS 실행
flutter run -d ios

# Android 실행
flutter run -d android

# macOS 실행
flutter run -d macos
```

## 프로젝트 구조

```
lib/
├── component/          # 재사용 가능한 위젯 컴포넌트
│   ├── banner_ad_widget.dart
│   ├── main_calendar.dart
│   ├── schedule_bottom_sheet.dart
│   ├── schedule_card.dart
│   └── today_banner.dart
├── const/              # 상수 정의
│   └── colors.dart
├── model/              # 데이터 모델
│   └── schedule_model.dart
├── provider/           # 상태 관리
│   └── schedule_provider.dart
├── repository/         # 데이터 레이어
│   ├── auth_repository.dart
│   └── schedule_repository.dart
├── screen/             # 화면
│   ├── auth_login_screen.dart
│   └── home_screen.dart
├── utils/              # 유틸리티
│   └── logger.dart
└── main.dart           # 앱 진입점
```

## 주요 기능 설명

### 일정 관리
- 캘린더에서 날짜 선택 시 해당 날짜의 일정이 표시됩니다
- FloatingActionButton을 통해 새 일정을 생성할 수 있습니다
- 일정 카드를 스와이프하여 삭제할 수 있습니다
- Firebase Firestore를 통해 실시간으로 동기화됩니다

### 인증
- Google Sign-In을 통한 소셜 로그인
- Firebase Authentication과 연동
- 플랫폼별 최적화된 로그인 플로우 (웹, 모바일, 데스크톱)

### 플랫폼별 특화 기능
- **웹**: HTML 기반 광고, OAuth Client ID 설정
- **macOS**: Firebase Auth persistence 비활성화, Google Sign-In 세션 관리
- **Android/iOS**: 네이티브 광고 SDK 사용

## 개발 환경

- **Flutter SDK**: ^3.10.4
- **Dart SDK**: ^3.10.4
- **최소 지원 버전**:
  - Android: API 21 이상
  - iOS: iOS 12.0 이상

## 라이선스

이 프로젝트는 개인 프로젝트입니다.
