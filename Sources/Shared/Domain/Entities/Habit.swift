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
