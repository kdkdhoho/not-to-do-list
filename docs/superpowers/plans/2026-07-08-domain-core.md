# 잉걸 도메인 코어 & 저장소 구현 계획 (Plan 1/4)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** PRD-v1 코어 루프 규칙(하루 경계 4시·체크인·스트릭·프리즈·소급·절제 진도·배지·프리셋)을 UI 없이 완전한 유닛테스트와 함께 구현한다.

**Architecture:** 순수 값 타입 도메인(Entities) + 순수 함수 엔진(StreakEngine·ProgressCalculator·BadgeEngine)을 `Shared/Domain`에 두고, SwiftData 영속화는 `Shared/Data`의 `@ModelActor` Repository에 가둔다. 엔진은 스냅샷 값만 받아 결정(Decision)을 반환하고, Service가 Repo IO ↔ 엔진을 오케스트레이션한다. UseCase 레이어는 두지 않는다 (CLAUDE.md).

**Tech Stack:** Swift 6 (strict concurrency), SwiftData, Swift Testing(`import Testing`), Tuist 4

## Global Constraints

- 최소 타겟 iOS 26.0, `SWIFT_VERSION: 6.0`, 모든 공개 타입 `Sendable` 준수 (CLAUDE.md)
- 하루 경계는 **오전 4시**, 기기 로컬 시간 기준 (PRD §4.2, §6.4)
- 마감(하루 마무리)은 달력 날짜당 1회, 소급은 **어제 분만**, 미래 기록 금지 (PRD §4.2)
- 프리즈: 연속 체크인 7일마다 1개 적립, 최대 2개 보유, 리셋 시 적립 카운터만 리셋 (PRD §4.3)
- 절제 진도는 관대 모델: 미기록일도 무너짐이 아니면 절제일 포함 (PRD §5.2)
- 환율 연동·재환산 없음. 통화 변경 시 수치 유지 (PRD §6.2)
- 도메인 레이어에 사용자 노출 문자열 금지 — 문자열은 UI 레이어에서 `AppStrings`로만 (localization 규칙)
- Repository 프로토콜은 `Sources/Shared/Domain/Interfaces/`, 구현체는 `Sources/Shared/Data/` (CLAUDE.md)
- 명령어: `tuist generate --no-open` / 테스트: `tuist test Shared`

---

### Task 1: 테스트 타겟 셋업 + DayStamp(하루 경계)

**Files:**
- Modify: `Project.swift` (targets 배열 끝에 SharedTests 타겟 추가)
- Create: `Sources/Shared/Domain/Entities/DayStamp.swift`
- Test: `Tests/SharedTests/DayStampTests.swift`

**Interfaces:**
- Produces: `DayStamp(year:month:day:)`, `DayStamp.advanced(by:calendar:) -> DayStamp`, `DayStamp.distance(to:calendar:) -> Int`, `DayBoundary.dayStamp(for:calendar:) -> DayStamp`, `DayBoundary.boundaryHour == 4`

- [ ] **Step 1: Project.swift에 테스트 타겟 추가**

`Project.swift`의 `targets:` 배열 마지막(ServiceApp 타겟 뒤)에 추가:

```swift
        // MARK: - Tests
        .target(
            name: "SharedTests",
            destinations: destinations,
            product: .unitTests,
            bundleId: "\(bundleId).sharedTests",
            deploymentTargets: .iOS(deploymentTarget),
            infoPlist: .default,
            buildableFolders: ["Tests/SharedTests"],
            dependencies: [
                .target(name: "Shared"),
            ]
        ),
```

- [ ] **Step 2: 실패하는 테스트 작성**

`Tests/SharedTests/DayStampTests.swift`:

```swift
import Foundation
import Testing
@testable import Shared

struct DayStampTests {
    let cal = Calendar(identifier: .gregorian)

    func date(_ y: Int, _ mo: Int, _ d: Int, _ h: Int, _ mi: Int = 0) -> Date {
        cal.date(from: DateComponents(year: y, month: mo, day: d, hour: h, minute: mi))!
    }

    @Test func 새벽1시는_전날로_귀속된다() {
        let stamp = DayBoundary.dayStamp(for: date(2026, 7, 8, 1, 30), calendar: cal)
        #expect(stamp == DayStamp(year: 2026, month: 7, day: 7))
    }

    @Test func 새벽4시부터_당일이다() {
        #expect(DayBoundary.dayStamp(for: date(2026, 7, 8, 4, 0), calendar: cal)
                == DayStamp(year: 2026, month: 7, day: 8))
        #expect(DayBoundary.dayStamp(for: date(2026, 7, 8, 3, 59), calendar: cal)
                == DayStamp(year: 2026, month: 7, day: 7))
    }

    @Test func 자정직전은_당일이다() {
        #expect(DayBoundary.dayStamp(for: date(2026, 7, 8, 23, 59), calendar: cal)
                == DayStamp(year: 2026, month: 7, day: 8))
    }

    @Test func advanced와_distance는_역연산이다() {
        let d = DayStamp(year: 2026, month: 7, day: 8)
        let next = d.advanced(by: 1, calendar: cal)
        #expect(next == DayStamp(year: 2026, month: 7, day: 9))
        #expect(d.distance(to: next, calendar: cal) == 1)
        #expect(d.advanced(by: -8, calendar: cal) == DayStamp(year: 2026, month: 6, day: 30))
    }

    @Test func 비교연산() {
        #expect(DayStamp(year: 2026, month: 7, day: 7) < DayStamp(year: 2026, month: 7, day: 8))
        #expect(DayStamp(year: 2025, month: 12, day: 31) < DayStamp(year: 2026, month: 1, day: 1))
    }
}
```

- [ ] **Step 3: 실패 확인**

Run: `tuist generate --no-open && tuist test Shared`
Expected: 컴파일 실패 — `cannot find 'DayBoundary' in scope`

- [ ] **Step 4: 구현**

`Sources/Shared/Domain/Entities/DayStamp.swift`:

```swift
import Foundation

/// 하루 경계(오전 4시)가 적용된 "앱의 하루". 모든 기록·규칙은 DayStamp 단위로 동작한다.
public struct DayStamp: Hashable, Comparable, Codable, Sendable {
    public let year: Int
    public let month: Int
    public let day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    public static func < (lhs: DayStamp, rhs: DayStamp) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }

    /// 정오 앵커로 변환해 DST에 안전하게 날짜 연산한다.
    private func noonDate(_ calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    public func advanced(by days: Int, calendar: Calendar = .current) -> DayStamp {
        let moved = calendar.date(byAdding: .day, value: days, to: noonDate(calendar))!
        let c = calendar.dateComponents([.year, .month, .day], from: moved)
        return DayStamp(year: c.year!, month: c.month!, day: c.day!)
    }

    public func distance(to other: DayStamp, calendar: Calendar = .current) -> Int {
        calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: noonDate(calendar)),
            to: calendar.startOfDay(for: other.noonDate(calendar))
        ).day!
    }
}

public enum DayBoundary {
    /// 하루 경계: 오전 4시 (PRD §4.2 — 밤 습관 타깃, 자정 직후 마무리를 전날로 귀속)
    public static let boundaryHour = 4

    public static func dayStamp(for date: Date, calendar: Calendar = .current) -> DayStamp {
        let shifted = calendar.date(byAdding: .hour, value: -boundaryHour, to: date)!
        let c = calendar.dateComponents([.year, .month, .day], from: shifted)
        return DayStamp(year: c.year!, month: c.month!, day: c.day!)
    }
}
```

- [ ] **Step 5: 통과 확인**

Run: `tuist test Shared`
Expected: PASS (5 tests)

- [ ] **Step 6: Commit**

```bash
git add Project.swift Sources/Shared/Domain/Entities/DayStamp.swift Tests/SharedTests/DayStampTests.swift
git commit -m "feat: DayStamp — 하루 경계 오전 4시 규칙"
```

---

### Task 2: 도메인 엔티티 (Habit·DayClose·HabitDayMark·StreakState)

**Files:**
- Create: `Sources/Shared/Domain/Entities/Habit.swift`
- Create: `Sources/Shared/Domain/Entities/TrackingRecords.swift`
- Test: `Tests/SharedTests/HabitTests.swift`

**Interfaces:**
- Consumes: `DayStamp` (Task 1)
- Produces:
  - `Habit(id:name:icon:colorHex:rate:createdDay:firstTrackedDay:archivedDay:)`, `Habit.Rate` (`.money(Decimal)/.time(minutes: Int)/.none`), `Habit.isActive(on:) -> Bool`
  - `DayClose(day:kind:closedAt:)`, `DayClose.Kind` (`.sameDay/.backfill/.freeze`)
  - `HabitDayMark(habitID:day:kind:memo:)`, `HabitDayMark.Kind` (`.lapsed(source:)/.unknown`), `LapseSource` (`.immediate/.atClose`)
  - `StreakState(current:best:freezes:freezeAccrual:)`

- [ ] **Step 1: 실패하는 테스트 작성**

`Tests/SharedTests/HabitTests.swift`:

```swift
import Foundation
import Testing
@testable import Shared

struct HabitTests {
    func habit(created: DayStamp, firstTracked: DayStamp? = nil, archived: DayStamp? = nil) -> Habit {
        Habit(id: UUID(), name: "담배", icon: "cigarette", colorHex: "D4B15F",
              rate: .money(3000), createdDay: created,
              firstTrackedDay: firstTracked ?? created, archivedDay: archived)
    }

    @Test func 추가_당일부터_활성이다() {
        let d = DayStamp(year: 2026, month: 7, day: 8)
        #expect(habit(created: d).isActive(on: d))
        #expect(!habit(created: d).isActive(on: d.advanced(by: -1)))
    }

    @Test func 마감후_추가는_다음날부터_활성이다() {
        let d = DayStamp(year: 2026, month: 7, day: 8)
        let h = habit(created: d, firstTracked: d.advanced(by: 1))
        #expect(!h.isActive(on: d))
        #expect(h.isActive(on: d.advanced(by: 1)))
    }

    @Test func 보관된_날부터_비활성이다() {
        let d = DayStamp(year: 2026, month: 7, day: 1)
        let h = habit(created: d, archived: DayStamp(year: 2026, month: 7, day: 5))
        #expect(h.isActive(on: DayStamp(year: 2026, month: 7, day: 4)))
        #expect(!h.isActive(on: DayStamp(year: 2026, month: 7, day: 5)))
    }
}
```

- [ ] **Step 2: 실패 확인**

Run: `tuist test Shared`
Expected: 컴파일 실패 — `cannot find 'Habit' in scope`

