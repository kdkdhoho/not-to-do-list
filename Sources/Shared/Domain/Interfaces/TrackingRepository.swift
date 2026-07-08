import Foundation

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
