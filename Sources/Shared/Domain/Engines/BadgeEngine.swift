import Foundation

public enum BadgeKind: Hashable, Codable, Sendable {
    case checkinStreak(days: Int)
    case habitRun(days: Int)          // 어느 습관이든 연속 절제 도달 시 1회
    case moneySaved(milestone: Int)   // 앱 통화 기준 합산 (PRD §7)
    case honesty                      // 무너짐 기록 다음 날에도 마무리 지속
}

public struct BadgeAward: Hashable, Codable, Sendable {
    public let kind: BadgeKind
    public let earnedAt: Date

    public init(kind: BadgeKind, earnedAt: Date) {
        self.kind = kind
        self.earnedAt = earnedAt
    }
}

public struct BadgeJudgeInput: Sendable {
    public var streakDays: Int
    public var maxHabitRun: Int
    public var totalSavedMoney: Decimal
    public var currencyCode: String
    public var closedTodayAfterYesterdayLapse: Bool
    public var alreadyEarned: Set<BadgeKind>

    public init(streakDays: Int, maxHabitRun: Int, totalSavedMoney: Decimal,
                currencyCode: String, closedTodayAfterYesterdayLapse: Bool,
                alreadyEarned: Set<BadgeKind>) {
        self.streakDays = streakDays
        self.maxHabitRun = maxHabitRun
        self.totalSavedMoney = totalSavedMoney
        self.currencyCode = currencyCode
        self.closedTodayAfterYesterdayLapse = closedTodayAfterYesterdayLapse
        self.alreadyEarned = alreadyEarned
    }
}

/// 마무리 완료 직후 일괄 판정. 획득한 배지는 회수되지 않는다 (PRD §7).
public enum BadgeEngine {
    public static let streakMilestones = [3, 7, 14, 30, 60, 100]
    public static let habitRunMilestones = [7, 30, 100]
    /// 통화별 누적 아낀 돈 임계값. 테이블에 없는 통화는 USD 임계값을 쓴다 (PRD §6.3)
    public static let moneyMilestones: [String: [Int]] = [
        "KRW": [10_000, 50_000, 100_000, 500_000],
        "USD": [10, 50, 100, 500],
    ]

    public static func judge(_ input: BadgeJudgeInput) -> [BadgeKind] {
        var earned: [BadgeKind] = []

        for m in streakMilestones where input.streakDays >= m {
            earned.append(.checkinStreak(days: m))
        }
        for m in habitRunMilestones where input.maxHabitRun >= m {
            earned.append(.habitRun(days: m))
        }
        let milestones = moneyMilestones[input.currencyCode] ?? moneyMilestones["USD"]!
        for m in milestones where input.totalSavedMoney >= Decimal(m) {
            earned.append(.moneySaved(milestone: m))
        }
        if input.closedTodayAfterYesterdayLapse {
            earned.append(.honesty)
        }

        return earned.filter { !input.alreadyEarned.contains($0) }
    }
}
