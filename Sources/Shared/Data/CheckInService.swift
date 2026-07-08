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