- [ ] **Step 3: 구현**

`Sources/Shared/Domain/Entities/Habit.swift`:

```swift
import Foundation

public struct Habit: Identifiable, Hashable, Sendable {
    /// 환산 단가 (PRD §5.1) — 앱 통화/일 또는 분/일, 미입력 시 절제일만 추적
    public enum Rate: Hashable, Codable, Sendable {
        case money(Decimal)
        case time(minutes: Int)
        case none
    }

    public let id: UUID
    public var name: String
    /// AppIcon rawValue (SF Symbol 이름)
    public var icon: String
    public var colorHex: String
    public var rate: Rate
    public let createdDay: DayStamp
    /// 마감 후 추가된 습관은 다음 날부터 마감 대상 (PRD §11)
    public let firstTrackedDay: DayStamp
    public var archivedDay: DayStamp?

    public init(id: UUID, name: String, icon: String, colorHex: String, rate: Rate,
                createdDay: DayStamp, firstTrackedDay: DayStamp, archivedDay: DayStamp? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.rate = rate
        self.createdDay = createdDay
        self.firstTrackedDay = firstTrackedDay
        self.archivedDay = archivedDay
    }

    public func isActive(on day: DayStamp) -> Bool {
        guard day >= firstTrackedDay else { return false }
        if let archivedDay { return day < archivedDay }
        return true
    }
}
```

`Sources/Shared/Domain/Entities/TrackingRecords.swift`:

```swift
import Foundation

/// 하루 마무리(체크인) 기록 — 달력 날짜당 1개 (PRD §4.2)
public struct DayClose: Hashable, Codable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case sameDay    // 당일 마무리
        case backfill   // 어제 소급
        case freeze     // ❄ 프리즈 자동 소모
    }
    public let day: DayStamp
    public let kind: Kind
    public let closedAt: Date

    public init(day: DayStamp, kind: Kind, closedAt: Date) {
        self.day = day
        self.kind = kind
        self.closedAt = closedAt
    }
}

public enum LapseSource: String, Codable, Sendable {
    case immediate  // 낮의 즉시 기록
    case atClose    // 마무리 시 체크
}

/// 습관·날짜 단위 기록. 마크 없음 + 그날 마무리됨 = 참았다 (이진 모델, PRD §4.2)
public struct HabitDayMark: Hashable, Codable, Sendable {
    public enum Kind: Hashable, Codable, Sendable {
        case lapsed(source: LapseSource)
        case unknown   // 소급 "기억나지 않아요" → 미기록 처리 (PRD §11)
    }
    public let habitID: UUID
    public let day: DayStamp
    public let kind: Kind
    public var memo: String?

    public init(habitID: UUID, day: DayStamp, kind: Kind, memo: String? = nil) {
        self.habitID = habitID
        self.day = day
        self.kind = kind
        self.memo = memo
    }
}

/// 스트릭 상태 스냅샷 (영속 대상)
public struct StreakState: Hashable, Codable, Sendable {
    public var current: Int
    public var best: Int
    public var freezes: Int
    public var freezeAccrual: Int

    public init(current: Int = 0, best: Int = 0, freezes: Int = 0, freezeAccrual: Int = 0) {
        self.current = current
        self.best = best
        self.freezes = freezes
        self.freezeAccrual = freezeAccrual
    }
}
```

- [ ] **Step 4: 통과 확인**

Run: `tuist test Shared`
Expected: PASS (8 tests)

- [ ] **Step 5: Commit**

```bash
git add Sources/Shared/Domain/Entities/Habit.swift Sources/Shared/Domain/Entities/TrackingRecords.swift Tests/SharedTests/HabitTests.swift
git commit -m "feat: 도메인 엔티티 — Habit·DayClose·HabitDayMark·StreakState"
```

---

### Task 3: StreakEngine (스트릭·프리즈·리셋 규칙)

**Files:**
- Create: `Sources/Shared/Domain/Engines/StreakEngine.swift`
- Test: `Tests/SharedTests/StreakEngineTests.swift`

**Interfaces:**
- Consumes: `DayStamp`, `DayClose.Kind`, `StreakState` (Task 1·2)
- Produces:
  - `StreakInput(today:closedDays:pausedDays:state:)` — `closedDays: [DayStamp: DayClose.Kind]`, `pausedDays: Set<DayStamp>`(활성 습관 0개였던 날)
  - `StreakDecision(freezeFills:didReset:state:yesterdayOpenForBackfill:)` — `freezeFills: [DayStamp]`
  - `StreakEngine.evaluate(_ input: StreakInput, calendar: Calendar) -> StreakDecision`
  - `StreakEngine.accrueAfterClose(_ state: StreakState) -> StreakState` — 7일마다 +1, 최대 2개

- [ ] **Step 1: 실패하는 테스트 작성**

`Tests/SharedTests/StreakEngineTests.swift`:

```swift
import Foundation
import Testing
@testable import Shared

struct StreakEngineTests {
    let cal = Calendar(identifier: .gregorian)
    let today = DayStamp(year: 2026, month: 7, day: 8)

    /// n일 전부터 어제까지 연속 sameDay 마무리
    func closes(daysBack: Int, until offset: Int = -1) -> [DayStamp: DayClose.Kind] {
        var map: [DayStamp: DayClose.Kind] = [:]
        for i in stride(from: -daysBack, through: offset, by: 1) {
            map[today.advanced(by: i, calendar: cal)] = .sameDay
        }
        return map
    }

    @Test func 연속마무리는_스트릭이_이어진다() {
        let input = StreakInput(today: today, closedDays: closes(daysBack: 23),
                                pausedDays: [], state: StreakState(current: 23, best: 23))
        let d = StreakEngine.evaluate(input, calendar: cal)
        #expect(!d.didReset)
        #expect(d.freezeFills.isEmpty)
        #expect(d.state.current == 23)
        #expect(d.yesterdayOpenForBackfill == false)  // 어제 마무리됨
    }

    @Test func 어제_공백은_프리즈를_쓰지_않고_소급대상으로_남긴다() {
        var map = closes(daysBack: 10, until: -2)   // 그제까지 마무리, 어제 공백
        map[today] = nil
        let input = StreakInput(today: today, closedDays: map,
                                pausedDays: [], state: StreakState(current: 9, best: 9, freezes: 2))
        let d = StreakEngine.evaluate(input, calendar: cal)
        #expect(d.freezeFills.isEmpty)
        #expect(d.yesterdayOpenForBackfill == true)
        #expect(!d.didReset)
    }

    @Test func 그제_공백은_프리즈로_자동_메운다() {
        var map = closes(daysBack: 10, until: -3)   // 3일 전까지 마무리
        map[today.advanced(by: -1, calendar: cal)] = .sameDay  // 어제는 마무리됨
        let input = StreakInput(today: today, closedDays: map,
                                pausedDays: [], state: StreakState(current: 8, best: 8, freezes: 2))
        let d = StreakEngine.evaluate(input, calendar: cal)
        #expect(d.freezeFills == [today.advanced(by: -2, calendar: cal)])
        #expect(d.state.freezes == 1)
        #expect(!d.didReset)
    }

    @Test func 프리즈가_모자라면_리셋된다_최고기록은_보존() {
        let map = closes(daysBack: 10, until: -5)   // 어제 제외 3일 공백(그제·3일전·4일전)
        let input = StreakInput(today: today, closedDays: map,
                                pausedDays: [], state: StreakState(current: 6, best: 15, freezes: 2))
        let d = StreakEngine.evaluate(input, calendar: cal)
        #expect(d.didReset)
        #expect(d.state.current == 0)
        #expect(d.state.best == 15)          // 최고 기록 영구 보존 (PRD §4.3)
        #expect(d.state.freezes == 2)        // 리셋 시 보유 프리즈는 유지
        #expect(d.state.freezeAccrual == 0)  // 적립 카운터만 리셋
    }

    @Test func 습관0개인_날은_스트릭을_끊지_않고_일시정지한다() {
        var map = closes(daysBack: 10, until: -4)
        map[today.advanced(by: -1, calendar: cal)] = .sameDay
        let paused: Set<DayStamp> = [today.advanced(by: -2, calendar: cal),
                                     today.advanced(by: -3, calendar: cal)]
        let input = StreakInput(today: today, closedDays: map,
                                pausedDays: paused, state: StreakState(current: 7, best: 7, freezes: 0))
        let d = StreakEngine.evaluate(input, calendar: cal)
        #expect(!d.didReset)
        #expect(d.freezeFills.isEmpty)       // 일시정지일은 공백이 아니다 (PRD §11)
    }

    @Test func 적립은_7일마다_1개_최대2개() {
        var s = StreakState(current: 6, best: 6, freezes: 0, freezeAccrual: 6)
        s = StreakEngine.accrueAfterClose(s)   // 7일째 마무리
        #expect(s.freezes == 1 && s.freezeAccrual == 0)

        var full = StreakState(current: 20, best: 20, freezes: 2, freezeAccrual: 6)
        full = StreakEngine.accrueAfterClose(full)
        #expect(full.freezes == 2 && full.freezeAccrual == 0)  // 최대 보유 초과분은 버린다
    }
}
```

- [ ] **Step 2: 실패 확인**

Run: `tuist test Shared`
Expected: 컴파일 실패 — `cannot find 'StreakEngine' in scope`

- [ ] **Step 3: 구현**

`Sources/Shared/Domain/Engines/StreakEngine.swift`:

