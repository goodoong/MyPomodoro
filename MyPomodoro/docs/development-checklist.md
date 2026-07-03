# MyPomodoro MVP 개발 체크리스트

> 기준: [architecture.md](./architecture.md) · [specs/](./specs/README.md)  
> 규칙: **각 작업은 1~2시간 내 완료** 가능한 단위로 분할  
> 예상 총 소요: **약 35~45시간** (작업 30개)

---

## 사용 방법

- `[ ]` 완료 시 `[x]`로 체크
- 작업 순서는 **의존성 순** — 위에서부터 진행
- 각 작업의 **완료 조건**을 만족해야 다음 작업으로 이동
- ⏱ 표시는 예상 소요 시간

---

## Phase 0 — 프로젝트 기반 (3~4시간)

### 0-1. 폴더 구조 및 Xcode 그룹 생성 ⏱ 1h

- [x] `App/`, `Views/`, `ViewModels/`, `Models/`, `Services/`, `Utilities/` 폴더 생성
- [x] Xcode 프로젝트에 동일한 Group 구조 반영
- [x] 기존 `ContentView.swift` 정리 (이후 `MainTabView`로 대체 예정)

**완료 조건**: architecture.md 폴더 트리와 실제 프로젝트 구조가 일치

**참고**: [architecture.md — 폴더 구조](./architecture.md#폴더-구조)

---

### 0-2. 상수 · Enum 정의 ⏱ 1h

- [x] `AppConstants.swift` — 집중 25분, 휴식 5분, 목표 120분, 입력 범위
- [x] `TimerMode.swift` — `focus`, `break`
- [x] `TimerState.swift` — `idle`, `running`, `paused`
- [x] `DateRange.swift` — `today`, `thisWeek`
- [x] `AppTab.swift` — `home`, `timer`, `statistics`, `settings`

**완료 조건**: 빌드 성공, 기본값이 specs·architecture와 일치

**참고**: [settings.md](./specs/settings.md), [focus-timer.md](./specs/focus-timer.md)

---

### 0-3. 유틸리티 Extension ⏱ 1h

- [x] `Date+Calendar.swift` — 오늘 시작/끝, 이번 주(월~일) 범위 계산
- [x] `TimeInterval+Formatting.swift` — `mm:ss`, 분 단위 표시

**완료 조건**: 오늘·이번 주 `DateInterval` 반환 단위 테스트 또는 Preview에서 확인

**참고**: [statistics.md](./specs/statistics.md) — 타임존·로컬 캘린더 집계

---

## Phase 1 — Model (3~4시간)

### 1-1. SwiftData 엔티티 ⏱ 1~2h

- [x] `Subject.swift` — id, name, colorHex, createdAt, sortOrder, isDeleted
- [x] `StudySession.swift` — id, subjectId, startedAt, endedAt, durationSeconds, isCompleted, createdAt
- [x] `DailyGoal.swift` — id, targetMinutes, updatedAt
- [x] `Subject` ↔ `StudySession` Relationship 설정

**완료 조건**: `@Model` 3종 컴파일, relationship 정상

**참고**: [architecture.md — Model](./architecture.md#model), [study-session-storage.md](./specs/study-session-storage.md)

---

### 1-2. Presentation Model ⏱ 1h

- [x] `TodaySummary.swift`
- [x] `StatisticsSummary.swift`
- [x] `SubjectDistributionItem.swift`

**완료 조건**: SwiftData 엔티티와 분리된 struct 3종, `Identifiable` 적용

**참고**: [home.md](./specs/home.md), [statistics.md](./specs/statistics.md)

---

## Phase 2 — Service 기반 (2~3시간)

### 2-1. Service Protocol 정의 ⏱ 1h

- [x] `TimerEngineProtocol.swift`
- [x] `StudySessionServiceProtocol.swift`
- [x] `SubjectServiceProtocol.swift`
- [x] `StatisticsServiceProtocol.swift`
- [x] `SettingsServiceProtocol.swift`

**완료 조건**: architecture.md 메서드 시그니처와 일치하는 Protocol 5종

**참고**: [architecture.md — Service](./architecture.md#service)

---

### 2-2. UserPreferencesStore ⏱ 1h

- [x] `lastSelectedSubjectId` get/set 구현 (UserDefaults)
- [x] UUID 인코딩·디코딩 처리

**완료 조건**: 값 저장 후 앱 재실행 시 복원 확인

**참고**: [subject-selection.md](./specs/subject-selection.md) — 마지막 선택 과목

---

## Phase 3 — Service 구현 (8~10시간)

### 3-1. SettingsService ⏱ 1~2h

- [x] 집중·휴식 시간 UserDefaults 저장 (범위 1~180, 1~60)
- [x] `DailyGoal` SwiftData 읽기/쓰기 (단일 레코드 유지)
- [x] 기본값 fallback (25, 5, 120)

**완료 조건**: 설정 변경 후 재실행해도 값 유지

**참고**: [settings.md](./specs/settings.md)

---

### 3-2. SubjectService ⏱ 1~2h

- [x] `fetchAll()` — isDeleted 제외, sortOrder 정렬
- [x] `create` — 이름 1~30자, 중복 차단
- [x] `update`, `softDelete` — 삭제 확인은 ViewModel/View에서
- [x] `selectedSubject`, `setSelectedSubject` — UserPreferencesStore 연동

**완료 조건**: 과목 CRUD + 마지막 선택 과목 동작

**참고**: [subject-selection.md](./specs/subject-selection.md)

---

### 3-3. StudySessionService ⏱ 1~2h

- [x] `saveCompleted` — 1분 미만 미저장, endedAt ≥ startedAt, subjectId 필수
- [x] `fetchSessions(in:)` — DateInterval 범위 조회
- [x] `fetchTodaySessions()`

**완료 조건**: 유효 세션만 저장, 예외 입력 시 throw 또는 Result 반환

**참고**: [study-session-storage.md](./specs/study-session-storage.md)

---

### 3-4. StatisticsService ⏱ 1~2h

- [x] `todaySummary(goalMinutes:)` — 시간 합계, 세션 수, 달성률
- [x] `summary(for:)` — 일별·주별 분 합계
- [x] `subjectDistribution(for:)` — 과목별 분·비율, 삭제된 과목 처리

**완료 조건**: 샘플 세션 데이터로 집계 결과 검증

**참고**: [statistics.md](./specs/statistics.md), [home.md](./specs/home.md)

---

### 3-5. TimerEngine — 기본 동작 ⏱ 1~2h

- [x] `start`, `pause`, `resume`, `stop`
- [x] 1초 tick, `remainingSeconds` 감소
- [x] `onTick`, `onFocusCompleted`, `onBreakCompleted` 콜백
- [x] 집중 완료 시 break 모드 자동 전환 준비 (콜백만)

**완료 조건**: 콘솔 또는 단위 테스트로 25분→0초→콜백 호출 확인

**참고**: [focus-timer.md](./specs/focus-timer.md)

---

### 3-6. TimerEngine — 백그라운드 보정 ⏱ 1h

- [x] `sessionStartAt` 기록
- [x] `syncRemainingTime(now:)` — 포그라운드 복귀 시 남은 시간 재계산
- [x] 0 이하 도달 시 완료 콜백 처리

**완료 조건**: 백그라운드 1~2분 후 복귀 시 시간 오차 1초 이내

**참고**: [focus-timer.md](./specs/focus-timer.md) — 백그라운드 예외

---

## Phase 4 — 앱 셸 · DI (3~4시간)

### 4-1. AppDependencies + ModelContainer ⏱ 1~2h

- [x] `MyPomodoroApp`에 `.modelContainer(for:)` 등록
- [x] `AppDependencies` — Service 조립, ViewModel factory 메서드
- [x] `@MainActor` 적용

**완료 조건**: 앱 실행 시 SwiftData 컨테이너 초기화, Service 주입 가능

**참고**: [architecture.md — 의존성 주입](./architecture.md#의존성-주입)

---

### 4-2. MainTabView ⏱ 1h

- [x] TabView 4탭 (Home · Timer · Statistics · Settings)
- [x] `AppTab` enum 기반 selection 바인딩
- [x] placeholder View 4개 연결

**완료 조건**: 탭 전환 동작, 아이콘·라벨 표시

**참고**: [common.md](./specs/common.md) — 네비게이션

---

### 4-3. 공통 UI 컴포넌트 ⏱ 1h

- [x] `EmptyStateView` — 메시지 + 선택적 액션 버튼
- [x] `ToastView` 또는 alert modifier — 저장 실패 등

**완료 조건**: Preview에서 두 컴포넌트 확인

**참고**: [statistics.md](./specs/statistics.md), [study-session-storage.md](./specs/study-session-storage.md)

---

## Phase 5 — Settings 화면 (4~5시간)

### 5-1. SettingsViewModel ⏱ 1~2h

- [x] 설정값 로드 (focus, break, dailyGoal, subjects)
- [x] `updateFocusMinutes`, `updateBreakMinutes`, `updateDailyGoal`
- [x] `addSubject`, `updateSubject`, `deleteSubject`
- [x] validationError 상태 관리

**완료 조건**: Service 호출만으로 설정·과목 변경 가능

**참고**: [architecture.md — SettingsViewModel](./architecture.md#settingsviewmodel)

---

### 5-2. SettingsView — 타이머 · 목표 섹션 ⏱ 1~2h

- [x] `TimerDurationSection` — Stepper/Slider, 범위 제한
- [x] `DailyGoalSection` — 10~720분
- [x] Dark Mode First 스타일 적용

**완료 조건**: Settings에서 시간·목표 변경 시 즉시 반영

**참고**: [settings.md](./specs/settings.md)

---

### 5-3. SettingsView — 과목 관리 ⏱ 1~2h

- [x] `SubjectManagementSection` — 목록, 삭제
- [x] `SubjectEditSheet` — 추가·수정, 색상 프리셋 6색
- [x] 빈 이름·중복 이름 UI 피드백

**완료 조건**: Settings에서 과목 추가·수정·삭제 완료

**참고**: [subject-selection.md](./specs/subject-selection.md)

---

## Phase 6 — Timer 화면 (6~8시간) ⭐ 핵심

### 6-1. TimerViewModel — 기본 제어 ⏱ 1~2h

- [x] SettingsService에서 duration 로드
- [x] `start`, `pause`, `resume`, `stop` → TimerEngine 위임
- [x] `canStart` — 과목 선택·시간 유효성
- [x] 과목 목록·선택 상태 (`subjects`, `selectedSubject`)

**완료 조건**: ViewModel 단독으로 타이머 시작·정지 상태 전환

**참고**: [focus-timer.md](./specs/focus-timer.md), [subject-selection.md](./specs/subject-selection.md)

---

### 6-2. TimerView — 표시 · 컨트롤 UI ⏱ 1~2h

- [x] `TimerDisplayView` — 모드 라벨, `mm:ss` 표시
- [x] `TimerControlBar` — 시작/일시정지/재개/중단 버튼 상태 분기
- [x] `TimerView` 조합 + Dark Mode

**완료 조건**: Timer 탭에서 시각적 타이머 동작 (저장 없이)

**참고**: [common.md](./specs/common.md) — 타이머 화면 구성

---

### 6-3. SubjectPickerView + 빈 상태 ⏱ 1h

- [x] 과목 피커/목록 UI
- [x] 과목 0개 시 "과목을 먼저 추가하세요" + Settings 유도
- [x] 타이머 실행 중 과목 변경 비활성화

**완료 조건**: specs 과목 선택·빈 목록 예외 UI 충족

**참고**: [subject-selection.md](./specs/subject-selection.md)

---

### 6-4. TimerViewModel — 세션 저장 · 모드 전환 ⏱ 1~2h

- [x] 집중 완료 → `StudySessionService.saveCompleted`
- [x] 저장 성공 → break 타이머 자동 시작
- [x] `stop()` during focus → 저장 안 함 (AC-5)
- [x] 휴식 완료/중단 → 통계 미포함

**완료 조건**: AC-1, AC-5 수동 검증 통과

**참고**: [study-session-storage.md](./specs/study-session-storage.md), [common.md](./specs/common.md)

---

### 6-5. TimerViewModel — scenePhase 연동 ⏱ 1h

- [x] `onScenePhaseChange` — background/inactive 시 시각 정지
- [x] active 복귀 시 `syncRemainingTime`
- [x] 저장 실패 시 `alertMessage` / Toast

**완료 조건**: 백그라운드 후 타이머 정확도 유지

**참고**: [focus-timer.md](./specs/focus-timer.md)

---

## Phase 7 — Home 화면 (2~3시간)

### 7-1. HomeViewModel ⏱ 1h

- [x] `load()` — `todaySummary`, `lastSubject`
- [x] `requestStartTimer(onNavigate:)` — Timer 탭 전환 콜백
- [x] 오늘 기록 없음 empty 처리

**완료 조건**: Service 데이터가 Presentation Model로 변환

**참고**: [home.md](./specs/home.md)

---

### 7-2. HomeView + 컴포넌트 ⏱ 1~2h

- [x] `TodaySummaryCard` — 시간, 세션 수, 달성률
- [x] `QuickStartSection` — 마지막 과목, 타이머 시작 버튼
- [x] 기록 없음 empty state

**완료 조건**: Home 탭에서 오늘 요약 표시, Timer 탭 이동 동작

**참고**: [home.md](./specs/home.md)

---

## Phase 8 — Statistics 화면 (3~4시간)

### 8-1. StatisticsViewModel ⏱ 1~2h

- [x] `dateRange` 상태, `setDateRange`
- [x] `load()` — dailyMinutes, weeklyMinutes, distribution
- [x] `isEmpty` 판단

**완료 조건**: 기간 전환 시 집계 결과 갱신

**참고**: [statistics.md](./specs/statistics.md)

---

### 8-2. StatisticsView — 기간 요약 ⏱ 1h

- [x] `PeriodSummaryView` — 오늘/이번 주 분 표시
- [x] `dateRange` 토글 또는 SegmentedControl

**완료 조건**: AC-2 — 일별·주별 시간 분 단위 표시

**참고**: [statistics.md](./specs/statistics.md)

---

### 8-3. StatisticsView — 과목 분포 · 빈 상태 ⏱ 1~2h

- [x] `SubjectDistributionChart` — 막대 또는 원형 차트
- [x] `StatisticsEmptyState` — 기록 없을 때 Timer 유도
- [x] 삭제된 과목 "알 수 없는 과목" 표시

**완료 조건**: AC-3 — 과목별 비율 표시

**참고**: [statistics.md](./specs/statistics.md)

---

## Phase 9 — 통합 · 마무리 (3~4시간)

### 9-1. 탭 간 연동 · 데이터 갱신 ⏱ 1~2h

- [x] Home → Timer 빠른 시작 (탭 + 마지막 과목)
- [x] 세션 저장 후 Home·Statistics `onAppear` 갱신
- [x] Settings 변경 시 Timer 다음 세션부터 반영

**완료 조건**: 탭 이동 없이도 데이터 정합성 유지

**참고**: [architecture.md — ViewModel 간 공유](./architecture.md#viewmodel-간-공유)

---

### 9-2. MVP 수용 기준(AC) 전체 검증 ⏱ 1~2h

- [x] **AC-1**: 25분 집중 완료 → `StudySession` 저장
- [x] **AC-2**: Statistics 일·주 공부 시간 표시
- [x] **AC-3**: Statistics 과목별 비율 표시
- [x] **AC-4**: 재실행 후 과목·세션·설정 유지
- [x] **AC-5**: 미완료 중단 시 통계 미반영

**완료 조건**: common.md AC 5항목 전부 통과

**참고**: [common.md](./specs/common.md)

---

### 9-3. UI 마감 · 정리 ⏱ 1h

- [x] Dark Mode First 전 화면 점검
- [x] `ContentView.swift` 제거 또는 미사용 코드 정리
- [ ] 앱 아이콘·AccentColor 확인 (선택)

**완료 조건**: 4탭 MVP 빌드·실행 안정

**참고**: [project.md](./project.md) — Theme

---

## 진행 요약

| Phase | 작업 수 | 예상 시간 | 누적 |
|-------|---------|-----------|------|
| 0 기반 | 3 | 3~4h | 4h |
| 1 Model | 2 | 3~4h | 8h |
| 2 Service 기반 | 2 | 2~3h | 11h |
| 3 Service 구현 | 6 | 8~10h | 21h |
| 4 앱 셸 | 3 | 3~4h | 25h |
| 5 Settings | 3 | 4~5h | 30h |
| 6 Timer | 5 | 6~8h | 38h |
| 7 Home | 2 | 2~3h | 41h |
| 8 Statistics | 3 | 3~4h | 45h |
| 9 통합 | 3 | 3~4h | 48h |

---

## 마일스톤 (중간 점검용)

| 마일스톤 | 완료 Phase | 확인 방법 |
|----------|------------|-----------|
| **M1 — 데이터 계층 완료** | Phase 0~3 | Service 단위로 CRUD·집계·타이머 동작 |
| **M2 — 설정 가능한 앱** | Phase 4~5 | Settings에서 과목·시간·목표 변경 |
| **M3 — 핵심 루프 완료** | Phase 6 | 타이머 완료 → 세션 저장 → 통계 반영 |
| **M4 — MVP 출시** | Phase 7~9 | AC 5항목 전부 통과 |

---

## specs ↔ 작업 빠른 참조

| specs | 관련 작업 |
|-------|-----------|
| [focus-timer](./specs/focus-timer.md) | 3-5, 3-6, 6-1~6-5 |
| [subject-selection](./specs/subject-selection.md) | 3-2, 5-3, 6-1, 6-3 |
| [study-session-storage](./specs/study-session-storage.md) | 1-1, 3-3, 6-4 |
| [statistics](./specs/statistics.md) | 3-4, 8-1~8-3 |
| [home](./specs/home.md) | 7-1, 7-2 |
| [settings](./specs/settings.md) | 3-1, 5-1~5-3 |
| [common](./specs/common.md) | 4-2, 9-2 |
