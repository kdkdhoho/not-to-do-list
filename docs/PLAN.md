# Not-To-Do-List 기획 문서

작성일: 2026-06-29

## 1. 개요

끊고 싶은 습관을 등록하고, 그 습관에 **무너지지 않은 연속 일수(스트릭)** 를 자동으로 쌓는 절제 추적 앱이다.
일반 To-Do 앱이 "할 일"을 더하는 도구라면, 이 앱은 "하지 말 것"을 정해두고 안 한 날을 기록한다.

핵심은 **저마찰**이다. 매일 앱을 열어 체크할 필요가 없다. 아무것도 하지 않으면 스트릭은 매일 자동으로 오르고,
유혹에 졌을 때만 "오늘 무너짐"을 한 번 누르면 된다.

## 2. 핵심 컨셉 & 동작 원리

- 사용자는 끊고 싶은 습관(예: 흡연, 야식, 늦은 밤 SNS)을 등록한다.
- 등록한 시점부터 스트릭이 시작된다.
- 매일 별도 조작 없이 스트릭은 자동으로 +1 된다. (= 그날 무너지지 않았다고 간주)
- 습관에 무너진 날에만 "오늘 무너짐"을 기록한다. 그 순간 스트릭은 0으로 리셋되고, 다음 날부터 다시 쌓인다.
- 실수로 기록했다면 "실패 취소"로 되돌릴 수 있다.

이 모델은 매일 체크인을 강요하지 않으므로, 사용자가 앱을 잊고 지내도 추적이 유지된다.

## 3. 데이터 모델 (SwiftData, 이벤트 소싱)

성공/실패를 매일 저장하지 않고, **무너진 날(실패 이벤트)만** 저장한다. 스트릭과 통계는 이 이벤트로부터 계산으로 도출한다.

### Habit (습관)

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | UUID | 식별자 |
| `name` | String | 습관 이름 |
| `iconName` | String | `AppIcon` case 이름 |
| `colorToken` | String | `AppColor` 토큰 식별자 |
| `createdAt` | Date | 등록 시점 (스트릭 시작 기준) |
| `reminderTime` | Date? | 매일 알림 시간 (없으면 알림 끔) |
| `isArchived` | Bool | 보관 여부 |

### Lapse (실패 이벤트)

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | UUID | 식별자 |
| `habit` | Habit | 소속 습관 (관계) |
| `date` | Date | 무너진 날짜 |
| `note` | String? | 선택 메모 |

### 파생 값 (저장하지 않고 계산)

- `currentStreak` = 오늘 − 마지막 Lapse 날짜 (Lapse가 없으면 `createdAt` 기준)
- `bestStreak` = Lapse들 사이의 최대 간격 (+ 시작~첫 실패, 마지막 실패~오늘 구간 포함)
- `abstinenceRate` = 절제율 = 성공일 / 전체 추적일
- `totalLapses` = 누적 실패 횟수

## 4. 화면 구성

3탭(오늘 / 통계 / 설정) + 습관 상세 + 습관 추가·편집 시트로 구성한다.
템플릿의 기존 화면(Home / Explore / Settings / Detail)에 1:1로 매핑해 구조 변경을 최소화한다.

### 4.1 오늘 (Home)

- 등록한 습관 카드 리스트. 각 카드 구성:
  - 아이콘 + 이름
  - 현재 스트릭 `D+N` 표기
  - "오늘 무너짐" 기록 버튼
- 카드 탭 → 습관 상세로 이동
- 우상단 `+` 버튼 → 습관 추가 시트
- 빈 상태: "끊고 싶은 것을 추가해 보세요" 안내 + 추가 버튼

### 4.2 통계 (Explore → Statistics)

- 전체 요약: 진행 중 평균 스트릭, 이번 주/이번 달 절제율
- 습관별 스트릭 랭킹
- 캘린더 히트맵 — 실패한 날을 마킹

### 4.3 설정 (Settings)

- 알림 기본 시간 설정
- 테마
- 데이터 초기화
- 앱 정보 (버전 등)

### 4.4 습관 상세 (Detail → HabitDetail)

- 큰 스트릭 카운터, 최고 기록(best streak), 절제율
- 실패 히스토리 (날짜 리스트, 메모)
- 캘린더 히트맵
- "오늘 무너짐" 기록 / "실패 취소"
- 습관 편집 / 보관 / 삭제, 알림 시간 편집

