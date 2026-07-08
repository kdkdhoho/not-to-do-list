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
