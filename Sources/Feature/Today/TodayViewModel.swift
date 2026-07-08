import Foundation
import Observation
import Shared

@Observable
@MainActor
public final class TodayViewModel {
    public struct HabitRow: Identifiable, Equatable, Sendable {
        public let id: UUID
        public let name: String
        public let icon: String
        public let colorHex: String
        public let dPlusText: String
        public let subtitle: String
        public let lapsedToday: Bool
    }

    public private(set) var streakDays = 0
    public private(set) var freezeCount = 0
    public private(set) var isClosedToday = false
    public private(set) var showYesterdayCard = false
    public private(set) var habitRows: [HabitRow] = []
    public private(set) var lastCloseResult: CloseResult?

    private let checkInService: CheckInServicing
    private let habitRepository: HabitRepository
    private let trackingRepository: TrackingRepository
    private let currency: AppCurrency
    private let calendar: Calendar

    public init(checkInService: CheckInServicing, habitRepository: HabitRepository,
                trackingRepository: TrackingRepository, currency: AppCurrency,
                calendar: Calendar = .current) {
        self.checkInService = checkInService
        self.habitRepository = habitRepository
        self.trackingRepository = trackingRepository
        self.currency = currency
        self.calendar = calendar
    }

    public func refresh(now: Date = .now) async {
        do {
            let decision = try await checkInService.refresh(now: now)
            streakDays = decision.state.current
            freezeCount = decision.state.freezes
            let today = DayBoundary.dayStamp(for: now, calendar: calendar)
            isClosedToday = try await trackingRepository.close(on: today) != nil
            showYesterdayCard = decision.yesterdayOpenForBackfill
                ? !(try await activeYesterday(now: now).isEmpty)
                : false
            habitRows = try await buildRows(today: today)
        } catch {
            // 로드 실패 시 상태 유지 — 빈 화면 튐 방지
        }
    }

    public func closeToday(lapsedHabitIDs: Set<UUID>, now: Date = .now) async {
        do {
            lastCloseResult = try await checkInService.closeToday(lapsedHabitIDs: lapsedHabitIDs, now: now)
        } catch {
            lastCloseResult = nil
        }
        await refresh(now: now)
    }

    public func answerYesterday(_ answer: YesterdayAnswer, now: Date = .now) async {
        do {
            let habits = try await activeYesterday(now: now)
            let answers = Dictionary(uniqueKeysWithValues: habits.map { ($0.id, answer) })
            _ = try await checkInService.closeYesterday(answers: answers, now: now)
        } catch {}
        await refresh(now: now)
    }

    public func recordLapse(habitID: UUID, memo: String?, now: Date = .now) async {
        do {
            let trimmed = memo?.trimmingCharacters(in: .whitespacesAndNewlines)
            try await checkInService.recordImmediateLapse(
                habitID: habitID, memo: (trimmed?.isEmpty ?? true) ? nil : trimmed, now: now)
        } catch {}
        await refresh(now: now)
    }

    // MARK: - Private

    private func activeYesterday(now: Date) async throws -> [Habit] {
        let yesterday = DayBoundary.dayStamp(for: now, calendar: calendar).advanced(by: -1, calendar: calendar)
        return try await habitRepository.activeHabits(on: yesterday)
    }

    private func buildRows(today: DayStamp) async throws -> [HabitRow] {
        let habits = try await habitRepository.activeHabits(on: today)
        let todayMarks = try await trackingRepository.marks(in: today...today)
        let lapsedTodayIDs = Set(todayMarks.compactMap { mark -> UUID? in
            if case .lapsed = mark.kind { return mark.habitID }
            return nil
        })
        var rows: [HabitRow] = []
        for habit in habits {
            let marks = try await trackingRepository.marks(habitID: habit.id)
            let progress = ProgressCalculator.progress(for: habit, marks: marks,
                                                       today: today, calendar: calendar)
            rows.append(HabitRow(
                id: habit.id, name: habit.name, icon: habit.icon, colorHex: habit.colorHex,
                dPlusText: AppStrings.Today.dPlus(progress.currentRun),
                subtitle: subtitle(for: progress.saved),
                lapsedToday: lapsedTodayIDs.contains(habit.id)))
        }
        return rows
    }

    private func subtitle(for saved: SavedAmount) -> String {
        switch saved {
        case .money(let amount):
            let formatted = amount.formatted(.currency(code: currency.code))
            return AppStrings.Today.savedMoney(formatted)
        case .time(let minutes):
            let books = ReadingConversion.books(fromMinutes: minutes)
            if books >= 1 { return AppStrings.Today.savedBooks(books) }
            return AppStrings.Today.savedPages(ReadingConversion.pages(fromMinutes: minutes))
        case .none:
            return ""
        }
    }
}
