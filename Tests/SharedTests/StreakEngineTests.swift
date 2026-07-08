import Foundation
import Testing
@testable import Shared

struct StreakEngineTests {
    let cal = Calendar(identifier: .gregorian)
    let today = DayStamp(year: 2026, month: 7, day: 8)

    /// n일 전부터 어제까지 연속 sameDay 마무리
    func closes(daysBack: Int, until offset: Int = -1) -> [DayStamp: DayClose.Kind] {
        var map: [DayStamp: DayClose.Kind] = [:]
        for i in stride(from: -daysBack, through: offset, by: 1) {
            map[today.advanced(by: i, calendar: cal)] = .sameDay
        }
        return map
    }

    @Test func 연속마무리는_스트릭이_이어진다() {
        let input = StreakInput(today: today, closedDays: closes(daysBack: 23),
                                pausedDays: [], state: StreakState(current: 23, best: 23))
        let d = StreakEngine.evaluate(input, calendar: cal)
        #expect(!d.didReset)
        #expect(d.freezeFills.isEmpty)
        #expect(d.state.current == 23)
        #expect(d.yesterdayOpenForBackfill == false)  // 어제 마무리됨
    }

    @Test func 어제_공백은_프리즈를_쓰지_않고_소급대상으로_남긴다() {
        var map = closes(daysBack: 10, until: -2)   // 그제까지 마무리, 어제 공백
        map[today] = nil
        let input = StreakInput(today: today, closedDays: map,
                                pausedDays: [], state: StreakState(current: 9, best: 9, freezes: 2))
        let d = StreakEngine.evaluate(input, calendar: cal)
        #expect(d.freezeFills.isEmpty)
        #expect(d.yesterdayOpenForBackfill == true)
        #expect(!d.didReset)
    }

    @Test func 그제_공백은_프리즈로_자동_메운다() {
        var map = closes(daysBack: 10, until: -3)   // 3일 전까지 마무리
        map[today.advanced(by: -1, calendar: cal)] = .sameDay  // 어제는 마무리됨
        let input = StreakInput(today: today, closedDays: map,
                                pausedDays: [], state: StreakState(current: 8, best: 8, freezes: 2))
        let d = StreakEngine.evaluate(input, calendar: cal)
        #expect(d.freezeFills == [today.advanced(by: -2, calendar: cal)])
        #expect(d.state.freezes == 1)
        #expect(!d.didReset)
    }

    @Test func 프리즈가_모자라면_리셋된다_최고기록은_보존() {
        let map = closes(daysBack: 10, until: -5)   // 어제 제외 3일 공백(그제·3일전·4일전)
        let input = StreakInput(today: today, closedDays: map,
                                pausedDays: [], state: StreakState(current: 6, best: 15, freezes: 2))
        let d = StreakEngine.evaluate(input, calendar: cal)
        #expect(d.didReset)
        #expect(d.state.current == 0)
        #expect(d.state.best == 15)          // 최고 기록 영구 보존 (PRD §4.3)
        #expect(d.state.freezes == 2)        // 리셋 시 보유 프리즈는 유지
        #expect(d.state.freezeAccrual == 0)  // 적립 카운터만 리셋
    }

    @Test func 습관0개인_날은_스트릭을_끊지_않고_일시정지한다() {
        var map = closes(daysBack: 10, until: -4)
        map[today.advanced(by: -1, calendar: cal)] = .sameDay
        let paused: Set<DayStamp> = [today.advanced(by: -2, calendar: cal),
                                     today.advanced(by: -3, calendar: cal)]
        let input = StreakInput(today: today, closedDays: map,
                                pausedDays: paused, state: StreakState(current: 7, best: 7, freezes: 0))
        let d = StreakEngine.evaluate(input, calendar: cal)
        #expect(!d.didReset)
        #expect(d.freezeFills.isEmpty)       // 일시정지일은 공백이 아니다 (PRD §11)
    }

    @Test func 신규_스트릭_초기_며칠은_기록이전_날짜를_공백으로_보지_않는다() {
        // 어제 하루만 마무리된 갓 시작한 스트릭 — closedDays엔 그 이전 날짜가 아예 없다.
        // 스캔이 history 시작 이전까지 무한정 내려가 가짜 공백을 셌던 회귀 버그의 재현.
        let input = StreakInput(today: today, closedDays: [today.advanced(by: -1, calendar: cal): .sameDay],
                                pausedDays: [], state: StreakState(current: 1, best: 1))
        let d = StreakEngine.evaluate(input, calendar: cal)
        #expect(!d.didReset)
        #expect(d.freezeFills.isEmpty)
        #expect(d.state.current == 1)   // 어제 1일치 마무리만 반영 — 이전 히스토리가 없다고 리셋되지 않는다
    }

    @Test func 적립은_7일마다_1개_최대2개() {
        var s = StreakState(current: 6, best: 6, freezes: 0, freezeAccrual: 6)
        s = StreakEngine.accrueAfterClose(s)   // 7일째 마무리
        #expect(s.freezes == 1 && s.freezeAccrual == 0)

        var full = StreakState(current: 20, best: 20, freezes: 2, freezeAccrual: 6)
        full = StreakEngine.accrueAfterClose(full)
        #expect(full.freezes == 2 && full.freezeAccrual == 0)  // 최대 보유 초과분은 버린다
    }
}
