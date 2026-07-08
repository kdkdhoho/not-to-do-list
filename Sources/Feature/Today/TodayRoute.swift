import Foundation

public enum TodayRoute: Hashable {
    case habitDetail(habitID: UUID)   // Plan 3에서 목적지 구현 — 지금은 push 미사용
}

public enum TodaySheet: Identifiable, Hashable {
    case closing
    case lapse(habitID: UUID)

    public var id: String {
        switch self {
        case .closing: "closing"
        case .lapse(let id): "lapse-\(id.uuidString)"
        }
    }
}