```swift
import Foundation

public struct StreakInput: Sendable {
    public var today: DayStamp
    public var closedDays: [DayStamp: DayClose.Kind]
    /// 활성 습관이 0개였던 날 — 마무리 불가, 스트릭 일시정지 (PRD §11)
    public var pausedDays: Set<DayStamp>
    public var state: StreakState

    public init(today: DayStamp, closedDays: [DayStamp: DayClose.Kind],
                pausedDays: Set<DayStamp>, state: StreakState) {
        self.today = today
        self.closedDays = closedDays
        self.pausedDays = pausedDays
        self.state = state
    }
}

public struct StreakDecision: Equatable, Sendable {
    /// 프리즈로 자동 마무리 처리할 날 (DayClose(kind: .freeze) 저장 대상)
    public var freezeFills: [DayStamp]
    public var didReset: Bool
    public var state: StreakState
    /// 어제가 미마무리 상태로 남아 있어 소급 확인 카드를 띄워야 하는가
    public var yesterdayOpenForBackfill: Bool
}

public enum StreakEngine {
    public static let freezeAccrualPeriod = 7
    public static let maxFreezes = 2

    /// 앱 진입·마무리 직후 호출. 공백을 판정해 프리즈 소모/리셋을 결정하고 현재 스트릭을 재계산한다.
    /// - 어제 공백은 소급 기회가 남아 있으므로 프리즈를 소모하지 않는다 (PRD §4.2 소급 규칙 우선).
    /// - 그제 이전의 공백일(일시정지일 제외)에 오래된 날부터 프리즈를 1개씩 소모한다.
    public static func evaluate(_ input: StreakInput, calendar: Calendar = .current) -> StreakDecision {
        var state = input.state
        let yesterday = input.today.advanced(by: -1, calendar: calendar)
        let yesterdayOpen = input.closedDays[yesterday] == nil && !input.pausedDays.contains(yesterday)

        // 1. 그제 이전의 공백 수집: 마지막 마무리일부터 그제까지
        var gaps: [DayStamp] = []
        var cursor = input.today.advanced(by: -2, calendar: calendar)
        while input.closedDays[cursor] == nil {
            if !input.pausedDays.contains(cursor) { gaps.append(cursor) }
            cursor = cursor.advanced(by: -1, calendar: calendar)
            // 마무리 기록이 하나도 없는 신규 사용자: 스트릭 0이면 공백 개념이 없다
            if state.current == 0 && gaps.count > Self.maxFreezes { break }
            if gaps.count > Self.maxFreezes { break }  // 이미 리셋 확정
        }
        gaps.sort()

        // 2. 프리즈 소모 또는 리셋
        var fills: [DayStamp] = []
        var didReset = false
        if state.current > 0 {
            if gaps.count <= state.freezes {
                fills = gaps
                state.freezes -= gaps.count
            } else {
                didReset = true
                state.current = 0
                state.freezeAccrual = 0   // 보유 프리즈는 유지, 카운터만 리셋 (PRD §4.3)
            }
        }

        // 3. 스트릭 재계산: 오늘 또는 어제(소급 대기 포함)에 닿는 연속 마무리 사슬
        if !didReset {
            var closed = input.closedDays
            for f in fills { closed[f] = .freeze }
            var count = 0
            var day = closed[input.today] != nil ? input.today : yesterday
            if closed[day] == nil && !input.pausedDays.contains(day) {
                day = day.advanced(by: -1, calendar: calendar)  // 어제 소급 대기 중이면 그제부터 센다
            }
            while true {
                if closed[day] != nil {
                    count += 1
                } else if !input.pausedDays.contains(day) {
                    break  // 일시정지일은 세지 않고 건너뛴다
                }
                day = day.advanced(by: -1, calendar: calendar)
            }
            state.current = count
            state.best = max(state.best, count)
        }

        return StreakDecision(freezeFills: fills, didReset: didReset,
                              state: state, yesterdayOpenForBackfill: yesterdayOpen)
    }

    /// 사용자 마무리(당일·소급) 직후 적립 카운터를 진행시킨다. 프리즈 자동 메움은 적립되지 않는다.
    public static func accrueAfterClose(_ state: StreakState) -> StreakState {
        var s = state
        s.freezeAccrual += 1
        if s.freezeAccrual >= Self.freezeAccrualPeriod {
            s.freezeAccrual = 0
            if s.freezes < Self.maxFreezes { s.freezes += 1 }
        }
        return s
    }
}
```

- [ ] **Step 4: 통과 확인**

Run: `tuist test Shared`
Expected: PASS (14 tests)

- [ ] **Step 5: Commit**

```bash
git add Sources/Shared/Domain/Engines/StreakEngine.swift Tests/SharedTests/StreakEngineTests.swift
git commit -m "feat: StreakEngine — 스트릭·프리즈·리셋·일시정지 규칙"
```

---

### Task 4: ProgressCalculator (절제 진도 — 관대 모델)

**Files:**
- Create: `Sources/Shared/Domain/Engines/ProgressCalculator.swift`
- Test: `Tests/SharedTests/ProgressCalculatorTests.swift`

**Interfaces:**
- Consumes: `Habit`, `HabitDayMark`, `DayStamp`
- Produces:
  - `HabitProgress(currentRun:bestRun:totalCleanDays:saved:)`, `SavedAmount` (`.money(Decimal)/.time(minutes: Int)/.none`)
  - `ProgressCalculator.progress(for:marks:today:calendar:) -> HabitProgress`
  - `ReadingConversion.pages(fromMinutes:) -> Int`, `ReadingConversion.books(fromMinutes:) -> Int` (1페이지=2분, 300페이지=1권)

- [ ] **Step 1: 실패하는 테스트 작성**

`Tests/SharedTests/ProgressCalculatorTests.swift`:

```swift
import Foundation
import Testing
@testable import Shared

struct ProgressCalculatorTests {
    let cal = Calendar(identifier: .gregorian)
    let today = DayStamp(year: 2026, month: 7, day: 8)

    func habit(rate: Habit.Rate = .money(3000), createdDaysAgo: Int) -> Habit {
        let created = today.advanced(by: -createdDaysAgo, calendar: cal)
        return Habit(id: UUID(), name: "담배", icon: "cigarette", colorHex: "D4B15F",
                     rate: rate, createdDay: created, firstTrackedDay: created)
    }

    func lapse(_ h: Habit, daysAgo: Int) -> HabitDayMark {
        HabitDayMark(habitID: h.id, day: today.advanced(by: -daysAgo, calendar: cal),
                     kind: .lapsed(source: .immediate))
    }

    @Test func 무너짐없으면_전체가_절제일이다() {
        let h = habit(createdDaysAgo: 9)   // 10일째 추적 (등록일 포함)
        let p = ProgressCalculator.progress(for: h, marks: [], today: today, calendar: cal)
        #expect(p.totalCleanDays == 10)
        #expect(p.currentRun == 10)
        #expect(p.bestRun == 10)
        #expect(p.saved == .money(30000))
    }

    @Test func 미기록일은_절제일에_포함된다_관대모델() {
        let h = habit(createdDaysAgo: 9)
        let unknown = HabitDayMark(habitID: h.id, day: today.advanced(by: -3, calendar: cal), kind: .unknown)
        let p = ProgressCalculator.progress(for: h, marks: [unknown], today: today, calendar: cal)
        #expect(p.totalCleanDays == 10)   // unknown은 무너짐이 아니다 (PRD §5.2)
        #expect(p.currentRun == 10)       // 미기록일은 연속을 끊지 않는다
    }

    @Test func 무너진날은_빠지고_연속이_끊긴다() {
        let h = habit(createdDaysAgo: 9)
        let p = ProgressCalculator.progress(for: h, marks: [lapse(h, daysAgo: 3)],
                                            today: today, calendar: cal)
        #expect(p.totalCleanDays == 9)
        #expect(p.currentRun == 3)   // 무너짐 다음 날 ~ 오늘 (PRD §5.2)
        #expect(p.bestRun == 6)      // 등록일 ~ 무너짐 전날
    }

    @Test func 시간단가는_분으로_적립된다() {
        let h = habit(rate: .time(minutes: 60), createdDaysAgo: 9)
        let p = ProgressCalculator.progress(for: h, marks: [], today: today, calendar: cal)
        #expect(p.saved == .time(minutes: 600))
    }

    @Test func 독서환산_2분1페이지_300페이지1권() {
        #expect(ReadingConversion.pages(fromMinutes: 60) == 30)
        #expect(ReadingConversion.books(fromMinutes: 600) == 1)
        #expect(ReadingConversion.books(fromMinutes: 599) == 0)
    }
}
```

- [ ] **Step 2: 실패 확인**

Run: `tuist test Shared`
Expected: 컴파일 실패 — `cannot find 'ProgressCalculator' in scope`

- [ ] **Step 3: 구현**

`Sources/Shared/Domain/Engines/ProgressCalculator.swift`:

```swift
import Foundation

public enum SavedAmount: Hashable, Sendable {
    case money(Decimal)
    case time(minutes: Int)
    case none
}

/// 절제 진도 — 사라지지 않는 자산 (PRD §5.2)
public struct HabitProgress: Hashable, Sendable {
    public var currentRun: Int      // 현재 연속 절제일 (D+N)
    public var bestRun: Int         // 최고 연속 기록
    public var totalCleanDays: Int  // 총 절제일
    public var saved: SavedAmount   // 아낀 돈(시간)
}

public enum ProgressCalculator {
    /// 관대 모델: 미기록(unknown 포함)일도 무너짐으로 기록되지 않은 한 절제일에 포함한다.
    public static func progress(for habit: Habit, marks: [HabitDayMark],
                                today: DayStamp, calendar: Calendar = .current) -> HabitProgress {
        let end = habit.archivedDay.map { $0.advanced(by: -1, calendar: calendar) } ?? today
        let trackedDays = habit.firstTrackedDay.distance(to: end, calendar: calendar) + 1
        guard trackedDays > 0 else {
            return HabitProgress(currentRun: 0, bestRun: 0, totalCleanDays: 0, saved: .none)
        }

        let lapsedDays = Set(marks.compactMap { mark -> DayStamp? in
            guard mark.habitID == habit.id, case .lapsed = mark.kind else { return nil }
            return mark.day
        }).filter { $0 >= habit.firstTrackedDay && $0 <= end }

        let totalClean = trackedDays - lapsedDays.count

        // 연속 구간: 무너진 날만 경계로 삼는다 (미기록은 끊지 않음)
        var currentRun = 0
        var bestRun = 0
        var run = 0
        var day = habit.firstTrackedDay
        while day <= end {
            if lapsedDays.contains(day) {
                bestRun = max(bestRun, run)
                run = 0
            } else {
                run += 1
            }
            day = day.advanced(by: 1, calendar: calendar)
        }
        bestRun = max(bestRun, run)
        currentRun = run

        let saved: SavedAmount
        switch habit.rate {
        case .money(let perDay): saved = .money(perDay * Decimal(totalClean))
        case .time(let minutes): saved = .time(minutes: minutes * totalClean)
        case .none: saved = .none
        }

        return HabitProgress(currentRun: currentRun, bestRun: bestRun,
                             totalCleanDays: totalClean, saved: saved)
    }
}

/// 행동 환산 — MVP는 독서 1종, 전 지역 공통 (PRD §5.3)
public enum ReadingConversion {
    public static let minutesPerPage = 2
    public static let pagesPerBook = 300

    public static func pages(fromMinutes minutes: Int) -> Int { minutes / minutesPerPage }
    public static func books(fromMinutes minutes: Int) -> Int {
        minutes / (minutesPerPage * pagesPerBook)
    }
}
```

