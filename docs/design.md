# Not-To-Do-List Design — 잉걸 (Ember)

작성일: 2026-07-06
기준 문서: `docs/PRD-v1.md` (확정본)
문서 형식 참고: `docs/apple-design-md.md`
개정: 2026-07-06 — PRD §6(국제화) 반영: 로케일 대응 규칙 추가, PRD 섹션 참조 갱신
개정: 2026-07-06 — "오늘 마감" CTA 라운딩 pill → `{rounded.lg}`(16)로 변경. 필은 상태 칩 전용 문법으로 축소
개정: 2026-07-06 — 사용자 노출 용어 정리: 행동 용어 "마감" → **"하루 마무리"**, 소급 버튼 [무너졌어요] → [못 참았어요], 온보딩 컨셉 "참은 날이 쌓여요", habit-row 서브카피 "…원을 아꼈어요!" 형식. "마감"은 내부 서사·모션 명칭(마감 의식)에만 남는다. button-secondary는 시트 위에서 `{colors.canvas}`로 반전

## Overview

이 앱의 핵심 순간은 밤이다. 사용자는 저녁 리마인더(21:00)를 받고, 하루가 끝나기 전에 앱을 열어 **오늘을 마감**한다. 그래서 이 디자인 시스템의 이름은 **잉걸** — 타고 남아 밤새 꺼지지 않는 불씨다. 스트릭(🔥)은 화려한 불꽃놀이가 아니라, 매일 밤 조용히 지키는 잉걸불이다.

