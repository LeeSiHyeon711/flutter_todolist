# 백엔드 작업 요약 (코드 리뷰용)

## 📋 작업 개요
로컬 데이터베이스(Drift)에서 클라우드 데이터베이스(Firebase Firestore)로 마이그레이션하고, 백엔드 아키텍처를 재구성했습니다.

---

## 🎯 주요 작업 내용

### 1. 데이터베이스 마이그레이션
**Before**: Drift (로컬 SQLite 기반 ORM)  
**After**: Firebase Firestore (클라우드 NoSQL)

**변경 이유**:
- 데이터 동기화 및 멀티 디바이스 지원
- 서버리스 백엔드 인프라 구축
- 실시간 데이터 업데이트 가능성 확보

**삭제된 파일**:
- `lib/database/drift_database.dart`
- `lib/database/drift_database.g.dart`

---

### 2. Repository 패턴 구현 (`ScheduleRepository`)

**위치**: `lib/repository/schedule_repository.dart`

**역할**: Firestore와의 직접적인 통신을 담당하는 데이터 접근 계층

**주요 메서드**:

#### `getSchedules(DateTime date)`
- 날짜를 `YYYYMMDD` 형식으로 변환
- Firestore `where` 쿼리로 해당 날짜의 일정 조회
- `ScheduleModel` 리스트 반환

#### `createSchedule(ScheduleModel schedule)`
- Firestore에 문서 추가 (문서 ID는 `schedule.id` 사용)
- 생성된 일정 ID 반환

#### `deleteSchedule(String id)`
- 문서 ID로 일정 삭제
- 삭제된 일정 ID 반환

**설계 포인트**:
- 단일 책임 원칙: 데이터 접근 로직만 담당
- 의존성 역전: Provider가 Repository에 의존
- 테스트 용이성: Repository를 Mock으로 교체 가능

---

### 3. 상태 관리 및 비즈니스 로직 (`ScheduleProvider`)

**위치**: `lib/provider/schedule_provider.dart`

**역할**: 
- UI 상태 관리 (Provider 패턴)
- 비즈니스 로직 처리
- Optimistic UI 구현

**핵심 기능**:

#### 캐싱 전략
```dart
Map<DateTime, List<ScheduleModel>> cache = {}
```
- 날짜별로 일정 목록을 메모리에 캐싱
- 불필요한 네트워크 요청 방지

#### Optimistic UI 패턴

**생성 시 (`createSchedule`)**:
1. 임시 UUID 생성하여 즉시 UI 업데이트
2. 백그라운드에서 Firestore에 저장
3. 성공 시 임시 ID를 실제 ID로 교체
4. 실패 시 롤백 (임시 데이터 제거)

**삭제 시 (`deleteSchedule`)**:
1. 캐시에서 즉시 제거하여 UI 업데이트
2. 백그라운드에서 Firestore에서 삭제
3. 실패 시 롤백 (삭제된 데이터 복구)

**장점**:
- 사용자 경험 향상 (즉각적인 피드백)
- 네트워크 지연에 대한 체감 속도 개선

---

### 4. 데이터 모델 (`ScheduleModel`)

**위치**: `lib/model/schedule_model.dart`

**구조**:
- `id`: String (UUID)
- `content`: String (일정 내용)
- `date`: DateTime (일정 날짜)
- `startTime`: int (시작 시간, 0-24)
- `endTime`: int (종료 시간, 0-24)

**주요 메서드**:
- `fromJson()`: Firestore 문서 → 모델 변환
- `toJson()`: 모델 → Firestore 문서 변환
  - 날짜는 `YYYYMMDD` 문자열로 저장 (쿼리 최적화)
- `copyWith()`: 불변 객체 업데이트

**설계 포인트**:
- 불변성(Immutability) 보장
- 직렬화/역직렬화 지원

---

### 5. Firebase 초기화 및 설정

**위치**: `lib/firebase_options.dart`, `lib/main.dart`