- [ ] **Step 4: 통과 확인**

Run: `tuist test Shared`
Expected: PASS (19 tests)

- [ ] **Step 5: Commit**

```bash
git add Sources/Shared/Domain/Engines/ProgressCalculator.swift Tests/SharedTests/ProgressCalculatorTests.swift
git commit -m "feat: ProgressCalculator — 관대 모델 절제 진도 + 독서 환산"
```

---

### Task 5: BadgeEngine (배지 판정)

**Files:**
- Create: `Sources/Shared/Domain/Engines/BadgeEngine.swift`
- Test: `Tests/SharedTests/BadgeEngineTests.swift`

**Interfaces:**
- Consumes: `StreakState`, `HabitProgress`, `HabitDayMark`, `AppCurrency`(Task 7 — 이 태스크에선 통화 코드 문자열 `"KRW"`/`"USD"`만 사용)
- Produces:
  - `BadgeKind` (`.checkinStreak(days:)/.habitRun(days:)/.moneySaved(milestone: Int)/.honesty`) — `Codable·Hashable`
  - `BadgeAward(kind:earnedAt:)`
  - `BadgeEngine.judge(_ input: BadgeJudgeInput) -> [BadgeKind]` — 이미 획득한 배지는 제외하고 신규만 반환

- [ ] **Step 1: 실패하는 테스트 작성**

`Tests/SharedTests/BadgeEngineTests.swift`:

```swift
import Foundation
import Testing
@testable import Shared

struct BadgeEngineTests {
    func input(streak: Int = 0, bestHabitRun: Int = 0, savedMoney: Decimal = 0,
               currency: String = "KRW", lapsedYesterday: Bool = false,
               earned: Set<BadgeKind> = []) -> BadgeJudgeInput {
        BadgeJudgeInput(streakDays: streak, maxHabitRun: bestHabitRun,
                        totalSavedMoney: savedMoney, currencyCode: currency,
                        closedTodayAfterYesterdayLapse: lapsedYesterday, alreadyEarned: earned)
    }

    @Test func 스트릭_마일스톤은_도달분을_일괄_판정한다() {
        let new = BadgeEngine.judge(input(streak: 7))
        #expect(new.contains(.checkinStreak(days: 3)))
        #expect(new.contains(.checkinStreak(days: 7)))
        #expect(!new.contains(.checkinStreak(days: 14)))
    }

    @Test func 이미_획득한_배지는_다시_주지_않는다() {
        let new = BadgeEngine.judge(input(streak: 7, earned: [.checkinStreak(days: 3)]))
        #expect(!new.contains(.checkinStreak(days: 3)))
        #expect(new.contains(.checkinStreak(days: 7)))
    }

    @Test func 아낀돈은_통화별_임계값을_쓴다() {
        #expect(BadgeEngine.judge(input(savedMoney: 10000, currency: "KRW"))
            .contains(.moneySaved(milestone: 10000)))
        #expect(BadgeEngine.judge(input(savedMoney: 10, currency: "USD"))
            .contains(.moneySaved(milestone: 10)))
        #expect(!BadgeEngine.judge(input(savedMoney: 9999, currency: "KRW"))
            .contains(.moneySaved(milestone: 10000)))
    }

    @Test func 미지원통화는_USD_임계값을_쓴다() {
        #expect(BadgeEngine.judge(input(savedMoney: 50, currency: "EUR"))
            .contains(.moneySaved(milestone: 50)))
    }

    @Test func 정직배지_무너진_다음날에도_마무리하면_획득() {
        #expect(BadgeEngine.judge(input(lapsedYesterday: true)).contains(.honesty))
        #expect(!BadgeEngine.judge(input(lapsedYesterday: false)).contains(.honesty))
    }
}
```

- [ ] **Step 2: 실패 확인**

Run: `tuist test Shared`
Expected: 컴파일 실패 — `cannot find 'BadgeEngine' in scope`

- [ ] **Step 3: 구현**

`Sources/Shared/Domain/Engines/BadgeEngine.swift`:

```swift
import Foundation

public enum BadgeKind: Hashable, Codable, Sendable {
    case checkinStreak(days: Int)
    case habitRun(days: Int)          // 어느 습관이든 연속 절제 도달 시 1회
    case moneySaved(milestone: Int)   // 앱 통화 기준 합산 (PRD §7)
    case honesty                      // 무너짐 기록 다음 날에도 마무리 지속
}

public struct BadgeAward: Hashable, Codable, Sendable {
    public let kind: BadgeKind
    public let earnedAt: Date

    public init(kind: BadgeKind, earnedAt: Date) {
        self.kind = kind
        self.earnedAt = earnedAt
    }
}

public struct BadgeJudgeInput: Sendable {
    public var streakDays: Int
    public var maxHabitRun: Int
    public var totalSavedMoney: Decimal
    public var currencyCode: String
    public var closedTodayAfterYesterdayLapse: Bool
    public var alreadyEarned: Set<BadgeKind>

    public init(streakDays: Int, maxHabitRun: Int, totalSavedMoney: Decimal,
                currencyCode: String, closedTodayAfterYesterdayLapse: Bool,
                alreadyEarned: Set<BadgeKind>) {
        self.streakDays = streakDays
        self.maxHabitRun = maxHabitRun
        self.totalSavedMoney = totalSavedMoney
        self.currencyCode = currencyCode
        self.closedTodayAfterYesterdayLapse = closedTodayAfterYesterdayLapse
        self.alreadyEarned = alreadyEarned
    }
}

/// 마무리 완료 직후 일괄 판정. 획득한 배지는 회수되지 않는다 (PRD §7).
public enum BadgeEngine {
    public static let streakMilestones = [3, 7, 14, 30, 60, 100]
    public static let habitRunMilestones = [7, 30, 100]
    /// 통화별 누적 아낀 돈 임계값. 테이블에 없는 통화는 USD 임계값을 쓴다 (PRD §6.3)
    public static let moneyMilestones: [String: [Int]] = [
        "KRW": [10_000, 50_000, 100_000, 500_000],
        "USD": [10, 50, 100, 500],
    ]

    public static func judge(_ input: BadgeJudgeInput) -> [BadgeKind] {
        var earned: [BadgeKind] = []

        for m in streakMilestones where input.streakDays >= m {
            earned.append(.checkinStreak(days: m))
        }
        for m in habitRunMilestones where input.maxHabitRun >= m {
            earned.append(.habitRun(days: m))
        }
        let milestones = moneyMilestones[input.currencyCode] ?? moneyMilestones["USD"]!
        for m in milestones where input.totalSavedMoney >= Decimal(m) {
            earned.append(.moneySaved(milestone: m))
        }
        if input.closedTodayAfterYesterdayLapse {
            earned.append(.honesty)
        }

        return earned.filter { !input.alreadyEarned.contains($0) }
    }
}
```

- [ ] **Step 4: 통과 확인**

Run: `tuist test Shared`
Expected: PASS (24 tests)

- [ ] **Step 5: Commit**

```bash
git add Sources/Shared/Domain/Engines/BadgeEngine.swift Tests/SharedTests/BadgeEngineTests.swift
git commit -m "feat: BadgeEngine — 스트릭·절제·아낀 돈·정직 배지 판정"
```

---

### Task 6: SwiftData 모델 + Repository 프로토콜/구현

**Files:**
- Create: `Sources/Shared/Domain/Interfaces/HabitRepository.swift`
- Create: `Sources/Shared/Domain/Interfaces/TrackingRepository.swift`
- Create: `Sources/Shared/Data/Persistence/PersistenceModels.swift`
- Create: `Sources/Shared/Data/Persistence/SwiftDataHabitRepository.swift`
- Create: `Sources/Shared/Data/Persistence/SwiftDataTrackingRepository.swift`
- Create: `Sources/Shared/Data/Persistence/AppModelContainer.swift`
- Test: `Tests/SharedTests/RepositoryTests.swift`

**Interfaces:**
- Consumes: Task 1·2의 도메인 타입 전부
- Produces:

```swift
public protocol HabitRepository: Sendable {
    func habits(includeArchived: Bool) async throws -> [Habit]
    func activeHabits(on day: DayStamp) async throws -> [Habit]
    func save(_ habit: Habit) async throws            // upsert
    func archive(id: UUID, on day: DayStamp) async throws
    func unarchive(id: UUID) async throws
    func delete(id: UUID) async throws                // 기록 포함 영구 삭제 (PRD §11)
}

public protocol TrackingRepository: Sendable {
    func closes(in range: ClosedRange<DayStamp>) async throws -> [DayClose]
    func close(on day: DayStamp) async throws -> DayClose?
    func saveClose(_ close: DayClose) async throws
    func marks(in range: ClosedRange<DayStamp>) async throws -> [HabitDayMark]
    func marks(habitID: UUID) async throws -> [HabitDayMark]
    func saveMark(_ mark: HabitDayMark) async throws        // 같은 (habitID, day)는 교체
    func deleteMark(habitID: UUID, day: DayStamp) async throws
    func streakState() async throws -> StreakState
    func saveStreakState(_ state: StreakState) async throws
    func badges() async throws -> [BadgeAward]
    func saveBadges(_ awards: [BadgeAward]) async throws
    func deleteAllData() async throws                        // 설정 > 데이터 초기화 (PRD §11)
}
```

- `AppModelContainer.make(inMemory: Bool) throws -> ModelContainer`

- [ ] **Step 1: 실패하는 테스트 작성**

`Tests/SharedTests/RepositoryTests.swift`:

