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
