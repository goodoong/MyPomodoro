# MyPomodoro MVP 기능 명세서

> 기준 문서: [project.md](../project.md)  
> 대상 플랫폼: iOS 18+  
> 아키텍처: MVVM · UI: SwiftUI · 저장소: SwiftData

## 기능 명세

| # | 기능 | 문서 |
|---|------|------|
| 1 | 집중 타이머 (Pomodoro) | [focus-timer.md](./focus-timer.md) |
| 2 | 과목 선택 | [subject-selection.md](./subject-selection.md) |
| 3 | 공부 시간 저장 | [study-session-storage.md](./study-session-storage.md) |
| 4 | 기본 통계 | [statistics.md](./statistics.md) |
| 5 | 홈 (Home) | [home.md](./home.md) |
| 6 | 설정 (Settings) | [settings.md](./settings.md) |

## 공통

- [공통 · 비기능 요구사항](./common.md)

## 부록: 화면별 기능 매핑

| 화면 | MVP 기능 |
|------|----------|
| Home | 오늘 요약, 빠른 시작 |
| Timer | Pomodoro, 과목 선택, 세션 저장 트리거 |
| Statistics | 일별/주별 시간, 과목 분포 |
| Settings | 타이머 시간, 일일 목표, 과목 관리 |