```swift
import Foundation
import Testing
@testable import Shared

struct RepositoryTests {
    let day = DayStamp(year: 2026, month: 7, day: 8)

    func makeRepos() throws -> (HabitRepository, TrackingRepository) {
        let container = try AppModelContainer.make(inMemory: true)
        return (SwiftDataHabitRepository(modelContainer: container),
                SwiftDataTrackingRepository(modelContainer: container))
    }

    func habit() -> Habit {
        Habit(id: UUID(), name: "담배", icon: "cigarette", colorHex: "D4B15F",
              rate: .money(3000), createdDay: day, firstTrackedDay: day)
    }

    @Test func 습관_저장_조회_라운드트립() async throws {
        let (repo, _) = try makeRepos()
        let h = habit()
        try await repo.save(h)
        let loaded = try await repo.habits(includeArchived: false)
        #expect(loaded == [h])
    }

    @Test func 보관하면_활성목록에서_빠지고_복원된다() async throws {
        let (repo, _) = try makeRepos()
        let h = habit()
        try await repo.save(h)
        try await repo.archive(id: h.id, on: day.advanced(by: 1))
        #expect(try await repo.activeHabits(on: day.advanced(by: 2)).isEmpty)
        #expect(try await repo.habits(includeArchived: true).count == 1)
        try await repo.unarchive(id: h.id)
        #expect(try await repo.activeHabits(on: day.advanced(by: 2)).count == 1)
    }

    @Test func 삭제는_마크까지_지운다() async throws {
        let (repo, tracking) = try makeRepos()
        let h = habit()
        try await repo.save(h)
        try await tracking.saveMark(HabitDayMark(habitID: h.id, day: day,
                                                 kind: .lapsed(source: .immediate)))
        try await repo.delete(id: h.id)
        #expect(try await tracking.marks(habitID: h.id).isEmpty)
    }

    @Test func 같은날_마크는_교체된다() async throws {
        let (_, tracking) = try makeRepos()
        let id = UUID()
        try await tracking.saveMark(HabitDayMark(habitID: id, day: day, kind: .unknown))
        try await tracking.saveMark(HabitDayMark(habitID: id, day: day,
                                                 kind: .lapsed(source: .atClose), memo: "야근"))
        let marks = try await tracking.marks(habitID: id)
        #expect(marks.count == 1)
        #expect(marks[0].kind == .lapsed(source: .atClose))
        #expect(marks[0].memo == "야근")
    }

    @Test func 마무리와_스트릭상태_배지_라운드트립() async throws {
        let (_, tracking) = try makeRepos()
        let close = DayClose(day: day, kind: .sameDay, closedAt: Date(timeIntervalSince1970: 0))
        try await tracking.saveClose(close)
        #expect(try await tracking.close(on: day) == close)

        try await tracking.saveStreakState(StreakState(current: 5, best: 9, freezes: 1, freezeAccrual: 5))
        #expect(try await tracking.streakState().best == 9)

        try await tracking.saveBadges([BadgeAward(kind: .honesty,
                                                  earnedAt: Date(timeIntervalSince1970: 0))])
        #expect(try await tracking.badges().map(\.kind) == [.honesty])
    }

    @Test func 데이터초기화는_모든_기록을_지운다() async throws {
        let (_, tracking) = try makeRepos()
        try await tracking.saveClose(DayClose(day: day, kind: .sameDay, closedAt: .now))
        try await tracking.deleteAllData()
        #expect(try await tracking.close(on: day) == nil)
        #expect(try await tracking.streakState() == StreakState())
    }
}
```

- [ ] **Step 2: 실패 확인**

Run: `tuist test Shared`
Expected: 컴파일 실패 — `cannot find 'AppModelContainer' in scope`

- [ ] **Step 3: 프로토콜 + SwiftData 구현**

`Sources/Shared/Domain/Interfaces/HabitRepository.swift` / `TrackingRepository.swift`: 위 **Interfaces** 블록의 프로토콜 선언을 그대로 파일로 만든다 (import Foundation만 필요).

`Sources/Shared/Data/Persistence/PersistenceModels.swift`:

```swift
import Foundation
import SwiftData

// DayStamp는 정렬 가능한 Int 키(yyyymmdd)로 저장한다. 변환은 Data 레이어에 가둔다.
extension DayStamp {
    var storageKey: Int { year * 10_000 + month * 100 + day }
    init(storageKey: Int) {
        self.init(year: storageKey / 10_000, month: (storageKey / 100) % 100, day: storageKey % 100)
    }
}

@Model
final class HabitModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var rateData: Data          // Habit.Rate를 JSONEncoder로 저장
    var createdDayKey: Int
    var firstTrackedDayKey: Int
    var archivedDayKey: Int?

    init(_ habit: Habit) {
        id = habit.id
        name = habit.name
        icon = habit.icon
        colorHex = habit.colorHex
        rateData = (try? JSONEncoder().encode(habit.rate)) ?? Data()
        createdDayKey = habit.createdDay.storageKey
        firstTrackedDayKey = habit.firstTrackedDay.storageKey
        archivedDayKey = habit.archivedDay?.storageKey
    }

    var entity: Habit {
        Habit(id: id, name: name, icon: icon, colorHex: colorHex,
              rate: (try? JSONDecoder().decode(Habit.Rate.self, from: rateData)) ?? .none,
              createdDay: DayStamp(storageKey: createdDayKey),
              firstTrackedDay: DayStamp(storageKey: firstTrackedDayKey),
              archivedDay: archivedDayKey.map(DayStamp.init(storageKey:)))
    }
}

@Model
final class DayCloseModel {
    @Attribute(.unique) var dayKey: Int
    var kindRaw: String
    var closedAt: Date

    init(_ close: DayClose) {
        dayKey = close.day.storageKey
        kindRaw = close.kind.rawValue
        closedAt = close.closedAt
    }

    var entity: DayClose {
        DayClose(day: DayStamp(storageKey: dayKey),
                 kind: DayClose.Kind(rawValue: kindRaw) ?? .sameDay, closedAt: closedAt)
    }
}

@Model
final class HabitDayMarkModel {
    @Attribute(.unique) var compositeKey: String   // "habitID|dayKey"
    var habitID: UUID
    var dayKey: Int
    var kindData: Data
    var memo: String?

    init(_ mark: HabitDayMark) {
        compositeKey = "\(mark.habitID.uuidString)|\(mark.day.storageKey)"
        habitID = mark.habitID
        dayKey = mark.day.storageKey
        kindData = (try? JSONEncoder().encode(mark.kind)) ?? Data()
        memo = mark.memo
    }

    var entity: HabitDayMark {
        HabitDayMark(habitID: habitID, day: DayStamp(storageKey: dayKey),
                     kind: (try? JSONDecoder().decode(HabitDayMark.Kind.self, from: kindData)) ?? .unknown,
                     memo: memo)
    }
}

@Model
final class StreakStateModel {
    @Attribute(.unique) var singleton: Int   // 항상 0
    var current: Int
    var best: Int
    var freezes: Int
    var freezeAccrual: Int

    init(_ state: StreakState) {
        singleton = 0
        current = state.current
        best = state.best
        freezes = state.freezes
        freezeAccrual = state.freezeAccrual
    }

    var entity: StreakState {
        StreakState(current: current, best: best, freezes: freezes, freezeAccrual: freezeAccrual)
    }
}

@Model
final class BadgeAwardModel {
    @Attribute(.unique) var kindData: Data
    var earnedAt: Date

    init(_ award: BadgeAward) {
        kindData = (try? JSONEncoder().encode(award.kind)) ?? Data()
        earnedAt = award.earnedAt
    }

    var entity: BadgeAward? {
        guard let kind = try? JSONDecoder().decode(BadgeKind.self, from: kindData) else { return nil }
        return BadgeAward(kind: kind, earnedAt: earnedAt)
    }
}
```

`Sources/Shared/Data/Persistence/AppModelContainer.swift`:

```swift
import SwiftData

public enum AppModelContainer {
    public static func make(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema([HabitModel.self, DayCloseModel.self, HabitDayMarkModel.self,
                             StreakStateModel.self, BadgeAwardModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
```

`Sources/Shared/Data/Persistence/SwiftDataHabitRepository.swift`:

```swift
import Foundation
import SwiftData

@ModelActor
public actor SwiftDataHabitRepository: HabitRepository {
    public func habits(includeArchived: Bool) async throws -> [Habit] {
        let all = try modelContext.fetch(FetchDescriptor<HabitModel>(
            sortBy: [SortDescriptor(\.createdDayKey)]))
        let entities = all.map(\.entity)
        return includeArchived ? entities : entities.filter { $0.archivedDay == nil }
    }

    public func activeHabits(on day: DayStamp) async throws -> [Habit] {
        try await habits(includeArchived: true).filter { $0.isActive(on: day) }
    }

    public func save(_ habit: Habit) async throws {
        try deleteModel(id: habit.id)
        modelContext.insert(HabitModel(habit))
        try modelContext.save()
    }

    public func archive(id: UUID, on day: DayStamp) async throws {
        guard let model = try fetchModel(id: id) else { return }
        model.archivedDayKey = day.storageKey
        try modelContext.save()
    }

    public func unarchive(id: UUID) async throws {
        guard let model = try fetchModel(id: id) else { return }
        model.archivedDayKey = nil
        try modelContext.save()
    }

    public func delete(id: UUID) async throws {
        try deleteModel(id: id)
        try modelContext.delete(model: HabitDayMarkModel.self,
                                where: #Predicate { $0.habitID == id })
        try modelContext.save()
    }

    private func fetchModel(id: UUID) throws -> HabitModel? {
        try modelContext.fetch(FetchDescriptor<HabitModel>(
            predicate: #Predicate { $0.id == id })).first
    }

    private func deleteModel(id: UUID) throws {
        try modelContext.delete(model: HabitModel.self, where: #Predicate { $0.id == id })
    }
}
```

`Sources/Shared/Data/Persistence/SwiftDataTrackingRepository.swift`:

