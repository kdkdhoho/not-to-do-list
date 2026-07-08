import Foundation

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
