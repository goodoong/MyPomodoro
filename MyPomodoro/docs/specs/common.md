# 공통 · 비기능 요구사항

[← 목차](./README.md)

## 네비게이션

`TabView` 4탭: **Home · Timer · Statistics · Settings**

## UI/UX

- Dark Mode First
- iOS 18+ Human Interface Guidelines 준수
- 타이머 화면: 남은 시간, 현재 모드, 선택 과목, 시작/일시정지/중단 컨트롤

## 데이터 모델 관계 요약

```
Subject (1) ──< StudySession (N)
DailyGoal (단일 또는 최신 1건)
```

## MVP 제외 (명시적 비포함)

- Widget
- Live Activity
- HealthKit
- iCloud 동기화
- 푸시 알림 커스터마이징(시스템 로컬 알림만 MVP 허용 가능)

## 수용 기준 (Acceptance Criteria)

| # | 기준 |
|---|------|
| AC-1 | 과목을 선택하고 25분 집중 타이머를 완료하면 `StudySession`이 저장된다 |
| AC-2 | Statistics에서 오늘·이번 주 공부 시간이 분 단위로 표시된다 |
| AC-3 | Statistics에서 과목별 시간 비율이 표시된다 |
| AC-4 | 앱 재실행 후에도 과목·세션·설정이 유지된다 |
| AC-5 | 타이머 미완료 중단 시 통계에 반영되지 않는다 |
