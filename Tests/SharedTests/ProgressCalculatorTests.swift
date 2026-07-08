import Foundation
import Testing
@testable import Shared

struct ProgressCalculatorTests {
    let cal = Calendar(identifier: .gregorian)
    let today = DayStamp(year: 2026, month: 7, day: 8)

    func habit(rate: Habit.Rate = .money(3000), createdDaysAgo: Int) -> Habit {
        let created = today.advanced(by: -createdDaysAgo, calendar: cal)
        return Habit(id: UUID(), name: "담배", icon: "cigarette", colorHex: "D4B15F",
                     rate: rate, createdDay: created, firstTrackedDay: created)
    }

    func lapse(_ h: Habit, daysAgo: Int) -> HabitDayMark {
        HabitDayMark(habitID: h.id, day: today.advanced(by: -daysAgo, calendar: cal),
                     kind: .lapsed(source: .immediate))
    }

    @Test func 무너짐없으면_전체가_절제일이다() {
        let h = habit(createdDaysAgo: 9)   // 10일째 추적 (등록일 포함)
        let p = ProgressCalculator.progress(for: h, marks: [], today: today, calendar: cal)
        #expect(p.totalCleanDays == 10)
        #expect(p.currentRun == 10)
        #expect(p.bestRun == 10)
        #expect(p.saved == .money(30000))
    }

    @Test func 미기록일은_절제일에_포함된다_관대모델() {
        let h = habit(createdDaysAgo: 9)
        let unknown = HabitDayMark(habitID: h.id, day: today.advanced(by: -3, calendar: cal), kind: .unknown)
        let p = ProgressCalculator.progress(for: h, marks: [unknown], today: today, calendar: cal)
        #expect(p.totalCleanDays == 10)   // unknown은 무너짐이 아니다 (PRD §5.2)
        #expect(p.currentRun == 10)       // 미기록일은 연속을 끊지 않는다
    }

    @Test func 무너진날은_빠지고_연속이_끊긴다() {
        let h = habit(createdDaysAgo: 9)
        let p = ProgressCalculator.progress(for: h, marks: [lapse(h, daysAgo: 3)],
                                            today: today, calendar: cal)
        #expect(p.totalCleanDays == 9)
        #expect(p.currentRun == 3)   // 무너짐 다음 날 ~ 오늘 (PRD §5.2)
        #expect(p.bestRun == 6)      // 등록일 ~ 무너짐 전날
    }

    @Test func 시간단가는_분으로_적립된다() {
        let h = habit(rate: .time(minutes: 60), createdDaysAgo: 9)
        let p = ProgressCalculator.progress(for: h, marks: [], today: today, calendar: cal)
        #expect(p.saved == .time(minutes: 600))
    }

    @Test func 독서환산_2분1페이지_300페이지1권() {
        #expect(ReadingConversion.pages(fromMinutes: 60) == 30)
        #expect(ReadingConversion.books(fromMinutes: 600) == 1)
        #expect(ReadingConversion.books(fromMinutes: 599) == 0)
    }
}