```swift
import Foundation
import SwiftData

@ModelActor
public actor SwiftDataTrackingRepository: TrackingRepository {
    public func closes(in range: ClosedRange<DayStamp>) async throws -> [DayClose] {
        let lower = range.lowerBound.storageKey
        let upper = range.upperBound.storageKey
        return try modelContext.fetch(FetchDescriptor<DayCloseModel>(
            predicate: #Predicate { $0.dayKey >= lower && $0.dayKey <= upper },
            sortBy: [SortDescriptor(\.dayKey)])).map(\.entity)
    }

    public func close(on day: DayStamp) async throws -> DayClose? {
        let key = day.storageKey
        return try modelContext.fetch(FetchDescriptor<DayCloseModel>(
            predicate: #Predicate { $0.dayKey == key })).first?.entity
    }

    public func saveClose(_ close: DayClose) async throws {
        modelContext.insert(DayCloseModel(close))
        try modelContext.save()
    }

    public func marks(in range: ClosedRange<DayStamp>) async throws -> [HabitDayMark] {
        let lower = range.lowerBound.storageKey
        let upper = range.upperBound.storageKey
        return try modelContext.fetch(FetchDescriptor<HabitDayMarkModel>(
            predicate: #Predicate { $0.dayKey >= lower && $0.dayKey <= upper })).map(\.entity)
    }

    public func marks(habitID: UUID) async throws -> [HabitDayMark] {
        try modelContext.fetch(FetchDescriptor<HabitDayMarkModel>(
            predicate: #Predicate { $0.habitID == habitID })).map(\.entity)
    }

    public func saveMark(_ mark: HabitDayMark) async throws {
        try await deleteMark(habitID: mark.habitID, day: mark.day)
        modelContext.insert(HabitDayMarkModel(mark))
        try modelContext.save()
    }

    public func deleteMark(habitID: UUID, day: DayStamp) async throws {
        let key = "\(habitID.uuidString)|\(day.storageKey)"
        try modelContext.delete(model: HabitDayMarkModel.self,
                                where: #Predicate { $0.compositeKey == key })
        try modelContext.save()
    }

    public func streakState() async throws -> StreakState {
        try modelContext.fetch(FetchDescriptor<StreakStateModel>()).first?.entity ?? StreakState()
    }

    public func saveStreakState(_ state: StreakState) async throws {
        try modelContext.delete(model: StreakStateModel.self)
        modelContext.insert(StreakStateModel(state))
        try modelContext.save()
    }

    public func badges() async throws -> [BadgeAward] {
        try modelContext.fetch(FetchDescriptor<BadgeAwardModel>(
            sortBy: [SortDescriptor(\.earnedAt)])).compactMap(\.entity)
    }

    public func saveBadges(_ awards: [BadgeAward]) async throws {
        for award in awards { modelContext.insert(BadgeAwardModel(award)) }
        try modelContext.save()
    }

    public func deleteAllData() async throws {
        try modelContext.delete(model: DayCloseModel.self)
        try modelContext.delete(model: HabitDayMarkModel.self)
        try modelContext.delete(model: StreakStateModel.self)
        try modelContext.delete(model: BadgeAwardModel.self)
        try modelContext.delete(model: HabitModel.self)
        try modelContext.save()
    }
}
```

- [ ] **Step 4: 통과 확인**

Run: `tuist test Shared`
Expected: PASS (30 tests)

- [ ] **Step 5: Commit**

```bash
git add Sources/Shared/Domain/Interfaces Sources/Shared/Data/Persistence Tests/SharedTests/RepositoryTests.swift
git commit -m "feat: SwiftData 영속화 — Habit·Tracking Repository"
```

---

### Task 7: AppCurrency + PresetCatalog

**Files:**
- Create: `Sources/Shared/Domain/Entities/AppCurrency.swift`
- Create: `Sources/Shared/Domain/Entities/PresetCatalog.swift`
- Test: `Tests/SharedTests/PresetCatalogTests.swift`

**Interfaces:**
- Produces:
  - `AppCurrency(code: String)`, `AppCurrency.supported: [AppCurrency]`, `AppCurrency.default(for locale: Locale) -> AppCurrency`
  - `HabitPreset(id:nameKey:icon:defaultRate:)`, `PresetID` enum
  - `PresetCatalog.presets(for: AppCurrency) -> [HabitPreset]`

- [ ] **Step 1: 실패하는 테스트 작성**

`Tests/SharedTests/PresetCatalogTests.swift`:

```swift
import Foundation
import Testing
@testable import Shared

struct PresetCatalogTests {
    @Test func 한국로케일은_KRW가_기본이다() {
        let locale = Locale(identifier: "ko_KR")
        #expect(AppCurrency.default(for: locale).code == "KRW")
    }

    @Test func 미지원_로케일통화는_USD_폴백() {
        let locale = Locale(identifier: "fa_IR")   // 이란 리알 — 미지원
        #expect(AppCurrency.default(for: locale).code == "USD")
    }

    @Test func KRW는_근거기반_단가가_채워진다() {
        let presets = PresetCatalog.presets(for: AppCurrency(code: "KRW"))
        let cigarette = presets.first { $0.id == .cigarette }!
        #expect(cigarette.defaultRate == .money(3000))
        let delivery = presets.first { $0.id == .delivery }!
        #expect(delivery.defaultRate == .money(30000))
    }

    @Test func USD_테이블() {
        let presets = PresetCatalog.presets(for: AppCurrency(code: "USD"))
        #expect(presets.first { $0.id == .cigarette }!.defaultRate == .money(6))
    }

    @Test func 그외통화는_돈프리셋_단가가_빈칸이다() {
        let presets = PresetCatalog.presets(for: AppCurrency(code: "EUR"))
        #expect(presets.first { $0.id == .cigarette }!.defaultRate == Habit.Rate.none)
        // 시간 프리셋은 지역 무관 공통 (PRD §5.3)
        #expect(presets.first { $0.id == .sns }!.defaultRate == .time(minutes: 60))
    }

    @Test func 프리셋은_10종이다() {
        #expect(PresetCatalog.presets(for: AppCurrency(code: "KRW")).count == 10)
    }
}
```

- [ ] **Step 2: 실패 확인**

Run: `tuist test Shared`
Expected: 컴파일 실패 — `cannot find 'AppCurrency' in scope`

- [ ] **Step 3: 구현**

`Sources/Shared/Domain/Entities/AppCurrency.swift`:

```swift
import Foundation

/// 앱 통화 — 전역 1개. 환율 연동·재환산 없음 (PRD §6.2)
public struct AppCurrency: Hashable, Codable, Sendable {
    public let code: String

    public init(code: String) {
        self.code = code
    }

    /// v1 지원 통화 (PRD §6.2 — 주요 통화 약 20종)
    public static let supported: [AppCurrency] = [
        "KRW", "USD", "EUR", "JPY", "GBP", "CNY", "TWD", "HKD", "SGD", "THB",
        "VND", "IDR", "PHP", "INR", "AUD", "CAD", "NZD", "BRL", "MXN", "CHF",
    ].map(AppCurrency.init(code:))

    /// 최초 실행 시 기기 로케일의 통화. 미지원 로케일은 USD (PRD §11)
    public static func `default`(for locale: Locale) -> AppCurrency {
        guard let code = locale.currency?.identifier,
              supported.contains(AppCurrency(code: code)) else {
            return AppCurrency(code: "USD")
        }
        return AppCurrency(code: code)
    }
}
```

`Sources/Shared/Domain/Entities/PresetCatalog.swift`:

```swift
import Foundation

public enum PresetID: String, CaseIterable, Codable, Sendable {
    case cigarette, lateNightSnack, delivery, alcohol, shopping, cafe, snack
    case sns, shorts, gaming
}

public struct HabitPreset: Hashable, Sendable, Identifiable {
    public let id: PresetID
    /// AppStrings 키 — UI 레이어에서 현지화 (도메인은 문자열을 노출하지 않는다)
    public let nameKey: String
    public let icon: String
    public let defaultRate: Habit.Rate
}

/// 프리셋 라이브러리 (PRD §5.3) — 단가는 통화별 테이블, KRW·USD 2종 제공
public enum PresetCatalog {
    static let moneyAmounts: [String: [PresetID: Decimal]] = [
        "KRW": [.cigarette: 3000, .lateNightSnack: 20000, .delivery: 30000, .alcohol: 15000,
                .shopping: 10000, .cafe: 5000, .snack: 5000],
        "USD": [.cigarette: 6, .lateNightSnack: 15, .delivery: 25, .alcohol: 12,
                .shopping: 10, .cafe: 5, .snack: 3],
    ]
    static let timeMinutes: [PresetID: Int] = [.sns: 60, .shorts: 60, .gaming: 90]
    static let icons: [PresetID: String] = [
        .cigarette: "cigarette", .lateNightSnack: "drumstick", .delivery: "utensils",
        .alcohol: "beer", .shopping: "shopping-cart", .cafe: "coffee", .snack: "cookie",
        .sns: "smartphone", .shorts: "youtube", .gaming: "gamepad-2",
    ]

    public static func presets(for currency: AppCurrency) -> [HabitPreset] {
        let amounts = moneyAmounts[currency.code]
        return PresetID.allCases.map { id in
            let rate: Habit.Rate
            if let minutes = timeMinutes[id] {
                rate = .time(minutes: minutes)
            } else if let amount = amounts?[id] {
                rate = .money(amount)
            } else {
                rate = .none   // 그 외 통화: 이름·아이콘만 채우고 단가는 빈칸 (PRD §5.3)
            }
            return HabitPreset(id: id, nameKey: "preset.\(id.rawValue)",
                               icon: icons[id]!, defaultRate: rate)
        }
    }
}
```

- [ ] **Step 4: 통과 확인**

Run: `tuist test Shared`
Expected: PASS (36 tests)

- [ ] **Step 5: Commit**

```bash
git add Sources/Shared/Domain/Entities/AppCurrency.swift Sources/Shared/Domain/Entities/PresetCatalog.swift Tests/SharedTests/PresetCatalogTests.swift
git commit -m "feat: AppCurrency·PresetCatalog — 통화별 단가 테이블"
```

---

### Task 8: CheckInService (마무리·소급·즉시 기록 오케스트레이션)

**Files:**
- Create: `Sources/Shared/Domain/Interfaces/CheckInServicing.swift`
- Create: `Sources/Shared/Data/CheckInService.swift`
- Test: `Tests/SharedTests/CheckInServiceTests.swift`

**Interfaces:**
- Consumes: `HabitRepository`, `TrackingRepository` (Task 6), `StreakEngine`(Task 3), `ProgressCalculator`(Task 4), `BadgeEngine`(Task 5), `DayBoundary`(Task 1)
- Produces:

```swift
public enum YesterdayAnswer: Sendable { case resisted, lapsed, unknown }

public struct CloseResult: Sendable {
    public let close: DayClose
    public let streak: StreakState
    public let newBadges: [BadgeKind]
}

public enum CheckInError: Error, Equatable {
    case alreadyClosed        // 그날 다시 마무리할 수 없다 (PRD §4.1)
    case noActiveHabits       // 습관 0개 — 마무리 불가 (PRD §11)
    case notEditable          // 오늘·어제까지만 수정 가능 (PRD §4.2)
}

public protocol CheckInServicing: Sendable {
    /// 앱 진입 시 호출: 프리즈 자동 소모·리셋 반영 후 현재 상태 반환
    func refresh(now: Date) async throws -> StreakDecision
    /// 오늘 마무리. lapsedHabitIDs 외 활성 습관은 일괄 "참았다"
    func closeToday(lapsedHabitIDs: Set<UUID>, now: Date) async throws -> CloseResult
    /// 어제 소급 마무리 (프리즈 소모 없음)
    func closeYesterday(answers: [UUID: YesterdayAnswer], now: Date) async throws -> CloseResult
    /// 낮의 즉시 무너짐 기록 — 그날 마무리에 자동 반영
    func recordImmediateLapse(habitID: UUID, memo: String?, now: Date) async throws
}
```

