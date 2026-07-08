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
