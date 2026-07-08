import Foundation

/// 하루 마무리(체크인) 기록 — 달력 날짜당 1개 (PRD §4.2)
public struct DayClose: Hashable, Codable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case sameDay    // 당일 마무리
        case backfill   // 어제 소급
        case freeze     // ❄ 프리즈 자동 소모
    }
    public let day: DayStamp
    public let kind: Kind
    public let closedAt: Date

    public init(day: DayStamp, kind: Kind, closedAt: Date) {
        self.day = day
        self.kind = kind
        self.closedAt = closedAt
    }
}

public enum LapseSource: String, Codable, Sendable {
    case immediate  // 낮의 즉시 기록
    case atClose    // 마무리 시 체크
}

/// 습관·날짜 단위 기록. 마크 없음 + 그날 마무리됨 = 참았다 (이진 모델, PRD §4.2)
public struct HabitDayMark: Hashable, Codable, Sendable {
    public enum Kind: Hashable, Codable, Sendable {
        case lapsed(source: LapseSource)
        case unknown   // 소급 "기억나지 않아요" → 미기록 처리 (PRD §11)
    }
    public let habitID: UUID
    public let day: DayStamp
    public let kind: Kind
    public var memo: String?

    public init(habitID: UUID, day: DayStamp, kind: Kind, memo: String? = nil) {
        self.habitID = habitID
        self.day = day
        self.kind = kind
        self.memo = memo
    }
}

/// 스트릭 상태 스냅샷 (영속 대상)
public struct StreakState: Hashable, Codable, Sendable {
    public var current: Int
    public var best: Int
    public var freezes: Int
    public var freezeAccrual: Int

    public init(current: Int = 0, best: Int = 0, freezes: Int = 0, freezeAccrual: Int = 0) {
        self.current = current
        self.best = best
        self.freezes = freezes
        self.freezeAccrual = freezeAccrual
    }
}
