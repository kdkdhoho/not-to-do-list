import Foundation

public struct StreakInput: Sendable {
    public var today: DayStamp
    public var closedDays: [DayStamp: DayClose.Kind]
    /// 활성 습관이 0개였던 날 — 마무리 불가, 스트릭 일시정지 (PRD §11)
    public var pausedDays: Set<DayStamp>
    public var state: StreakState

    public init(today: DayStamp, closedDays: [DayStamp: DayClose.Kind],
                pausedDays: Set<DayStamp>, state: StreakState) {
        self.today = today
        self.closedDays = closedDays
        self.pausedDays = pausedDays
        self.state = state
    }
}

public struct StreakDecision: Equatable, Sendable {
    /// 프리즈로 자동 마무리 처리할 날 (DayClose(kind: .freeze) 저장 대상)
    public var freezeFills: [DayStamp]
    public var didReset: Bool
    public var state: StreakState
    /// 어제가 미마무리 상태로 남아 있어 소급 확인 카드를 띄워야 하는가
    public var yesterdayOpenForBackfill: Bool
}

public enum StreakEngine {
    public static let freezeAccrualPeriod = 7
    public static let maxFreezes = 2

    /// 앱 진입·마무리 직후 호출. 공백을 판정해 프리즈 소모/리셋을 결정하고 현재 스트릭을 재계산한다.
    /// - 어제 공백은 소급 기회가 남아 있으므로 프리즈를 소모하지 않는다 (PRD §4.2 소급 규칙 우선).
    /// - 그제 이전의 공백일(일시정지일 제외)에 오래된 날부터 프리즈를 1개씩 소모한다.
    public static func evaluate(_ input: StreakInput, calendar: Calendar = .current) -> StreakDecision {
        var state = input.state
        let yesterday = input.today.advanced(by: -1, calendar: calendar)
        let yesterdayOpen = input.closedDays[yesterday] == nil && !input.pausedDays.contains(yesterday)

        // 1. 그제 이전의 공백 수집: 마지막 마무리일부터 그제까지
        var gaps: [DayStamp] = []
        var cursor = input.today.advanced(by: -2, calendar: calendar)
        while input.closedDays[cursor] == nil {
            if !input.pausedDays.contains(cursor) { gaps.append(cursor) }
            cursor = cursor.advanced(by: -1, calendar: calendar)
            // 마무리 기록이 하나도 없는 신규 사용자: 스트릭 0이면 공백 개념이 없다
            if state.current == 0 && gaps.count > Self.maxFreezes { break }
            if gaps.count > Self.maxFreezes { break }  // 이미 리셋 확정
        }
        gaps.sort()

        // 2. 프리즈 소모 또는 리셋
        var fills: [DayStamp] = []
        var didReset = false
        if state.current > 0 {
            if gaps.count <= state.freezes {
                fills = gaps
                state.freezes -= gaps.count
            } else {
                didReset = true
                state.current = 0
                state.freezeAccrual = 0   // 보유 프리즈는 유지, 카운터만 리셋 (PRD §4.3)
            }
        }

        // 3. 스트릭 재계산: 오늘 또는 어제(소급 대기 포함)에 닿는 연속 마무리 사슬
        if !didReset {
            var closed = input.closedDays
            for f in fills { closed[f] = .freeze }
            var count = 0
            var day = closed[input.today] != nil ? input.today : yesterday
            if closed[day] == nil && !input.pausedDays.contains(day) {
                day = day.advanced(by: -1, calendar: calendar)  // 어제 소급 대기 중이면 그제부터 센다
            }
            while true {
                if closed[day] != nil {
                    count += 1
                } else if !input.pausedDays.contains(day) {
                    break  // 일시정지일은 세지 않고 건너뛴다
                }
                day = day.advanced(by: -1, calendar: calendar)
            }
            state.current = count
            state.best = max(state.best, count)
        }

        return StreakDecision(freezeFills: fills, didReset: didReset,
                              state: state, yesterdayOpenForBackfill: yesterdayOpen)
    }

    /// 사용자 마무리(당일·소급) 직후 적립 카운터를 진행시킨다. 프리즈 자동 메움은 적립되지 않는다.
    public static func accrueAfterClose(_ state: StreakState) -> StreakState {
        var s = state
        s.freezeAccrual += 1
        if s.freezeAccrual >= Self.freezeAccrualPeriod {
            s.freezeAccrual = 0
            if s.freezes < Self.maxFreezes { s.freezes += 1 }
        }
        return s
    }
}
