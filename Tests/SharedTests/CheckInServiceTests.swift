import Foundation
import Testing
@testable import Shared

struct CheckInServiceTests {
    let cal = Calendar(identifier: .gregorian)

    func fixture() throws -> (CheckInService, HabitRepository, TrackingRepository) {
        let container = try AppModelContainer.make(inMemory: true)
        let habits = SwiftDataHabitRepository(modelContainer: container)
        let tracking = SwiftDataTrackingRepository(modelContainer: container)
        let service = CheckInService(habitRepository: habits, trackingRepository: tracking,
                                     currency: AppCurrency(code: "KRW"), calendar: cal)
        return (service, habits, tracking)
    }

    /// 2026-07-08 21:00 로컬
    var now: Date { cal.date(from: DateComponents(year: 2026, month: 7, day: 8, hour: 21))! }
    var today: DayStamp { DayBoundary.dayStamp(for: now, calendar: cal) }

    func addHabit(_ repo: HabitRepository, daysAgo: Int = 10) async throws -> Habit {
        let created = today.advanced(by: -daysAgo, calendar: cal)
        let h = Habit(id: UUID(), name: "담배", icon: "cigarette", colorHex: "D4B15F",
                      rate: .money(3000), createdDay: created, firstTrackedDay: created)
        try await repo.save(h)
        return h
    }

    @Test func 마무리하면_스트릭이_오르고_모든_활성습관이_참은것으로_확정된다() async throws {
        let (service, habits, tracking) = try fixture()
        let h = try await addHabit(habits)
        let result = try await service.closeToday(lapsedHabitIDs: [], now: now)
        #expect(result.close.day == today && result.close.kind == .sameDay)
        #expect(result.streak.current == 1)
        // 마크 없음 + 마무리됨 = 참았다 (이진 모델)
        #expect(try await tracking.marks(habitID: h.id).isEmpty)
    }

    @Test func 같은날_두번_마무리는_거부된다() async throws {
        let (service, habits, _) = try fixture()
        _ = try await addHabit(habits)
        _ = try await service.closeToday(lapsedHabitIDs: [], now: now)
        await #expect(throws: CheckInError.alreadyClosed) {
            _ = try await service.closeToday(lapsedHabitIDs: [], now: now)
        }
    }

    @Test func 습관0개면_마무리_불가() async throws {
        let (service, _, _) = try fixture()
        await #expect(throws: CheckInError.noActiveHabits) {
            _ = try await service.closeToday(lapsedHabitIDs: [], now: now)
        }
    }

    @Test func 무너진_습관은_atClose_마크가_남고_스트릭은_유지된다() async throws {
        let (service, habits, tracking) = try fixture()
        let h = try await addHabit(habits)
        let result = try await service.closeToday(lapsedHabitIDs: [h.id], now: now)
        let marks = try await tracking.marks(habitID: h.id)
        #expect(marks.count == 1)
        #expect(marks[0].kind == .lapsed(source: .atClose))
        #expect(result.streak.current == 1)   // 무너져도 기록하면 스트릭 유지 (PRD 원칙)
    }

    @Test func 즉시기록은_마무리에_자동반영되고_중복마크되지_않는다() async throws {
        let (service, habits, tracking) = try fixture()
        let h = try await addHabit(habits)
        try await service.recordImmediateLapse(habitID: h.id, memo: "회식", now: now)
        _ = try await service.closeToday(lapsedHabitIDs: [h.id], now: now)
        let marks = try await tracking.marks(habitID: h.id)
        #expect(marks.count == 1)
        #expect(marks[0].kind == .lapsed(source: .immediate))   // 즉시 기록이 우선
        #expect(marks[0].memo == "회식")
    }

    @Test func 어제소급은_backfill로_마무리되고_기억안남은_unknown_마크() async throws {
        let (service, habits, tracking) = try fixture()
        let h = try await addHabit(habits)
        let result = try await service.closeYesterday(answers: [h.id: .unknown], now: now)
        #expect(result.close.kind == .backfill)
        #expect(result.close.day == today.advanced(by: -1, calendar: cal))
        let marks = try await tracking.marks(habitID: h.id)
        #expect(marks.count == 1 && marks[0].kind == .unknown)
    }

    @Test func 어제가_이미_마무리됐으면_소급_거부() async throws {
        let (service, habits, _) = try fixture()
        let h = try await addHabit(habits)
        _ = try await service.closeYesterday(answers: [h.id: .resisted], now: now)
        await #expect(throws: CheckInError.alreadyClosed) {
            _ = try await service.closeYesterday(answers: [h.id: .resisted], now: now)
        }
    }

    @Test func 새벽1시_마무리는_전날로_귀속된다() async throws {
        let (service, habits, tracking) = try fixture()
        _ = try await addHabit(habits)
        let lateNight = cal.date(from: DateComponents(year: 2026, month: 7, day: 9, hour: 1))!
        _ = try await service.closeToday(lapsedHabitIDs: [], now: lateNight)
        #expect(try await tracking.close(on: today) != nil)   // 7/8로 귀속
    }

    @Test func 마무리후_추가한_습관은_오늘_마크대상이_아니다() async throws {
        let (service, habits, _) = try fixture()
        _ = try await addHabit(habits)
        _ = try await service.closeToday(lapsedHabitIDs: [], now: now)
        // 마무리 후 추가 → firstTrackedDay는 내일 (Plan 2의 습관 추가 플로우가 이 규칙으로 생성)
        let late = Habit(id: UUID(), name: "야식", icon: "drumstick", colorHex: "A8B36A",
                         rate: .money(20000), createdDay: today,
                         firstTrackedDay: today.advanced(by: 1, calendar: cal))
        try await habits.save(late)
        #expect(try await habits.activeHabits(on: today).count == 1)
    }

    @Test func 배지는_마무리직후_일괄판정된다() async throws {
        let (service, habits, _) = try fixture()
        _ = try await addHabit(habits, daysAgo: 30)
        let result = try await service.closeToday(lapsedHabitIDs: [], now: now)
        // 첫 마무리: 스트릭 1 → 스트릭 배지 없음. 관대 모델 절제 31일 → habitRun 7·30 획득
        #expect(result.newBadges.contains(.habitRun(days: 30)))
        #expect(!result.newBadges.contains(.checkinStreak(days: 3)))
        // 아낀 돈 31×3000=93,000 → 1만·5만 달성
        #expect(result.newBadges.contains(.moneySaved(milestone: 50000)))
    }
}