- [ ] **Step 1: 실패하는 테스트 작성**

`Tests/SharedTests/CheckInServiceTests.swift`:

```swift
import Foundation
import Testing
@testable import Shared

struct CheckInServiceTests {
    let cal = Calendar(identifier: .gregorian)

    func fixture() throws -> (CheckInService, HabitRepository, TrackingRepository) {
        let container = try AppModelContainer.make(inMemory: true)
        let habits = SwiftDataHabitRepository(modelContainer: container)
        let tracking = SwiftDataTrackingRepository(modelContainer: container)
        let service = CheckInService(habitRepository: habits, trackingRepository: tracking,
                                     currency: AppCurrency(code: "KRW"), calendar: cal)
        return (service, habits, tracking)
    }

    /// 2026-07-08 21:00 로컬
    var now: Date { cal.date(from: DateComponents(year: 2026, month: 7, day: 8, hour: 21))! }
    var today: DayStamp { DayBoundary.dayStamp(for: now, calendar: cal) }

    func addHabit(_ repo: HabitRepository, daysAgo: Int = 10) async throws -> Habit {
        let created = today.advanced(by: -daysAgo, calendar: cal)
        let h = Habit(id: UUID(), name: "담배", icon: "cigarette", colorHex: "D4B15F",
                      rate: .money(3000), createdDay: created, firstTrackedDay: created)
        try await repo.save(h)
        return h
    }

    @Test func 마무리하면_스트릭이_오르고_모든_활성습관이_참은것으로_확정된다() async throws {
        let (service, habits, tracking) = try fixture()
        let h = try await addHabit(habits)
        let result = try await service.closeToday(lapsedHabitIDs: [], now: now)
        #expect(result.close.day == today && result.close.kind == .sameDay)
        #expect(result.streak.current == 1)
        // 마크 없음 + 마무리됨 = 참았다 (이진 모델)
        #expect(try await tracking.marks(habitID: h.id).isEmpty)
    }

    @Test func 같은날_두번_마무리는_거부된다() async throws {
        let (service, habits, _) = try fixture()
        _ = try await addHabit(habits)
        _ = try await service.closeToday(lapsedHabitIDs: [], now: now)
        await #expect(throws: CheckInError.alreadyClosed) {
            _ = try await service.closeToday(lapsedHabitIDs: [], now: now)
        }
    }

    @Test func 습관0개면_마무리_불가() async throws {
        let (service, _, _) = try fixture()
        await #expect(throws: CheckInError.noActiveHabits) {
            _ = try await service.closeToday(lapsedHabitIDs: [], now: now)
        }
    }

    @Test func 무너진_습관은_atClose_마크가_남고_스트릭은_유지된다() async throws {
        let (service, habits, tracking) = try fixture()
        let h = try await addHabit(habits)
        let result = try await service.closeToday(lapsedHabitIDs: [h.id], now: now)
        let marks = try await tracking.marks(habitID: h.id)
        #expect(marks.count == 1)
        #expect(marks[0].kind == .lapsed(source: .atClose))
        #expect(result.streak.current == 1)   // 무너져도 기록하면 스트릭 유지 (PRD 원칙)
    }

    @Test func 즉시기록은_마무리에_자동반영되고_중복마크되지_않는다() async throws {
        let (service, habits, tracking) = try fixture()
        let h = try await addHabit(habits)
        try await service.recordImmediateLapse(habitID: h.id, memo: "회식", now: now)
        _ = try await service.closeToday(lapsedHabitIDs: [h.id], now: now)
        let marks = try await tracking.marks(habitID: h.id)
        #expect(marks.count == 1)
        #expect(marks[0].kind == .lapsed(source: .immediate))   // 즉시 기록이 우선
        #expect(marks[0].memo == "회식")
    }

    @Test func 어제소급은_backfill로_마무리되고_기억안남은_unknown_마크() async throws {
        let (service, habits, tracking) = try fixture()
        let h = try await addHabit(habits)
        let result = try await service.closeYesterday(answers: [h.id: .unknown], now: now)
        #expect(result.close.kind == .backfill)
        #expect(result.close.day == today.advanced(by: -1, calendar: cal))
        let marks = try await tracking.marks(habitID: h.id)
        #expect(marks.count == 1 && marks[0].kind == .unknown)
    }

    @Test func 어제가_이미_마무리됐으면_소급_거부() async throws {
        let (service, habits, _) = try fixture()
        let h = try await addHabit(habits)
        _ = try await service.closeYesterday(answers: [h.id: .resisted], now: now)
        await #expect(throws: CheckInError.alreadyClosed) {
            _ = try await service.closeYesterday(answers: [h.id: .resisted], now: now)
        }
    }

    @Test func 새벽1시_마무리는_전날로_귀속된다() async throws {
        let (service, habits, tracking) = try fixture()
        _ = try await addHabit(habits)
        let lateNight = cal.date(from: DateComponents(year: 2026, month: 7, day: 9, hour: 1))!
        _ = try await service.closeToday(lapsedHabitIDs: [], now: lateNight)
        #expect(try await tracking.close(on: today) != nil)   // 7/8로 귀속
    }

    @Test func 마무리후_추가한_습관은_오늘_마크대상이_아니다() async throws {
        let (service, habits, _) = try fixture()
        _ = try await addHabit(habits)
        _ = try await service.closeToday(lapsedHabitIDs: [], now: now)
        // 마무리 후 추가 → firstTrackedDay는 내일 (Plan 2의 습관 추가 플로우가 이 규칙으로 생성)
        let late = Habit(id: UUID(), name: "야식", icon: "drumstick", colorHex: "A8B36A",
                         rate: .money(20000), createdDay: today,
                         firstTrackedDay: today.advanced(by: 1, calendar: cal))
        try await habits.save(late)
        #expect(try await habits.activeHabits(on: today).count == 1)
    }

    @Test func 배지는_마무리직후_일괄판정된다() async throws {
        let (service, habits, _) = try fixture()
        _ = try await addHabit(habits, daysAgo: 30)
        let result = try await service.closeToday(lapsedHabitIDs: [], now: now)
        // 첫 마무리: 스트릭 1 → 스트릭 배지 없음. 관대 모델 절제 31일 → habitRun 7·30 획득
        #expect(result.newBadges.contains(.habitRun(days: 30)))
        #expect(!result.newBadges.contains(.checkinStreak(days: 3)))
        // 아낀 돈 31×3000=93,000 → 1만·5만 달성
        #expect(result.newBadges.contains(.moneySaved(milestone: 50000)))
    }
}
```

- [ ] **Step 2: 실패 확인**

Run: `tuist test Shared`
Expected: 컴파일 실패 — `cannot find 'CheckInService' in scope`

- [ ] **Step 3: 구현**

`Sources/Shared/Domain/Interfaces/CheckInServicing.swift`: 위 **Interfaces** 블록의 `YesterdayAnswer`·`CloseResult`·`CheckInError`·`CheckInServicing`을 그대로 파일로 만든다.

`Sources/Shared/Data/CheckInService.swift`:

```swift
import Foundation

public actor CheckInService: CheckInServicing {
    private let habitRepository: HabitRepository
    private let trackingRepository: TrackingRepository
    private let currency: AppCurrency
    private let calendar: Calendar

    public init(habitRepository: HabitRepository, trackingRepository: TrackingRepository,
                currency: AppCurrency, calendar: Calendar = .current) {
        self.habitRepository = habitRepository
        self.trackingRepository = trackingRepository
        self.currency = currency
        self.calendar = calendar
    }

    // MARK: - Refresh (앱 진입)

    public func refresh(now: Date) async throws -> StreakDecision {
        let today = DayBoundary.dayStamp(for: now, calendar: calendar)
        let decision = try await evaluateStreak(today: today)
        for day in decision.freezeFills {
            try await trackingRepository.saveClose(DayClose(day: day, kind: .freeze, closedAt: now))
        }
        try await trackingRepository.saveStreakState(decision.state)
        return decision
    }

    // MARK: - Close

    public func closeToday(lapsedHabitIDs: Set<UUID>, now: Date) async throws -> CloseResult {
        let today = DayBoundary.dayStamp(for: now, calendar: calendar)
        return try await close(day: today, kind: .sameDay,
                               lapsedHabitIDs: lapsedHabitIDs, unknownHabitIDs: [], now: now)
    }

    public func closeYesterday(answers: [UUID: YesterdayAnswer], now: Date) async throws -> CloseResult {
        let yesterday = DayBoundary.dayStamp(for: now, calendar: calendar).advanced(by: -1, calendar: calendar)
        let lapsed = Set(answers.filter { $0.value == .lapsed }.keys)
        let unknown = Set(answers.filter { $0.value == .unknown }.keys)
        return try await close(day: yesterday, kind: .backfill,
                               lapsedHabitIDs: lapsed, unknownHabitIDs: unknown, now: now)
    }

    private func close(day: DayStamp, kind: DayClose.Kind, lapsedHabitIDs: Set<UUID>,
                       unknownHabitIDs: Set<UUID>, now: Date) async throws -> CloseResult {
        guard try await trackingRepository.close(on: day) == nil else {
            throw CheckInError.alreadyClosed
        }
        let active = try await habitRepository.activeHabits(on: day)
        guard !active.isEmpty else { throw CheckInError.noActiveHabits }

        // 마크 저장 — 즉시 기록(immediate)이 이미 있으면 보존한다
        let existing = try await trackingRepository.marks(in: day...day)
        let existingIDs = Set(existing.map(\.habitID))
        for id in lapsedHabitIDs where !existingIDs.contains(id) {
            try await trackingRepository.saveMark(
                HabitDayMark(habitID: id, day: day, kind: .lapsed(source: .atClose)))
        }
        for id in unknownHabitIDs where !existingIDs.contains(id) {
            try await trackingRepository.saveMark(
                HabitDayMark(habitID: id, day: day, kind: .unknown))
        }

        let close = DayClose(day: day, kind: kind, closedAt: now)
        try await trackingRepository.saveClose(close)

        // 스트릭 갱신 + 적립
        let today = DayBoundary.dayStamp(for: now, calendar: calendar)
        var decision = try await evaluateStreak(today: today)
        decision.state = StreakEngine.accrueAfterClose(decision.state)
        try await trackingRepository.saveStreakState(decision.state)

        // 배지 판정 (PRD §7 — 마무리 완료 직후 일괄)
        let newBadges = try await judgeBadges(day: day, streak: decision.state, now: now)

        return CloseResult(close: close, streak: decision.state, newBadges: newBadges)
    }

    public func recordImmediateLapse(habitID: UUID, memo: String?, now: Date) async throws {
        let today = DayBoundary.dayStamp(for: now, calendar: calendar)
        try await trackingRepository.saveMark(
            HabitDayMark(habitID: habitID, day: today,
                         kind: .lapsed(source: .immediate), memo: memo))
    }

    // MARK: - Private

    private func evaluateStreak(today: DayStamp) async throws -> StreakDecision {
        let state = try await trackingRepository.streakState()
        let lookback = today.advanced(by: -(max(state.current, 1) + StreakEngine.maxFreezes + 2),
                                      calendar: calendar)
        let closes = try await trackingRepository.closes(in: lookback...today)
        var closedMap: [DayStamp: DayClose.Kind] = [:]
        for c in closes { closedMap[c.day] = c.kind }

        // 활성 습관 0개였던 날 = 일시정지 (PRD §11)
        var paused: Set<DayStamp> = []
        var day = lookback
        while day <= today {
            if try await habitRepository.activeHabits(on: day).isEmpty { paused.insert(day) }
            day = day.advanced(by: 1, calendar: calendar)
        }

        return StreakEngine.evaluate(
            StreakInput(today: today, closedDays: closedMap, pausedDays: paused, state: state),
            calendar: calendar)
    }

    private func judgeBadges(day: DayStamp, streak: StreakState, now: Date) async throws -> [BadgeKind] {
        let habits = try await habitRepository.habits(includeArchived: true)
        var maxRun = 0
        var totalMoney: Decimal = 0
        for habit in habits {
            let marks = try await trackingRepository.marks(habitID: habit.id)
            let p = ProgressCalculator.progress(for: habit, marks: marks, today: day, calendar: calendar)
            maxRun = max(maxRun, p.currentRun)
            if case .money(let amount) = p.saved { totalMoney += amount }
        }
        let yesterday = day.advanced(by: -1, calendar: calendar)
        let yesterdayMarks = try await trackingRepository.marks(in: yesterday...yesterday)
        let lapsedYesterday = yesterdayMarks.contains { if case .lapsed = $0.kind { true } else { false } }

        let earned = try await trackingRepository.badges().map(\.kind)
        let new = BadgeEngine.judge(BadgeJudgeInput(
            streakDays: streak.current, maxHabitRun: maxRun, totalSavedMoney: totalMoney,
            currencyCode: currency.code,
            closedTodayAfterYesterdayLapse: lapsedYesterday,
            alreadyEarned: Set(earned)))
        try await trackingRepository.saveBadges(new.map { BadgeAward(kind: $0, earnedAt: now) })
        return new
    }
}
```

