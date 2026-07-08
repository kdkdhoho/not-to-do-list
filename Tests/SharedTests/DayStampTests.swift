import Foundation
import Testing
@testable import Shared

struct DayStampTests {
    let cal = Calendar(identifier: .gregorian)

    func date(_ y: Int, _ mo: Int, _ d: Int, _ h: Int, _ mi: Int = 0) -> Date {
        cal.date(from: DateComponents(year: y, month: mo, day: d, hour: h, minute: mi))!
    }

    @Test func 새벽1시는_전날로_귀속된다() {
        let stamp = DayBoundary.dayStamp(for: date(2026, 7, 8, 1, 30), calendar: cal)
        #expect(stamp == DayStamp(year: 2026, month: 7, day: 7))
    }

    @Test func 새벽4시부터_당일이다() {
        #expect(DayBoundary.dayStamp(for: date(2026, 7, 8, 4, 0), calendar: cal)
                == DayStamp(year: 2026, month: 7, day: 8))
        #expect(DayBoundary.dayStamp(for: date(2026, 7, 8, 3, 59), calendar: cal)
                == DayStamp(year: 2026, month: 7, day: 7))
    }

    @Test func 자정직전은_당일이다() {
        #expect(DayBoundary.dayStamp(for: date(2026, 7, 8, 23, 59), calendar: cal)
                == DayStamp(year: 2026, month: 7, day: 8))
    }

    @Test func advanced와_distance는_역연산이다() {
        let d = DayStamp(year: 2026, month: 7, day: 8)
        let next = d.advanced(by: 1, calendar: cal)
        #expect(next == DayStamp(year: 2026, month: 7, day: 9))
        #expect(d.distance(to: next, calendar: cal) == 1)
        #expect(d.advanced(by: -8, calendar: cal) == DayStamp(year: 2026, month: 6, day: 30))
    }

    @Test func 비교연산() {
        #expect(DayStamp(year: 2026, month: 7, day: 7) < DayStamp(year: 2026, month: 7, day: 8))
        #expect(DayStamp(year: 2025, month: 12, day: 31) < DayStamp(year: 2026, month: 1, day: 1))
    }
}
