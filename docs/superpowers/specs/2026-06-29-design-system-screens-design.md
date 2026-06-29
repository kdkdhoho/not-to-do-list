# Not-To-Do-List — 화면 & 컴포넌트 디자인 스펙

작성일: 2026-06-29
대상 파일: `DESIGN.pen` (Pencil)
연관 기획: `docs/PLAN.md`

## 1. 목표

Not-To-Do-List 앱의 화면 5개와, 화면 전반에서 반복되는 재사용 컴포넌트를 `DESIGN.pen`에 디자인한다.
토큰(색·타이포·간격·반경)은 이미 Foundation에 정의돼 있으므로 **신규 토큰 정의는 하지 않고**, 그 토큰을
소비하는 **컴포넌트 라이브러리**와 **화면**을 만든다.

## 2. 확정 결정

| 항목 | 결정 |
|------|------|
| 시각 방향(무드) | **강렬·동기부여형** — 고대비, 진행바, 통계 노출 |
| 라이트/다크 | **라이트 우선** (다크는 토큰 자동 처리, 추후 별도 검수) |
| 컴포넌트 배치 | 기존 `Foundation / Components`(템플릿 데모)는 **보존**, 신규 프레임에 앱 전용 컴포넌트 추가 |
| 접근 방식 | **컴포넌트 우선** — reusable 컴포넌트 정의 후 화면이 인스턴스(`ref`)로 조립 |
| 기기 사이즈 | iPhone 393×852 (iPhone 16 기준) |

## 3. 문서 구조 (DESIGN.pen)

기존 Foundation 5개 프레임은 그대로 둔다:
- `Foundation / Color Palette`
- `Foundation / Typography`
- `Foundation / Icons`
- `Foundation / Spacing & Radius`
- `Foundation / Components` (템플릿 데모 — 참고용 보존)

신규 추가:
- **`App / Components`** — 앱 전용 재사용 컴포넌트 라이브러리 (reusable 노드)
- **`App / Screens`** — iPhone 화면 5개 (393×852, 라이트)

## 4. 재사용 컴포넌트 인벤토리 (`App / Components`)

모든 컴포넌트는 토큰만 사용한다 (`$primary-600`, `$secondary-500`, `$spacing-md`, `$radius-lg` 등).
하드코딩 색/사이즈 금지.

| # | 컴포넌트 | 쓰이는 곳 | 구성 |
|---|----------|-----------|------|
| 1 | **HabitCard** | 오늘 | 아이콘+이름 · 🔥스트릭 StatChip · ProgressBar(현재/최고) · 절제율·누적실패 메타 · "오늘 무너짐" LapseButton |
| 2 | **StreakHero** | 상세 | 거대한 `D+N` 카운터 · 최고기록 · 절제율 |
| 3 | **ProgressBar** | 카드/상세 | 현재 스트릭 / 최고 스트릭 대비 진행. fill `primary-600`, track `neutral-200` |
| 4 | **StatChip** | 카드/상세 | 🔥스트릭·절제율% 등 작은 pill 뱃지 |
| 5 | **PrimaryButton** | 전역 | 채워진 pill CTA (인디고 `primary-600`) |
| 6 | **LapseButton** | 카드/상세 | "오늘 무너짐"(destructive `error` 톤) + "실패 취소"(neutral) 변형 |
| 7 | **StatSummaryCard** | 통계 | 평균 스트릭 · 주/월 절제율 요약 |
| 8 | **RankingRow** | 통계 | 습관별 스트릭 랭킹 행 (순위·아이콘·이름·D+N) |
| 9 | **CalendarHeatmap** | 통계/상세 | 월간 그리드, 실패일 `error` 마킹 · 성공일 `neutral`/`success` |
| 10 | **ListRow** | 설정/상세 | 라벨 + 값/토글/chevron (variant) |
| 11 | **SectionHeader** | 전역 | 섹션 타이틀 (+선택적 액션) |
| 12 | **EmptyState** | 오늘 | 아이콘 + 안내 문구 + 추가 CTA |
| 13 | **TextFieldRow** | 시트 | 이름 입력 필드 |
| 14 | **IconPickerGrid** | 시트 | 아이콘 선택 (AppIcon 후보 그리드) |
| 15 | **ColorSwatchGrid** | 시트 | 색상 선택 (AppColor 토큰 스와치) |
| 16 | **TimePickerRow** | 시트/설정 | 리마인더 시간 선택 행 |
| 17 | **LapseHistoryRow** | 상세 | 실패 날짜 + 선택 메모 |
| 18 | **NavBar** | 전역 | 상단 타이틀 + 액션 버튼 |
| 19 | **TabBar** | 전역 | 하단 3탭 (오늘/통계/설정) |

