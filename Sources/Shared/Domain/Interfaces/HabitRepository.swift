import Foundation

public protocol HabitRepository: Sendable {
    func habits(includeArchived: Bool) async throws -> [Habit]
    func activeHabits(on day: DayStamp) async throws -> [Habit]
    func save(_ habit: Habit) async throws            // upsert
    func archive(id: UUID, on day: DayStamp) async throws
    func unarchive(id: UUID) async throws
    func delete(id: UUID) async throws                // 기록 포함 영구 삭제 (PRD §11)
}
