# 설정 (Settings)

[← 목차](./README.md)

## 기능 설명

타이머 기본 시간, 일일 목표, 과목 관리, 앱 기본 정보를 설정한다. MVP 범위에서 Widget·Live Activity·HealthKit은 포함하지 않는다.

## 사용자 행동

1. 집중·휴식 시간(분)을 변경한다.
2. 일일 목표 시간(분)을 설정한다.
3. 과목을 추가·수정·삭제한다.
4. 앱 버전 정보를 확인한다.

## 입력값

| 항목 | 타입 | 범위 | 기본값 |
|------|------|------|--------|
| `focusDurationMinutes` | `Int` | 1~180 | 25 |
| `breakDurationMinutes` | `Int` | 1~60 | 5 |
| `dailyGoalMinutes` | `Int` | 10~720 | 120 |
| 과목 CRUD | — | [과목 선택](./subject-selection.md) 참고 | — |

## 저장 데이터

| 저장 위치 | 필드 | 설명 |
|-----------|------|------|
| UserDefaults / SwiftData | `focusDurationMinutes` | 집중 시간 |
| UserDefaults / SwiftData | `breakDurationMinutes` | 휴식 시간 |
| `DailyGoal` | `targetMinutes` | 일일 목표 |
| `Subject` | — | [과목 선택](./subject-selection.md) 참고 |

## 예외 상황

| 상황 | 처리 |
|------|------|
| 타이머 실행 중 설정 변경 | 집중/휴식 시간 변경은 다음 세션부터 적용 |
| 범위 밖 값 입력 | 슬라이더/스테퍼로 범위 제한, 직접 입력 시 클램핑 |
| 설정 저장 실패 | 이전 값 유지, 오류 메시지 표시 |
