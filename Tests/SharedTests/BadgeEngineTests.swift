import Foundation
import Testing
@testable import Shared

struct BadgeEngineTests {
    func input(streak: Int = 0, bestHabitRun: Int = 0, savedMoney: Decimal = 0,
               currency: String = "KRW", lapsedYesterday: Bool = false,
               earned: Set<BadgeKind> = []) -> BadgeJudgeInput {
        BadgeJudgeInput(streakDays: streak, maxHabitRun: bestHabitRun,
                        totalSavedMoney: savedMoney, currencyCode: currency,
                        closedTodayAfterYesterdayLapse: lapsedYesterday, alreadyEarned: earned)
    }

    @Test func 스트릭_마일스톤은_도달분을_일괄_판정한다() {
        let new = BadgeEngine.judge(input(streak: 7))
        #expect(new.contains(.checkinStreak(days: 3)))
        #expect(new.contains(.checkinStreak(days: 7)))
        #expect(!new.contains(.checkinStreak(days: 14)))
    }

    @Test func 이미_획득한_배지는_다시_주지_않는다() {
        let new = BadgeEngine.judge(input(streak: 7, earned: [.checkinStreak(days: 3)]))
        #expect(!new.contains(.checkinStreak(days: 3)))
        #expect(new.contains(.checkinStreak(days: 7)))
    }

    @Test func 아낀돈은_통화별_임계값을_쓴다() {
        #expect(BadgeEngine.judge(input(savedMoney: 10000, currency: "KRW"))
            .contains(.moneySaved(milestone: 10000)))
        #expect(BadgeEngine.judge(input(savedMoney: 10, currency: "USD"))
            .contains(.moneySaved(milestone: 10)))
        #expect(!BadgeEngine.judge(input(savedMoney: 9999, currency: "KRW"))
            .contains(.moneySaved(milestone: 10000)))
    }

    @Test func 미지원통화는_USD_임계값을_쓴다() {
        #expect(BadgeEngine.judge(input(savedMoney: 50, currency: "EUR"))
            .contains(.moneySaved(milestone: 50)))
    }

    @Test func 정직배지_무너진_다음날에도_마무리하면_획득() {
        #expect(BadgeEngine.judge(input(lapsedYesterday: true)).contains(.honesty))
        #expect(!BadgeEngine.judge(input(lapsedYesterday: false)).contains(.honesty))
    }
}