## 5. 화면 5개 (`App / Screens`)

### 5.1 오늘 (Today / Home)
- NavBar (타이틀 "오늘" + `+` 액션)
- HabitCard 리스트 (스크롤)
- 별도 변형 화면: **빈 상태** (EmptyState — "끊고 싶은 것을 추가해 보세요" + 추가 CTA)
- 하단 TabBar (오늘 활성)

### 5.2 통계 (Statistics / Explore)
- NavBar (타이틀 "통계")
- StatSummaryCard (진행 중 평균 스트릭, 이번 주/달 절제율)
- SectionHeader "스트릭 랭킹" + RankingRow 리스트
- SectionHeader "캘린더" + CalendarHeatmap
- 하단 TabBar (통계 활성)

### 5.3 설정 (Settings)
- NavBar (타이틀 "설정")
- 그룹 ListRow:
  - 알림 기본 시간 (TimePickerRow)
  - 테마
  - 데이터 초기화 (destructive)
  - 앱 정보 (버전)
- 하단 TabBar (설정 활성)

### 5.4 습관 상세 (HabitDetail / Detail)
- NavBar (뒤로 + 편집/더보기 액션)
- StreakHero (큰 `D+N` · 최고기록 · 절제율 StatChip)
- CalendarHeatmap
- SectionHeader "실패 히스토리" + LapseHistoryRow 리스트
- 액션: "오늘 무너짐" LapseButton (또는 "실패 취소" 변형) · 편집/보관/삭제 진입

### 5.5 습관 추가·편집 (시트)
- 시트 헤더 (취소 / 타이틀 / 저장)
- TextFieldRow (이름)
- SectionHeader "아이콘" + IconPickerGrid
- SectionHeader "색상" + ColorSwatchGrid
- TimePickerRow (리마인더, 선택)
- 하단 저장 PrimaryButton

## 6. 강렬·동기부여형 비주얼 언어 (토큰 매핑)

- **스트릭/성공 강조** = 🔥 + `secondary-500`(앰버) 또는 `success-500`(그린)
- **진행바 fill** = `primary-600`(인디고), track = `neutral-200`
- **"오늘 무너짐"** = `error` 계열(테두리/텍스트) destructive 톤 — 접근은 쉽게, 시각적으로 축하하지 않음
- **"실패 취소"** = neutral 톤
- **타이포** = 스트릭 숫자는 `display`/`heading1`(Bold) 히어로, 메타는 `caption`
- **카드** = `surface` 배경, `radius-lg`, hairline 보더, 고대비 텍스트
- **간격** = `spacing-md`(17) 기본, 섹션 간 `spacing-lg`(24)

## 7. 범위 밖 (이번 작업 제외)

- 다크 모드 전용 검수 (토큰 자동 처리에 위임, 추후 별도)
- 코드(SwiftUI View) 구현 — 본 작업은 `DESIGN.pen` 디자인까지
- Foundation 토큰 값 변경 — 기존 토큰을 소비만 함
- 위젯, iCloud, 추천 습관, 고급 차트 (MVP 밖)

## 8. 산출물 검증 기준

- `App / Components`에 19개 컴포넌트가 reusable 노드로 존재
- `App / Screens`에 화면 5개(+ 오늘 빈 상태 변형)가 컴포넌트 인스턴스로 조립됨
- 모든 색·폰트·간격·반경이 토큰 참조(`$...`)로 바인딩 (하드코딩 0건)
- 라이트 모드에서 레이아웃 클리핑·오버플로 없음 (snapshot_layout 검증)
