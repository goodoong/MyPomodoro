# 공부 시간 저장

[← 목차](./README.md)

## 기능 설명

완료된 집중 세션의 시작·종료 시각, 실제 집중 시간, 연결 과목을 로컬(SwiftData)에 영구 저장한다. 이 데이터는 Statistics 탭의 집계 원천이 된다.

## 사용자 행동

1. 과목을 선택하고 집중 타이머를 시작한다.
2. 집중 세션을 끝까지 완료하거나(자동 저장), 중단 시 저장 여부를 확인한다(MVP: 완료 시에만 자동 저장).
3. **Statistics** 또는 **Home** 탭에서 저장된 기록이 반영된 결과를 확인한다.

## 입력값

| 항목 | 타입 | 설명 |
|------|------|------|
| `subjectId` | `UUID` | 연결 과목 |
| `startedAt` | `Date` | 세션 시작 시각 |
| `endedAt` | `Date` | 세션 종료 시각 |
| `plannedDuration` | `TimeInterval` | 설정된 집중 시간(초) |
| `actualDuration` | `TimeInterval` | 실제 집중 시간(초) |
| `isCompleted` | `Bool` | 계획 시간 대비 완료 여부 |

## 저장 데이터

**모델: `StudySession`**

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | `UUID` | 고유 식별자 |
| `subjectId` | `UUID` | FK → `Subject.id` |
| `startedAt` | `Date` | 시작 시각 |
| `endedAt` | `Date` | 종료 시각 |
| `durationSeconds` | `Int` | 실제 집중 시간(초) |
| `isCompleted` | `Bool` | 완료 여부 |
| `createdAt` | `Date` | 레코드 생성 시각 |

**관계**

- `Subject` 1 : N `StudySession`

## 예외 상황

| 상황 | 처리 |
|------|------|
| 집중 시간 1분 미만 | 저장하지 않음 |
| `endedAt` < `startedAt` | 저장 차단, 내부 로그 기록 |
| SwiftData 저장 실패 | 사용자에게 "저장에 실패했습니다" 토스트 표시, 메모리에 임시 보관 후 재시도 |
| 연결된 `subjectId`가 없음 | 저장 차단, 과목 선택 요구 |
| 동일 세션 중복 저장 | `id` 기준 upsert로 중복 방지 |