캔버스는 **따뜻한 숯색 다크 단일 모드**다. 밤 10시의 방 안 조도에 맞춘 웜톤 차콜 위에, 따뜻한 종이색 잉크로 글을 얹는다. 순수한 검정(#000000)과 순수한 흰색(#FFFFFF)은 시스템 어디에도 없다 — 화면은 인쇄물이 아니라 불가에 앉은 밤이어야 한다.

액센트는 단 하나, **잉걸 오렌지**다. PRD 원칙 3("핵심 행동은 마감 하나")을 색 문법으로 그대로 옮겼다: 핵심 행동이 하나이므로 액센트도 하나이고, 그 액센트는 **"오늘 마감" CTA와 스트릭 불꽃에만** 허락된다. 나머지 모든 UI는 숯과 종이 톤 안에서 조용히 물러난다. 프로스트 블루는 두 번째 액센트가 아니라 ❄ 프리즈 전용 기능색이다.

타이포그래피는 두 목소리다. 한글 UI는 Pretendard가 말하고, **숫자는 IBM Plex Mono가 기록한다**. 마감(마감 = 장부를 닫는 일)이라는 단어 그대로, 🔥 24 · D+37 · 128,000원 같은 수치는 원장의 활자처럼 모노스페이스 탭ular 숫자로 찍힌다. 이 앱에서 숫자는 장식이 아니라 사용자가 쌓아온 자산 그 자체이므로, 숫자에게 고유한 목소리를 준다.

절제를 다루는 앱은 스스로 절제되어야 한다. 그림자 없음, 그라데이션 없음, 컨페티 없음. 시스템에 존재하는 유일한 발광 효과는 **불꽃 글로우 하나**이며, 마감이 완료되는 순간에만 켜진다.

**Key Characteristics:**
- 다크 단일 모드 — 밤의 의식(마감)에 맞춘 웜 차콜 캔버스. 라이트 모드는 로드맵.
- 단일 액센트(잉걸 오렌지)는 "마감" 액션과 스트릭 불꽃에만. 핵심 행동이 하나 = 액센트도 하나.
- 숫자는 IBM Plex Mono, 한글은 Pretendard — 장부의 활자와 대화의 목소리를 분리.
- 무너짐(lapse)에 빨간색을 절대 쓰지 않는다. 기록은 벌이 아니므로 (PRD 원칙 4).
- 그림자 대신 표면 색 단차로 위계를 만든다. 시스템 유일의 글로우는 불꽃 전용.
- 이모지(🔥❄)는 UI에서 금지 — 아이콘(lucide flame/snowflake)으로 그린다. 이모지는 알림·마케팅 카피에서만.
- 문구는 언어 공통 라이팅 원칙(PRD §14) — 대화체·능동형·죄책감 카피 금지. 한국어는 토스 가이드, 영어는 대응 원칙으로 로케일별 집필.
- v1부터 전 세계 배포 (PRD §6) — 한국어·영어 지원, 그 외 로케일은 영어 폴백. 금액·날짜·주 시작 요일은 시스템 로케일 포맷.

## Colors

> 다크 단일 모드다. 아래가 팔레트의 전부이며, 새 색이 필요해 보이면 먼저 표면 단차나 잉크 농도로 해결한다.

### Brand & Accent
- **잉걸 (Ember)** (`{colors.ember}` — #FF6B2C): 시스템의 유일한 액센트. 스트릭 불꽃, "오늘 마감" CTA, 오늘 날짜 링, 획득 배지 스트로크. 이 색이 보이면 "마감과 불꽃에 관한 것"이라는 뜻이다.
- **깊은 잉걸 (Ember Deep)** (`{colors.ember-deep}` — #C94F1A): 잉걸의 눌림(pressed) 상태 전용.
- **잉걸 재 (Ember Soft)** (`{colors.ember-soft}` — rgba(255, 107, 44, 0.14)): 잉걸 계열의 은은한 틴트 배경. 스트릭 헤더의 배경 승온, 획득 배지 배경.
- **잉걸 위 잉크 (On Ember)** (`{colors.on-ember}` — #1C0E04): 잉걸 배경 위 텍스트. 흰색이 아니라 어두운 갈흑색 — CTA가 광고 배너가 아니라 달궈진 금속판처럼 읽힌다.

### Functional
- **프로스트 (Frost)** (`{colors.frost}` — #9CCFE7): ❄ 프리즈 전용 기능색. 프리즈 칩, 캘린더의 프리즈 사용일 표기. **두 번째 액센트가 아니다** — 인터랙티브 요소에 쓰지 않는다.
- **프로스트 재 (Frost Soft)** (`{colors.frost-soft}` — rgba(156, 207, 231, 0.14)): 프리즈 칩 배경 틴트.
- **위험 (Danger)** (`{colors.danger}` — #E5484D): 파괴적 행동(습관 삭제, 데이터 초기화) 확인에만. **무너짐 기록에는 절대 쓰지 않는다.**

### Surface
- **숯 (Canvas)** (`{colors.canvas}` — #151210): 기본 캔버스. 웜톤 차콜 — 순수 검정이 아니라 불가의 어둠.
- **화로 (Surface)** (`{colors.surface}` — #1E1813): 카드, 리스트 행 배경. 캔버스에서 한 단계 승온.
- **화로 위 (Surface Raised)** (`{colors.surface-raised}` — #282017): 바텀시트, 칩, 입력 필드. 두 단계 승온. 위계는 그림자가 아니라 이 3단 색 단차가 만든다.
- **헤어라인 (Hairline)** (`{colors.hairline}` — #352C21): 1px 구분선. 표면 단차로 부족할 때만 최소한으로.
- **오버레이 (Overlay)** (`{colors.overlay}` — rgba(12, 9, 6, 0.6)): 시트·모달 뒤 딤. 마감 의식 모션의 화면 감광에도 재사용.

### Ink (텍스트)
- **잉크 (Ink)** (`{colors.ink}` — #F3ECE2): 기본 텍스트. 따뜻한 종이색 — 순수 흰색 금지.
- **옅은 잉크 (Ink Muted)** (`{colors.ink-muted}` — #A79A8B): 보조 텍스트, 서브카피, 비강조 수치.
- **희미한 잉크 (Ink Faint)** (`{colors.ink-faint}` — #6E6255): 플레이스홀더, 캘린더 미기록일, 잠긴 배지. 본문 정보 전달에는 쓰지 않는다(대비 부족).
- **꺼진 잉크 (Ink Disabled)** (`{colors.ink-disabled}` — #4A4137): 비활성 상태 전용.

### 기록 표기 원칙 (색의 도덕)
캘린더와 기록 UI에서 하루의 상태는 **색이 아니라 채움(fill)의 문법**으로 구분한다:
- 무너짐 없이 마감한 날 = `{colors.ink}` **채운 원**
- 무너짐을 기록하고 마감한 날 = `{colors.ink}` **테두리 원** (같은 색, 같은 크기 — "기록했다"는 같은 격이다)
- 프리즈로 메운 날 = `{colors.frost}` 채운 원 + 눈꽃 글리프
- 미기록/스트릭 끊김 = `{colors.ink-faint}` 작은 점
- 오늘 = `{colors.ember}` 링

성공=초록, 실패=빨강의 신호등 문법을 의도적으로 버린다. 이 앱에서 실패는 "기록한 하루"이지 "빨간 날"이 아니다.

### Gradient
**장식용 그라데이션 없음.** 온기는 웜톤 팔레트와 불꽃 글로우가 만든다. 유일한 예외는 위젯 배경에 허용되는 캔버스→화로의 미세한 수직 단차(감지 한계 수준)뿐이다.

## Typography

### Font Family
- **UI 텍스트 (한글·영문)**: `Pretendard` — 모든 UI 텍스트, 버튼, 라벨. 라틴 글리프를 포함하므로 영어 로케일도 같은 패밀리를 쓴다. 앱에 이미 번들되어 있다.
- **수치 (Numerals)**: `IBM Plex Mono` — 스트릭 카운터, D+N, 아낀 돈·시간, 캘린더 날짜, 위젯 숫자 등 **데이터 수치 전용**. SIL OFL 라이선스로 앱 번들 가능. 태생이 tabular라 숫자 폭이 고정 — 카운트업 애니메이션에서 흔들리지 않는다.
- **금액 표기**: 통화 기호를 포함한 포맷된 금액 전체(₩54,000 / $54 / 54 €)를 mono로 찍는다. 기호 위치·천단위 구분은 시스템 `FormatStyle`이 정한다 — 디자인이 통화별 포맷을 재발명하지 않는다.
- 본문 문장 안에 섞이는 숫자(예: "3일 연속")는 Pretendard를 그대로 쓴다. Plex Mono는 **수치가 주인공인 자리**에만.

### Hierarchy

| Token | Font | Size | Weight | Line Height | Tracking | Use |
|---|---|---|---|---|---|---|
| `{typography.numeral-hero}` | IBM Plex Mono | 64 | 600 | 1.0 | -1.0 | 홈 스트릭 카운터 — 앱에서 가장 큰 활자 |
| `{typography.numeral-lg}` | IBM Plex Mono | 34 | 600 | 1.1 | -0.5 | 습관 상세 D+N, 복귀 화면 자산, 중형 위젯 |
| `{typography.numeral-md}` | IBM Plex Mono | 20 | 500 | 1.2 | 0 | 통계 값(총 절제일·아낀 돈), 소형 위젯 |
| `{typography.numeral-sm}` | IBM Plex Mono | 15 | 500 | 1.2 | 0 | 리스트 행의 D+N, 프리즈 보유 수 |
| `{typography.numeral-cal}` | IBM Plex Mono | 13 | 500 | 1.0 | 0 | 캘린더 날짜 |
| `{typography.display}` | Pretendard | 28 | 700 | 1.25 | -0.5 | 온보딩·복귀 화면 헤드라인 |
| `{typography.title}` | Pretendard | 22 | 600 | 1.3 | -0.3 | 화면 타이틀 |
| `{typography.heading}` | Pretendard | 18 | 600 | 1.35 | -0.2 | 카드·시트 제목 |
| `{typography.body-strong}` | Pretendard | 16 | 600 | 1.5 | 0 | 습관 이름, 버튼 라벨 |
| `{typography.body}` | Pretendard | 16 | 400 | 1.5 | 0 | 본문, 설명 |
| `{typography.caption}` | Pretendard | 13 | 500 | 1.4 | 0 | 보조 설명, 수치 라벨 |
| `{typography.label}` | Pretendard | 12 | 500 | 1.3 | 0.2 | 칩, 탭 라벨, 캘린더 요일 |
| `{typography.micro}` | Pretendard | 11 | 500 | 1.3 | 0.2 | 위젯 라벨, 법적 고지 |

### Principles
- **숫자가 주인공인 자리는 항상 Plex Mono.** 스트릭·자산·D+N은 이 앱이 파는 상품이다. 상품에는 고유 서체를 준다.
- **큰 숫자, 작은 라벨.** `numeral-hero` 옆의 라벨("일째 마감")은 `caption`으로 조용히. 숫자와 라벨의 크기 대비가 위계의 전부다.
- **웨이트 사다리는 400 / 500 / 600 / 700.** 300은 없다 — 다크 배경 위 작은 한글에서 가독성이 무너진다. 700은 `display` 전용.
- **한글 디스플레이는 28pt로 충분하다.** 모바일에서 한글 헤드라인을 그 이상 키우면 두 어절이 못 들어간다. 시각적 스케일은 숫자(64pt)가 담당한다.
- **행간은 역할별 고정.** 수치 1.0–1.2 (한 줄 활자), 헤드라인 1.25–1.35, 본문 1.5. 본문 행간을 1.5 아래로 줄이지 않는다.
- 마이너스 트래킹은 22pt 이상에서만. 캡션·라벨은 +0.2로 살짝 벌린다.

### Dynamic Type
- 본문 계열(`body`, `body-strong`, `caption`)은 Dynamic Type 스케일링을 따른다.
- 수치 계열(`numeral-*`)은 **레이아웃 파괴 방지를 위해 상한 캡**(xxxLarge까지)을 두되, VoiceOver 라벨로 전체 값을 읽어준다 (예: "체크인 스트릭 24일").

## Layout

### Spacing System
- **기본 단위 4pt.** 구조 간격은 8/16/24/32/48로 스냅.
- **Tokens:** `{spacing.xs}` 4 · `{spacing.sm}` 8 · `{spacing.md}` 16 · `{spacing.lg}` 24 · `{spacing.xl}` 32 · `{spacing.xxl}` 48
- **화면 좌우 패딩:** `{spacing.screen-h}` 20 — 모든 화면 공통.
- **카드 내부 패딩:** `{spacing.md}` 16 (컴팩트 행) ~ `{spacing.lg}` 24 (히어로 카드).
- **섹션 간격:** `{spacing.xl}` 32. 홈의 스트릭 헤더 아래만 `{spacing.xxl}` 48 — 불꽃에게 숨 쉴 공간을 준다.

### 화면 지도 (MVP)

```
[탭] 오늘          [탭] 기록            [탭] 설정
 ├ 스트릭 헤더      ├ 기록 캘린더         ├ 리마인더 시간
 ├ 소급 확인 카드    ├ 배지 그리드         ├ 습관 관리(보관·삭제)
 ├ 습관 리스트      └ 습관별 절제 진도     └ 데이터 초기화
 └ 하루 마무리 CTA
[시트] 하루 마무리 플로우 · 무너짐 기록 · 습관 추가(프리셋) · 배지 획득
[전면] 온보딩(3단계) · 복귀 화면
```

홈(오늘)의 수직 구조 — 위에서 아래로 "자산 → 오늘 할 일 → 행동":

```
┌──────────────────────────────┐
│  ◐ 21:47                     │  상태영역 (숯)
│                              │
│   🔥(icon)  2 4              │  스트릭 헤더: numeral-hero
│   일째 마감    ❄ ×2          │  caption + 프리즈 칩
│                              │
│  ┌────────────────────────┐  │
│  │ 어제는 어땠어요?          │  │  소급 확인 카드 (조건부)
│  │ [참았어요][무너졌어요][…] │  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ 🚬 담배        D+37     │  │  습관 행 (화로 표면)
│  ├────────────────────────┤  │
│  │ 🍗 야식        D+12     │  │
│  └────────────────────────┘  │
│                              │
│  ╭────────────────────────╮  │
│  │      오늘 마감하기        │  │  잉걸 필 CTA (하단 고정)
│  ╰────────────────────────╯  │
└──────────────────────────────┘
```

### Whitespace Philosophy
밤에 보는 화면이므로 밀도를 낮게 유지한다. 홈에는 스트릭 헤더, 습관 리스트, CTA — 세 가지만 있다. 통계·캘린더·배지는 기록 탭으로 물러난다. 빈 공간은 채울 곳이 아니라 숯의 어둠 그 자체가 콘텐츠다. 단, 기록 캘린더만은 의도적으로 밀도를 올린다 — 쌓인 날들이 한눈에 보이는 것이 동기부여이기 때문이다.

## Elevation & Depth

| Level | Treatment | Use |
|---|---|---|
| Flat | `{colors.canvas}` | 화면 배경, 탭 바 |
| Surface | `{colors.surface}` 색 단차 | 카드, 습관 행 |
| Raised | `{colors.surface-raised}` 색 단차 | 바텀시트, 칩, 입력 필드 |
| Hairline | 1px `{colors.hairline}` | 표면 단차로 부족한 곳의 구분선 (캘린더 주 구분 등) |
| Dim | `{colors.overlay}` | 시트 뒤 딤, 마감 의식의 화면 감광 |
| **Ember Glow** | `0 0 24px rgba(255, 107, 44, 0.35)` | **시스템 유일의 발광.** 마감 완료 순간의 불꽃, 홈 스트릭 아이콘 |

**그림자 철학.** 드롭섀도는 시스템에 존재하지 않는다. 위계는 (a) 3단 표면 색 단차, (b) 오버레이 딤으로 만든다. 유일한 발광인 잉걸 글로우는 UI 위계 장치가 아니라 **보상 신호**다 — 카드·버튼·텍스트에 절대 바르지 않고, 불꽃에만 허락한다. Apple이 단 하나의 제품 그림자만 허용하듯, 잉걸은 단 하나의 글로우만 허용한다.

## Shapes

### Border Radius Scale

| Token | Value | Use |
|---|---|---|
| `{rounded.sm}` | 8 | 캘린더 도트 컨테이너, 인라인 태그 |
| `{rounded.md}` | 12 | 보조 버튼, 입력 필드, 프리셋 셀 |
| `{rounded.lg}` | 16 | 카드, 습관 행, 위젯 내부 블록, **"오늘 마감" CTA** |
| `{rounded.xl}` | 24 | 바텀시트 상단 모서리 |
| `{rounded.pill}` | 9999 | **상태 칩 전용** (❄ ×2 · 마감 완료 칩) — 필은 이 앱의 상태 문법 |

- 모든 라운딩은 iOS **continuous corner**(squircle)로 적용한다.
- 필 문법: 필 모양이 보이면 "상태(❄ ×2, 마감 완료)를 알리는 것"이다. 카드나 이미지에 필을 쓰지 않는다.
- 습관 아이콘 컨테이너는 44×44 원형 — 습관의 색은 이 원 안에만 산다 (아이콘 틴트 + 12% 배경). 습관 색이 행 전체나 화면으로 번지지 않게 가둔다.

## Motion

### System Micro-interaction
- 모든 눌림: `scale 0.97` + 80ms ease-out. 시스템 전역에서 유일한 버튼 피드백.
- 리스트 토글(무너짐 체크): 잉크 채움이 안에서 밖으로 80ms. 바운스 없음.
- Reduced Motion 설정 시 모든 모션은 크로스페이드로 대체.

### 마감 의식 (The Closing Ritual) — 시그니처 모션
앱에서 **단 하나뿐인 연출 순간**. "오늘 마감하기" 확정 직후 약 1.2초:

1. 화면이 `{colors.overlay}`로 반 단계 감광한다 — 방의 불을 끄듯.
2. 습관 행들이 위에서부터 순서대로 확정 상태로 잠긴다 (스태거 60ms).
3. 스트릭 숫자가 모노 활자로 틱업(+1)하고, 불꽃 아이콘에 잉걸 글로우가 한 번 맥동한다.
4. 햅틱 `.success`. 카피: "오늘도 마감했어요. 🔥 24일째예요" (알림·토스트라 이모지 허용).

배지 획득이 있으면 이 시퀀스가 끝난 뒤 시트로 이어진다. 컨페티·파티클·사운드 없음 — 축하는 불씨 하나로 충분하다. 시퀀스는 탭으로 스킵 가능.

## Components

### Global

**`tab-bar`** — 하단 3탭 (오늘 · 기록 · 설정). 배경 `{colors.canvas}` + 상단 1px `{colors.hairline}`. 활성 탭은 `{colors.ink}`, 비활성 `{colors.ink-faint}`. **잉걸을 쓰지 않는다** — 탭 이동은 핵심 행동이 아니다. 라벨 `{typography.label}`.

**`nav-title`** — 화면 상단 타이틀 `{typography.title}`. 내비게이션 바 배경은 캔버스와 동일(구분선 없음), 스크롤 시에만 하단 헤어라인이 나타난다.

### 스트릭 & 프리즈

**`streak-hearth`** — 홈 상단 히어로. 배경 `{colors.canvas}`(카드 아님 — 화면 그 자체가 화로다). 구성: flame 아이콘(lucide flame, `{colors.ember}` 틴트, 잉걸 글로우 상시 은은하게) + 스트릭 수 `{typography.numeral-hero}` `{colors.ink}` + 라벨 "일째 마무리" `{typography.caption}` `{colors.ink-muted}`. 우측 상단에 `{component.freeze-chip}`. 마무리 전에는 라벨이 "오늘 마무리가 남아 있어요"로, 마무리 후에는 "N일째 마무리"로.

**`freeze-chip`** — ❄ 보유 표시. 배경 `{colors.frost-soft}`, 눈꽃 아이콘(lucide snowflake) + 수량 `{typography.numeral-sm}` `{colors.frost}`, `{rounded.pill}`, 패딩 6×12. 탭하면 프리즈 규칙 설명 시트. 보유 0개면 아이콘만 `{colors.ink-faint}`로.

**`streak-danger-banner`** — 23:00 이후 미마감 상태의 홈 상단 배너. 배경 `{colors.ember-soft}`, 텍스트 `{colors.ink}` `{typography.caption}`: "🔥 23일이 사라지기 전에 오늘을 마무리해요" (en: "Don't lose your 23-day streak — close today 🔥") → 시스템에서 손실회피 카피가 허용된 유일한 자리 (PRD §14 예외).

### 마감 (Check-in)

**`checkin-cta`** — 앱의 심장. 배경 `{colors.ember}`, 텍스트 `{colors.on-ember}` `{typography.body-strong}`, `{rounded.lg}`, 높이 56, 화면 하단 고정(세이프에어리어 위 `{spacing.md}`). 라벨 "오늘 하루 마무리하기". 눌림: `{colors.ember-deep}` + scale 0.97.
- 마감 완료 후: `{component.checkin-done-chip}`으로 교체 — 배경 `{colors.surface}`, 텍스트 `{colors.ink-muted}`, "오늘 하루 마무리했어요 · 내일 봐요". 비인터랙티브.
- 습관 0개일 때: CTA 대신 "첫 습관 등록하기" (동일 스타일 — 이때만은 등록이 곧 핵심 행동이다).

**`closing-sheet`** — 마감 플로우 바텀시트. 배경 `{colors.surface-raised}`, 상단 `{rounded.xl}`. 타이틀 "오늘 하루 마무리할게요" `{typography.heading}`. 습관 행 리스트: 기본 상태 전원 "참았어요"(잉크 채운 체크), 무너진 습관만 탭해서 테두리 원으로 전환. 즉시 기록된 무너짐은 미리 전환된 채 잠김 표시. 하단 확정 버튼 `{component.checkin-cta}` 동일 스타일, 라벨 "이대로 마무리하기".

**`yesterday-card`** — 소급 확인 카드. 홈 리스트 최상단(조건부). 배경 `{colors.surface}`, `{rounded.lg}`, 패딩 `{spacing.lg}`. 타이틀 "어제는 어땠어요?" `{typography.heading}`. 버튼 3개 가로 배치: [참았어요] [못 참았어요] [기억나지 않아요] — 모두 `{component.button-secondary}` 동격. **어느 답도 강조하지 않는다** — 정직한 답에 시각적 편향을 주지 않는 것이 원칙.

### 습관

**`habit-row`** — 습관 리스트 행. 배경 `{colors.surface}`, `{rounded.lg}`, 패딩 16, 행 간격 `{spacing.sm}`. 좌측: 습관 아이콘 원(44×44, 습관 색 12% 배경 + 습관 색 아이콘). 중앙: 습관 이름 `{typography.body-strong}` + 아낀 돈 누계 `{typography.caption}` `{colors.ink-muted}`. 우측: `D+37` `{typography.numeral-sm}` `{colors.ink}`. 스와이프 좌: "무너짐 기록" 액션(배경 `{colors.surface-raised}`, 잉크 아이콘 — **빨강 아님**).

**`lapse-sheet`** — 즉시 무너짐 기록 시트. 타이틀 "무너진 순간을 기록할게요" `{typography.heading}`. 선택 메모 입력 필드(`{colors.surface-raised}` 위 한 단계 밝은 필드, `{rounded.md}`). 확정 버튼은 `{component.button-secondary}` — **잉걸이 아니다**(마감이 아니므로). 완료 토스트: "기록했어요. 지금까지 아낀 54,000원은 그대로예요" — 기록 직후 반드시 보존 자산을 함께 보여준다 (PRD 원칙 4).

**`preset-card`** — 습관 추가 프리셋 셀. 2열 그리드, 배경 `{colors.surface}`, `{rounded.md}`, 패딩 16. 아이콘 + 이름 `{typography.body-strong}` + 기본 단가 "3,000원/일" `{typography.numeral-sm}` `{colors.ink-muted}`. 선택 시 테두리 1.5px `{colors.ink}` (잉걸 아님 — 선택은 마감이 아니다). 그리드 끝에 "직접 만들기" 셀(점선 테두리 `{colors.hairline}`).

**`progress-card`** — 습관 상세 상단 절제 진도. 배경 `{colors.surface}`, `{rounded.lg}`, 패딩 `{spacing.lg}`. 상단: `D+37` `{typography.numeral-lg}` + "연속 절제" `{typography.caption}`. 하단 3-stat 가로 분할(헤어라인 구분): 최고 기록 · 총 절제일 · 아낀 돈, 각각 값 `{typography.numeral-md}` + 라벨 `{typography.caption}` `{colors.ink-muted}`. 시간 단가 습관은 아낀 돈 대신 행동 환산 문구("책 12권 읽을 시간") `{typography.caption}`으로.

### 기록

**`record-calendar`** — 월 단위 기록 캘린더. 배경 `{colors.canvas}` 위에 그대로(카드 없음). 요일 헤더 `{typography.label}` `{colors.ink-faint}`. 날짜 셀: 숫자 `{typography.numeral-cal}` + 아래 상태 도트. 도트 문법은 Colors §기록 표기 원칙 그대로:
- 절제 마감 = `{colors.ink}` 채운 원 · 무너짐 있는 마감 = `{colors.ink}` 테두리 원 · 프리즈 = `{colors.frost}` 원+눈꽃 · 미기록 = `{colors.ink-faint}` 점 · 오늘 = `{colors.ember}` 링
- 도트 탭 → 그날 기록 팝오버 (오늘·어제만 수정 버튼 노출, PRD §4.2).
- 주 시작 요일은 로케일 설정을 따른다 (PRD §6.4) — 월요일 시작(한국)과 일요일 시작(미국) 양쪽에서 7열 그리드가 성립해야 한다.

**`badge-medallion`** — 배지 셀. 3열 그리드. 원형 61×61: 획득 = `{colors.ember-soft}` 배경 + `{colors.ember}` 1.5px 스트로크 + 잉크 아이콘, 미획득 = `{colors.surface}` 배경 + `{colors.hairline}` 스트로크 + `{colors.ink-faint}` 아이콘. 아래 이름 `{typography.caption}`. 획득 시트: 배지 + "정직 배지를 얻었어요" `{typography.display}` — 글로우 없음(글로우는 불꽃 전용).

### 복귀 & 온보딩

**`return-screen`** — 🔥 리셋 후 첫 진입 전면 화면. 배경 `{colors.canvas}`. 헤드라인 "다시 왔네요" `{typography.display}`. 본문: "스트릭은 끊겼지만 절제 34일 · 128,000원은 그대로예요" — 보존 자산 수치는 `{typography.numeral-lg}`로 크게, 끊긴 스트릭 수치는 아예 표시하지 않는다. CTA "오늘부터 다시 마무리하기" `{component.checkin-cta}` 스타일. 재·숯 톤의 일러스트 영역(선택) — 죄책감 이미지 금지.

**`onboarding`** — 3장 전면. 배경 `{colors.canvas}`, 헤드라인 `{typography.display}`, 본문 `{typography.body}` `{colors.ink-muted}`. 2장의 핵심 반전 문장 "무너져도, 기록하면 스트릭은 유지돼요"만 `{colors.ember}`로 하이라이트 — 온보딩에서 잉걸이 쓰이는 유일한 자리. 3장은 프리셋 그리드 임베드. 건너뛰기는 상단 `{colors.ink-faint}` 텍스트 버튼, 습관 등록 단계에서 사라진다 (PRD §9).

### Buttons (보조 문법)

**`button-secondary`** — 배경 `{colors.surface-raised}`, 텍스트 `{colors.ink}` `{typography.body-strong}`, `{rounded.md}`, 높이 48. 하루 마무리 이외의 모든 확정 행동 (무너짐 기록, 소급 답변, 습관 저장). 시트(`{colors.surface-raised}`) 위에서는 배경을 `{colors.canvas}`로 반전해 색 단차를 만든다.

**`button-ghost`** — 배경 없음, 텍스트 `{colors.ink-muted}` `{typography.body-strong}`. 취소, 건너뛰기, "나중에".

**`button-danger`** — 배경 없음, 텍스트 `{colors.danger}`. 습관 삭제·데이터 초기화 확인 다이얼로그 안에서만. 확인 플로우는 2단계(PRD §11) + 보관 권장 안내를 먼저 보여준다.

### 입력

**`text-field`** — 배경 `{colors.surface-raised}`, 텍스트 `{colors.ink}` `{typography.body}`, 플레이스홀더 `{colors.ink-faint}`, `{rounded.md}`, 높이 48, 패딩 가로 16. 포커스: 테두리 1.5px `{colors.ink}` (잉걸 아님). 단가 입력 등 숫자 필드는 `{typography.numeral-md}` + 우측 단위 서픽스("원/일") `{typography.caption}` `{colors.ink-muted}`.

### 위젯

**`widget-small`** — 배경 `{colors.canvas}`(위젯은 앱과 동일한 밤). 불꽃 아이콘 + 스트릭 수 `{typography.numeral-lg}` + 마무리 여부 한 줄: 마무리 전 "오늘을 마무리해요" `{colors.ink-muted}` / 후 "마무리 완료" `{colors.ink-muted}`. 마무리 전 21시 이후엔 하단에 잉걸 점 하나로 긴급 신호.

**`widget-medium`** — 좌측: 소형과 동일 스택. 우측: 습관별 `D+N` 리스트(최대 3개, `{typography.numeral-sm}`) + 총 아낀 돈 `{typography.numeral-md}`. 데이터는 마지막 마감 스냅샷 (PRD §10).

### 알림 (카피 스타일)

| 알림 | 시각 | 한국어 | 영어 |
|---|---|---|---|
| 하루 마무리 알림 | 21:00 (변경 가능) | "오늘 하루를 마무리할 시간이에요" | "Time to close your day" |
| 스트릭 위험 | 23:00 | "🔥 23일이 사라지기 전에 오늘을 마무리해요" | "Don't lose your 23-day streak — close today 🔥" |

이모지는 알림에서만 허용. 이미 마감한 날은 어떤 알림도 없다 (PRD §8). 카피는 번역이 아니라 로케일별 집필 — 기준은 PRD §14.

## Do's and Don'ts

### Do
- `{colors.ember}`는 **마감 CTA·스트릭 불꽃·오늘 링·획득 배지 스트로크**에만. 새 요소에 잉걸을 쓰고 싶다면 "이것이 마감인가?"를 먼저 물어라.
- 수치가 주인공인 모든 자리는 IBM Plex Mono(`{typography.numeral-*}`)로. 큰 숫자 + 작은 caption 라벨 조합을 유지하라.
- 무너짐 기록 직후에는 반드시 보존 자산("아낀 54,000원은 그대로예요")을 함께 보여줘라 — 원칙 4의 UI 계약.
- 위계가 필요하면 표면 색 단차(`canvas → surface → surface-raised`)를 먼저 써라. 헤어라인은 최후 수단.
- 마감·삭제 같은 확정 행동의 버튼 라벨은 동사구로: "이대로 마무리하기", "기록 지우기" (토스 라이팅).
- 불꽃·눈꽃은 lucide 아이콘(flame/snowflake → SF Symbol 매핑)으로 그려라.
- 모든 눌림은 scale 0.97, Reduced Motion에서는 크로스페이드로.

### Don't
- 무너짐·실패에 빨간색 금지. `{colors.danger}`는 파괴적 행동 확인 전용이다.
- 두 번째 액센트 금지. `{colors.frost}`를 버튼·링크·강조에 쓰지 마라 — 프리즈 표기 전용이다.
- 잉걸 글로우를 카드·버튼·텍스트에 바르지 마라. 글로우는 불꽃 전용 보상 신호다.
- UI에 이모지(🔥❄) 금지 — 알림·토스트 카피에서만.
- 순수 검정(#000000)·순수 흰색(#FFFFFF) 금지. 팔레트는 숯과 종이다.
- 컨페티·파티클·사운드 금지. 축하는 잉걸 글로우 한 번으로 끝낸다.
- 죄책감 카피 금지("또 실패했네요" 류). 손실회피 카피는 `streak-danger-banner`와 23시 알림에서만.
- 그라데이션 배경, 드롭섀도 금지.
- 필(`{rounded.pill}`)을 카드·이미지·입력에 쓰지 마라 — 필은 액션·상태 문법이다.

## 기기 대응

### iPhone
| 폭 | 대응 |
|---|---|
| ≤ 375 (SE 계열) | `numeral-hero` 64→52, 화면 패딩 20→16, 소급 카드 버튼 3개는 세로 스택 |
| 390–430 (표준~Max) | 기준 레이아웃 |
| iPad | MVP 비목표 — 확대 레이아웃 없이 iPhone 레이아웃 호환 실행 |

- 하단 고정 CTA는 세이프에어리어 인셋 + `{spacing.md}` 유지. 홈 인디케이터와 겹치지 않는다.
- 터치 타깃 최소 44×44. 캘린더 날짜 셀도 44 유지(도트는 작아도 히트 영역은 셀 전체).
- 다크 단일 모드이므로 시스템 라이트/다크 설정과 무관하게 동일 렌더링. 상태바는 항상 라이트 콘텐츠.

### 위젯
- 소형/중형 모두 다크 고정. 배경 제거(iOS 17+ containerBackground removable) 시에도 잉크·잉걸 대비가 유지되는지 확인.
- 잠금화면 위젯은 로드맵.

### 로케일 (PRD §6)
- **텍스트 확장**: 영어 라벨은 한국어보다 30~50% 길 수 있다. 버튼·칩·행은 고정 폭 금지 — 콘텐츠 기반 크기. 소급 확인 카드의 3버튼처럼 가로로 나열되는 라벨은 넘칠 때 언어 무관 **세로 스택 폴백** (SE 대응과 동일 메커니즘).
- **금액**: 시스템 `FormatStyle`로 포맷된 문자열 전체에 `numeral-*` 토큰 적용. 통화 기호 위치(₩54,000 / 54 €)를 디자인이 가정하지 않는다.
- **캘린더**: 주 시작 요일은 로케일 설정을 따른다.
- **폴백**: 지원 언어는 한국어·영어, 그 외 로케일은 영어. RTL 대응은 비목표(지원 언어에 없음).

### 접근성
- 본문 잉크 대비: `{colors.ink}` on `{colors.canvas}` ≈ 15:1, `{colors.ink-muted}` ≈ 6:1 — WCAG AA 충족. `{colors.ink-faint}`는 장식·보조 전용(본문 금지).
- 캘린더 도트 문법은 색+형태 이중 부호화(채움/테두리/글리프)라 색각 이상에도 구분된다.
- VoiceOver: 스트릭 카운터 = "체크인 스트릭 24일", 캘린더 셀 = "7월 3일, 무너짐 있는 마감" 식으로 상태를 문장으로 읽는다.

## Iteration Guide

1. 토큰 반영 순서는 **본 문서 → `DESIGN.pen` (Foundation) → Swift 토큰** 단방향. 코드에서 값을 직접 바꾸지 않는다 (`.claude/rules/view-design-system.md`).
2. `DESIGN.pen` 매핑: `{colors.*}` → Foundation / Color Palette (Primary 스케일을 잉걸 계열로, Neutral을 웜 차콜·잉크 계열로 재정의), `{typography.*}` → Foundation / Typography, `{rounded.*}`·`{spacing.*}` → 기존 `Theme` 스케일.
3. Swift 매핑 기준: `{colors.ember}` → `AppColor.Brand.primary`, `canvas/surface/surface-raised` → `AppColor.Background.primary/secondary/elevated`, `ink 계열` → `AppColor.Text.*`, `{typography.numeral-*}` → `AppTypography`에 mono 패밀리 추가 (IBM Plex Mono 번들 필요).
4. 컴포넌트를 수정할 때는 YAML 키 하나씩(`{component.checkin-cta}`, `{component.record-calendar}`). 상태 변형은 `-pressed`, `-done`, `-locked` 서픽스로 분리 정의한다.
5. 새 화면을 디자인할 때의 자문 순서: ① 잉걸이 필요한가? (마감인가?) ② 새 색이 필요한가? (표면 단차로 안 되는가?) ③ 글로우가 필요한가? (아니다.)
6. 모든 카피는 PRD §14 라이팅 원칙으로 로케일별 검수 후 반영한다 (한국어: 토스 가이드 / 영어: 대응 원칙). 문자열은 String Catalog(`.xcstrings`) + `AppStrings` enum으로만 추가한다 (`.claude/rules/localization.md`).

## Known Gaps

- **라이트 모드 없음** — 다크 단일 모드는 의도된 v1 결정. 사용 데이터에서 주간 사용 비중이 높게 나오면 라이트 팔레트(종이 위 숯 반전)를 로드맵으로.
- 습관 아이콘 팔레트(습관별 색 12색 등)는 프리셋 라이브러리 구현 시점에 별도 정의 필요.
- 배지 아트웍(계열별 도상)은 본 문서 범위 밖 — 메달리온 컨테이너 스펙만 정의했다.
- 복귀 화면 일러스트, 엠프티 스테이트(습관 0개, 기록 없음) 아트 방향은 미정 — 톤만 규정(재·숯, 죄책감 금지).
- 온보딩 1장 컨셉 비주얼("참은 날이 쌓여요"의 시각화)은 프로토타입에서 탐색.
- IBM Plex Mono의 한글 없음은 문제 아님(수치 전용)이나, 지원 통화 기호(₩·$·€·¥ 등 약 20종, PRD §6.2) 렌더링 폭은 구현 시 확인 필요.
- 영어 카피 전문(온보딩·에러 포함)은 PRD §14 원칙으로 별도 집필 필요 — 본 문서의 카피 예시는 한국어 기준이며 영어는 대표 예시만 병기했다.
- 사운드·햅틱 상세(마감 의식 외)는 미정의.
