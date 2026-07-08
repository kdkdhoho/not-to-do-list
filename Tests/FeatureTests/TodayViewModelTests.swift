import Foundation
import Testing
import Shared
@testable import Feature

@MainActor
struct TodayViewModelTests {
    let cal = Calendar(identifier: .gregorian)

    func fixture() throws -> (TodayViewModel, HabitRepository, CheckInServicing) {
        let container = try AppModelContainer.make(inMemory: true)
        let habits = SwiftDataHabitRepository(modelContainer: container)
        let tracking = SwiftDataTrackingRepository(modelContainer: container)
        let service = CheckInService(habitRepository: habits, trackingRepository: tracking,
                                     currency: AppCurrency(code: "KRW"), calendar: cal)
        let vm = TodayViewModel(checkInService: service, habitRepository: habits,
                                trackingRepository: tracking,
                                currency: AppCurrency(code: "KRW"), calendar: cal)
        return (vm, habits, service)
    }

    var now: Date { cal.date(from: DateComponents(year: 2026, month: 7, day: 8, hour: 21))! }
    var today: DayStamp { DayBoundary.dayStamp(for: now, calendar: cal) }

    func seedHabit(_ repo: HabitRepository, rate: Habit.Rate = .money(3000),
                   daysAgo: Int = 9) async throws -> Habit {
        let created = today.advanced(by: -daysAgo, calendar: cal)
        let h = Habit(id: UUID(), name: "담배", icon: "smoke", colorHex: "D4B15F",
                      rate: rate, createdDay: created, firstTrackedDay: created)
        try await repo.save(h)
        return h
    }

    @Test func 리프레시가_스트릭과_습관행을_조립한다() async throws {
        let (vm, habits, _) = try fixture()
        _ = try await seedHabit(habits)
        await vm.refresh(now: now)
        #expect(vm.habitRows.count == 1)
        #expect(vm.habitRows[0].dPlusText == "D+10")           // 관대 모델: 등록일 포함 10일
        #expect(vm.habitRows[0].subtitle.contains("30,000"))   // 10일 × 3,000 포맷 포함
        #expect(vm.isClosedToday == false)
        #expect(vm.streakDays == 0)
    }

    @Test func 시간단가는_독서환산_서브타이틀() async throws {
        let (vm, habits, _) = try fixture()
        _ = try await seedHabit(habits, rate: .time(minutes: 60), daysAgo: 19)   // 20일×60분=1200분=책2권
        await vm.refresh(now: now)
        #expect(vm.habitRows[0].subtitle == AppStrings.Today.savedBooks(2))
    }

    @Test func 마무리하면_상태가_닫힘으로_바뀐다() async throws {
        let (vm, habits, _) = try fixture()
        _ = try await seedHabit(habits)
        await vm.refresh(now: now)
        await vm.closeToday(lapsedHabitIDs: [], now: now)
        #expect(vm.isClosedToday == true)
        #expect(vm.streakDays == 1)
        #expect(vm.lastCloseResult != nil)
    }

    @Test func 어제_미마무리면_소급카드가_보인다() async throws {
        let (vm, habits, service) = try fixture()
        let h = try await seedHabit(habits)
        // 그제 마무리 기록을 만들어 어제만 공백으로 둔다
        let dayBefore = cal.date(from: DateComponents(year: 2026, month: 7, day: 6, hour: 21))!
        _ = try await service.closeToday(lapsedHabitIDs: [], now: dayBefore)
        await vm.refresh(now: now)
        #expect(vm.showYesterdayCard == true)
        await vm.answerYesterday(.resisted, now: now)
        #expect(vm.showYesterdayCard == false)
        #expect(vm.streakDays == 2)
        _ = h
    }

    @Test func 즉시기록하면_행이_잠김표시된다() async throws {
        let (vm, habits, _) = try fixture()
        let h = try await seedHabit(habits)
        await vm.refresh(now: now)
        await vm.recordLapse(habitID: h.id, memo: "회식", now: now)
        #expect(vm.habitRows[0].lapsedToday == true)
    }
}