- [ ] **Step 4: 통과 확인**

Run: `tuist test Shared`
Expected: PASS (46 tests)

- [ ] **Step 5: Commit**

```bash
git add Sources/Shared/Domain/Interfaces/CheckInServicing.swift Sources/Shared/Data/CheckInService.swift Tests/SharedTests/CheckInServiceTests.swift
git commit -m "feat: CheckInService — 마무리·소급·즉시 기록 오케스트레이션"
```

---

### Task 9: DI 배선 + 통합 시나리오 테스트

**Files:**
- Modify: `Sources/ServiceApp/AppDIContainer.swift` (기존 컨테이너에 팩토리 추가 — 파일 열어 기존 패턴을 따라 아래 프로퍼티를 추가한다)
- Test: `Tests/SharedTests/IntegrationScenarioTests.swift`

**Interfaces:**
- Consumes: Task 1~8 전부
- Produces: `AppDIContainer`에 `habitRepository: HabitRepository`, `trackingRepository: TrackingRepository`, `checkInService: CheckInServicing` 프로퍼티 (lazy 조립, `AppModelContainer.make(inMemory: false)`)

- [ ] **Step 1: 통합 시나리오 테스트 작성**

`Tests/SharedTests/IntegrationScenarioTests.swift`:

```swift
import Foundation
import Testing
@testable import Shared

/// PRD 코어 루프 시나리오: 7일 마무리 → 프리즈 적립 → 2일 공백 → 프리즈 소모 → 리셋 → 자산 보존
struct IntegrationScenarioTests {
    let cal = Calendar(identifier: .gregorian)

    @Test func 코어루프_엔드투엔드() async throws {
        let container = try AppModelContainer.make(inMemory: true)
        let habits = SwiftDataHabitRepository(modelContainer: container)
        let tracking = SwiftDataTrackingRepository(modelContainer: container)
        let service = CheckInService(habitRepository: habits, trackingRepository: tracking,
                                     currency: AppCurrency(code: "KRW"), calendar: cal)

        func at(_ day: Int, hour: Int = 21) -> Date {
            cal.date(from: DateComponents(year: 2026, month: 7, day: day, hour: hour))!
        }
        let start = DayStamp(year: 2026, month: 7, day: 1)
        try await habits.save(Habit(id: UUID(), name: "담배", icon: "cigarette",
                                    colorHex: "D4B15F", rate: .money(3000),
                                    createdDay: start, firstTrackedDay: start))

        // 7/1 ~ 7/7 매일 마무리 → 스트릭 7, 프리즈 1개 적립
        var lastStreak = StreakState()
        for d in 1...7 {
            let r = try await service.closeToday(lapsedHabitIDs: [], now: at(d))
            lastStreak = r.streak
        }
        #expect(lastStreak.current == 7)
        #expect(lastStreak.freezes == 1)

        // 7/8·7/9 공백 후 7/10 접속 → 7/8은 프리즈 소모, 7/9(어제)는 소급 대기
        let decision = try await service.refresh(now: at(10, hour: 9))
        #expect(decision.freezeFills == [DayStamp(year: 2026, month: 7, day: 8)])
        #expect(decision.yesterdayOpenForBackfill)
        #expect(decision.state.freezes == 0)
        #expect(!decision.didReset)

        // 어제(7/9) 소급 → 스트릭 사슬 복구: 7일 + 프리즈 1 + 소급 1 = 9
        let habit = try await habits.habits(includeArchived: false)[0]
        let backfill = try await service.closeYesterday(answers: [habit.id: .resisted],
                                                        now: at(10, hour: 9, minute: 30))
        #expect(backfill.streak.current == 9)

        // 7/10 마무리 → 10일
        let r10 = try await service.closeToday(lapsedHabitIDs: [habit.id], now: at(10))
        #expect(r10.streak.current == 10)
        #expect(r10.newBadges.contains(.checkinStreak(days: 7)))

        // 7/11~7/14 나흘 방치 → 7/15 접속: 공백 4일(소급 1 제외해도 3일) > 프리즈 0 → 리셋
        let after = try await service.refresh(now: at(15, hour: 9))
        #expect(after.didReset)
        #expect(after.state.current == 0)
        #expect(after.state.best == 10)    // 최고 기록 보존

        // 누적 자산은 리셋과 무관 (PRD 원칙 4) — 7/10 무너짐 1회만 빠진다
        let marks = try await tracking.marks(habitID: habit.id)
        let today15 = DayStamp(year: 2026, month: 7, day: 15)
        let p = ProgressCalculator.progress(for: habit, marks: marks, today: today15, calendar: cal)
        #expect(p.totalCleanDays == 14)    // 7/1~7/15 15일 중 무너짐 1일 제외
        #expect(p.saved == .money(42000))
    }
}
```

`at(_:hour:minute:)`가 필요하므로 테스트 헬퍼 시그니처를 다음으로 작성한다:

```swift
        func at(_ day: Int, hour: Int = 21, minute: Int = 0) -> Date {
            cal.date(from: DateComponents(year: 2026, month: 7, day: day,
                                          hour: hour, minute: minute))!
        }
```

- [ ] **Step 2: 실행 — 실패 시 엔진·서비스 수정**

Run: `tuist test Shared`
Expected: PASS. 실패하면 이 시나리오가 명세의 기준이다 — 시나리오를 바꾸지 말고 엔진을 고친다.

- [ ] **Step 3: AppDIContainer 배선**

`Sources/ServiceApp/AppDIContainer.swift`를 열어 기존 프로퍼티 패턴대로 추가한다 (기존 코드 구조 유지 — 프로토콜이 있으면 프로토콜에도 요구사항 추가):

```swift
    // MARK: - 잉걸 도메인 (Plan 1)

    private let modelContainer: ModelContainer = {
        do {
            return try AppModelContainer.make(inMemory: false)
        } catch {
            fatalError("SwiftData 컨테이너 초기화 실패: \(error)")
        }
    }()

    lazy var habitRepository: HabitRepository =
        SwiftDataHabitRepository(modelContainer: modelContainer)

    lazy var trackingRepository: TrackingRepository =
        SwiftDataTrackingRepository(modelContainer: modelContainer)

    lazy var checkInService: CheckInServicing =
        CheckInService(habitRepository: habitRepository,
                       trackingRepository: trackingRepository,
                       currency: AppCurrency.default(for: .current))
```

필요 import: `import SwiftData`, `import Shared`.

- [ ] **Step 4: 전체 빌드 + 테스트**

Run: `tuist generate --no-open && tuist test Shared && tuist build`
Expected: 테스트 전체 PASS, 앱 빌드 성공

- [ ] **Step 5: Commit**

```bash
git add Sources/ServiceApp/AppDIContainer.swift Tests/SharedTests/IntegrationScenarioTests.swift
git commit -m "feat: 도메인 코어 DI 배선 + 코어 루프 통합 시나리오"
```

---

## Self-Review 결과

- **커버리지**: PRD §3 용어(DayStamp·DayClose·마크), §4.1-4.3(마무리 1회·소급·프리즈·리셋·즉시기록), §5.1-5.3(습관 속성·관대 모델 진도·프리셋), §6.2-6.3(앱 통화·통화별 테이블), §7(배지 4계열·회수 없음), §11 도메인 관련 엣지(추가 당일/마감 후 추가/보관/삭제/0개 일시정지/데이터 초기화/미래 기록은 DayBoundary가 현재 시각 기준이라 API 표면상 불가) 모두 태스크에 매핑됨.
- **다음 플랜으로 미룬 것**: 기록 수정 UI(오늘·어제 — `CheckInError.notEditable`은 선언만, 수정 API는 Plan 3 캘린더 팝오버에서), 알림·온보딩·위젯 스냅샷(Plan 4), 통화 변경 안내 플로우(Plan 3 설정).
- **타입 일관성**: `StreakDecision.state`(Task 3) ↔ CheckInService(Task 8), `Habit.Rate`(Task 2) ↔ PresetCatalog(Task 7) 시그니처 일치 확인.