### 4.5 습관 추가·편집 (시트)

- 이름 입력
- 아이콘 선택 (`AppIcon`)
- 색상 선택 (`AppColor`)
- 리마인더 시간 설정 (선택)

## 5. 핵심 로직 (Domain)

### StreakCalculator

`[Lapse]`와 `createdAt`를 입력받아 `currentStreak` / `bestStreak` / `abstinenceRate`를 계산하는 **순수 함수** 집합이다.
UI·저장소와 분리해 단위 테스트가 쉽도록 한다.

```
StreakCalculator
  ├── currentStreak(createdAt:lapses:asOf:) -> Int
  ├── bestStreak(createdAt:lapses:asOf:) -> Int
  └── abstinenceRate(createdAt:lapses:asOf:) -> Double
```

`asOf`(기준 날짜)를 주입받아 "오늘"을 테스트에서 고정할 수 있게 한다.

## 6. 알림 (MVP 포함)

- **NotificationScheduler** (Shared/Core) — 습관별 `reminderTime`에 매일 반복되는 로컬 알림을 등록한다.
  - 예: 매일 밤 10시 "오늘도 잘 참았나요?"
- 권한 요청은 사용자가 처음 알림을 켤 때 수행한다.
- 습관 추가·수정·삭제·보관 시 해당 습관의 스케줄을 갱신한다.

## 7. 아키텍처 & 모듈 배치

기존 템플릿 규칙(MVVM, Repository, DI, 3계층 네비게이션, Swift 6 동시성)을 그대로 따른다.

```
Shared/
├── Domain/
│   ├── Entities/        Habit, Lapse
│   └── Interfaces/      HabitRepository (프로토콜)
├── Data/
│   └── Repositories/    SwiftDataHabitRepository (구현체)
└── Core/
    ├── StreakCalculator
    └── NotificationScheduler

Feature/
├── Home/        → Today (오늘)
├── Explore/     → Statistics (통계)
├── Settings/    → Settings
├── Detail/      → HabitDetail (습관 상세)
└── Navigation/  → Route 확장
```

- ViewModel은 `HabitRepository` **프로토콜**에만 의존하고, 구현체는 `AppDIContainer`가 주입한다.
- DTO↔Entity 변환은 Repository 구현체 내부로 가둔다. (SwiftData 모델 ↔ Domain Entity)
- 데이터 흐름: **View → ViewModel → HabitRepository(프로토콜) → SwiftData**

## 8. 네비게이션 (3계층 정책 준수)

- `AppRouter`가 탭별 라우터를 소유하고 각 NavigationView에 주입한다.
- 탭 내부 이동은 각 탭 Router의 `NavigationPath`로 처리한다.
- Route는 `Hashable` enum, associated value에는 식별값(habitId)만 담는다.

```swift
enum TodayRoute: Hashable {
    case detail(habitId: UUID)
}
// 습관 추가/편집은 sheet로 표현
```

- 정방향 데이터: Route의 `habitId` → Router의 `makeViewModel` factory에서 조립
- 역방향 데이터(상세에서 실패 기록 후 목록 갱신): 공유 `HabitRepository`로 자동 동기화

## 9. 디자인 시스템 & 다국어

- 색상·타이포·간격은 `AppColor` / `AppTypography` / `Theme` 토큰만 사용 (하드코딩 금지).
- 아이콘은 `AppIcon`(SF Symbols), 이미지는 `AppImage`.
- 사용자에게 보이는 모든 문자열은 `AppStrings` enum + `Localizable.xcstrings`. 한국어(소스) + 영어.
- 토큰 값의 단일 진실은 `DESIGN.pen` — 값 변경은 Pencil에서 먼저 한 뒤 코드에 반영.

## 10. MVP 범위

### 포함

- 습관 등록 / 편집 / 보관 / 삭제
- 자동 스트릭 + "오늘 무너짐" 기록 / 실패 취소
- 오늘 / 통계 / 설정 3탭 + 습관 상세
- 절제율·최고 기록·캘린더 히트맵
- 로컬 알림 리마인더
- 로컬 저장 (SwiftData)

### 향후 로드맵 (MVP 밖)

- 홈 화면 위젯
- iCloud 동기화
- 추천 습관 라이브러리
- 통계 고급 차트 / 인사이트
