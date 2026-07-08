import Foundation
import Testing
@testable import Shared

/// PRD 코어 루프 시나리오: 7일 마무리 → 프리즈 적립 → 2일 공백 → 프리즈 소모 → 리셋 → 자산 보존
struct IntegrationScenarioTests {
    let cal = Calendar(identifier: .gregorian)

    @Test func 코어루프_엔드투엔드() async throws {
        let container = try AppModelContainer.make(inMemory: true)
        let habits = SwiftDataHabitRepository(modelContainer: container)
        let tracking = SwiftDataTrackingRepository(modelContainer: container)
        let service = CheckInService(habitRepository: habits, trackingRepository: tracking,
                                     currency: AppCurrency(code: "KRW"), calendar: cal)

        func at(_ day: Int, hour: Int = 21, minute: Int = 0) -> Date {
            cal.date(from: DateComponents(year: 2026, month: 7, day: day,
                                          hour: hour, minute: minute))!
        }
        let start = DayStamp(year: 2026, month: 7, day: 1)
        try await habits.save(Habit(id: UUID(), name: "담배", icon: "cigarette",
                                    colorHex: "D4B15F", rate: .money(3000),
                                    createdDay: start, firstTrackedDay: start))

        // 7/1 ~ 7/7 매일 마무리 → 스트릭 7, 프리즈 1개 적립
        // 배지는 마일스톤 도달 즉시(마감 완료 직후) 1회만 판정되고 회수되지 않는다 (PRD §7).
        // 스트릭이 7에 처음 도달하는 이 시점에 checkinStreak(7) 배지가 여기서 발급된다.
        var lastStreak = StreakState()
        var day7Badges: [BadgeKind] = []
        for d in 1...7 {
            let r = try await service.closeToday(lapsedHabitIDs: [], now: at(d))
            lastStreak = r.streak
            if d == 7 { day7Badges = r.newBadges }
        }
        #expect(lastStreak.current == 7)
        #expect(lastStreak.freezes == 1)
        #expect(day7Badges.contains(.checkinStreak(days: 7)))

        // 7/8·7/9 공백 후 7/10 접속 → 7/8은 프리즈 소모, 7/9(어제)는 소급 대기
        let decision = try await service.refresh(now: at(10, hour: 9))
        #expect(decision.freezeFills == [DayStamp(year: 2026, month: 7, day: 8)])
        #expect(decision.yesterdayOpenForBackfill)
        #expect(decision.state.freezes == 0)
        #expect(!decision.didReset)

        // 어제(7/9) 소급 → 스트릭 사슬 복구: 7일 + 프리즈 1 + 소급 1 = 9
        let habit = try await habits.habits(includeArchived: false)[0]
        let backfill = try await service.closeYesterday(answers: [habit.id: .resisted],
                                                        now: at(10, hour: 9, minute: 30))
        #expect(backfill.streak.current == 9)

        // 7/10 마무리 → 10일. 7일 배지는 7/7에 이미 발급됐으므로 재발급되지 않는다 (PRD §7 회수·재발급 없음)
        let r10 = try await service.closeToday(lapsedHabitIDs: [habit.id], now: at(10))
        #expect(r10.streak.current == 10)
        #expect(!r10.newBadges.contains(.checkinStreak(days: 7)))

        // 7/11~7/14 나흘 방치 → 7/15 접속: 공백 4일(소급 1 제외해도 3일) > 프리즈 0 → 리셋
        let after = try await service.refresh(now: at(15, hour: 9))
        #expect(after.didReset)
        #expect(after.state.current == 0)
        #expect(after.state.best == 10)    // 최고 기록 보존

        // 누적 자산은 리셋과 무관 (PRD 원칙 4) — 7/10 무너짐 1회만 빠진다
        let marks = try await tracking.marks(habitID: habit.id)
        let today15 = DayStamp(year: 2026, month: 7, day: 15)
        let p = ProgressCalculator.progress(for: habit, marks: marks, today: today15, calendar: cal)
        #expect(p.totalCleanDays == 14)    // 7/1~7/15 15일 중 무너짐 1일 제외
        #expect(p.saved == .money(42000))
    }
}
