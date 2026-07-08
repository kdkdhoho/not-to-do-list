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