**멀티 플랫폼 지원**:
- iOS
- Android
- Web
- Windows
- macOS (iOS 설정 공유)

**초기화 흐름** (`main.dart`):
```dart
1. WidgetsFlutterBinding.ensureInitialized()
2. Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
3. Repository 및 Provider 인스턴스 생성
4. ChangeNotifierProvider로 앱 래핑
```

**의존성 주입**:
- Repository → Provider (생성자 주입)
- Provider → Widget (Provider 패턴)

---

## 🏗️ 아키텍처 구조

```
┌─────────────────┐
│   UI Layer      │  (Widgets)
└────────┬────────┘
         │
┌────────▼────────┐
│  Provider Layer │  (ScheduleProvider)
│  - 상태 관리     │
│  - Optimistic UI│
│  - 캐싱         │
└────────┬────────┘
         │
┌────────▼────────┐
│ Repository Layer│  (ScheduleRepository)
│  - Firestore    │
│  - CRUD 작업    │
└────────┬────────┘
         │
┌────────▼────────┐
│   Data Layer    │  (Firebase Firestore)
└─────────────────┘
```

**레이어 분리 원칙**:
- UI는 Provider에만 의존
- Provider는 Repository에만 의존
- Repository는 Firestore에만 의존

---

## 📦 의존성 추가

**`pubspec.yaml`에 추가된 패키지**:
- `firebase_core: ^4.0.0` - Firebase 초기화
- `cloud_firestore: ^6.0.0` - Firestore 클라이언트
- `uuid: 4.5.1` - 고유 ID 생성 (Optimistic UI용)

---

## 🔍 주요 설계 결정사항

### 1. 날짜 저장 형식
- **선택**: `YYYYMMDD` 문자열
- **이유**: 
  - Firestore 쿼리 최적화 (`where('date', isEqualTo: dateString)`)
  - 인덱싱 효율성
  - 날짜 범위 쿼리 확장 가능

### 2. Optimistic UI 적용 범위
- **적용**: 생성, 삭제
- **미적용**: 조회 (캐싱으로 대체)
- **이유**: 사용자 액션에 대한 즉각적인 피드백 제공

### 3. 에러 처리
- **전략**: Try-Catch + 롤백
- **사용자 경험**: 실패 시 자동으로 이전 상태 복구
- **향후 개선**: 에러 로깅 및 사용자 알림 추가 가능

---

## 🚀 성능 최적화

1. **캐싱**: 날짜별 일정 목록을 메모리에 저장
2. **쿼리 최적화**: 날짜를 문자열로 저장하여 인덱스 활용
3. **Optimistic UI**: 네트워크 지연 체감 최소화

---

## 📝 향후 개선 가능 사항

1. **에러 처리 강화**: 
   - 에러 타입별 처리
   - 사용자 친화적 에러 메시지

2. **오프라인 지원**:
   - Firestore 오프라인 영속성 활성화
   - 동기화 상태 표시

3. **실시간 업데이트**:
   - `StreamBuilder` 또는 `snapshots()` 활용
   - 다른 디바이스에서의 변경사항 실시간 반영

4. **페이징**:
   - 대량 데이터 처리 시 페이지네이션 구현

5. **테스트**:
   - Repository 단위 테스트
   - Provider 통합 테스트

---

## 💡 코드 리뷰 시 강조할 포인트

1. **아키텍처**: 레이어 분리로 관심사 분리 달성
2. **사용자 경험**: Optimistic UI로 반응성 향상
3. **확장성**: Repository 패턴으로 데이터 소스 교체 용이
4. **에러 복구**: 자동 롤백 메커니즘 구현

---

## ⏱️ 설명 시간 배분 (30분 기준)

- **개요 및 마이그레이션 배경**: 5분
- **Repository 패턴 설명**: 8분
- **Provider 및 Optimistic UI**: 10분
- **데이터 모델 및 Firebase 설정**: 4분
- **질의응답**: 3분
