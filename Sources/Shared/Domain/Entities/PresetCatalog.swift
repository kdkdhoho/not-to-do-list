import Foundation

public enum PresetID: String, CaseIterable, Codable, Sendable {
    case cigarette, lateNightSnack, delivery, alcohol, shopping, cafe, snack
    case sns, shorts, gaming
}

public struct HabitPreset: Hashable, Sendable, Identifiable {
    public let id: PresetID
    /// AppStrings 키 — UI 레이어에서 현지화 (도메인은 문자열을 노출하지 않는다)
    public let nameKey: String
    public let icon: String
    public let defaultRate: Habit.Rate
}

/// 프리셋 라이브러리 (PRD §5.3) — 단가는 통화별 테이블, KRW·USD 2종 제공
public enum PresetCatalog {
    static let moneyAmounts: [String: [PresetID: Decimal]] = [
        "KRW": [.cigarette: 3000, .lateNightSnack: 20000, .delivery: 30000, .alcohol: 15000,
                .shopping: 10000, .cafe: 5000, .snack: 5000],
        "USD": [.cigarette: 6, .lateNightSnack: 15, .delivery: 25, .alcohol: 12,
                .shopping: 10, .cafe: 5, .snack: 3],
    ]
    static let timeMinutes: [PresetID: Int] = [.sns: 60, .shorts: 60, .gaming: 90]
    static let icons: [PresetID: String] = [
        .cigarette: "cigarette", .lateNightSnack: "drumstick", .delivery: "utensils",
        .alcohol: "beer", .shopping: "shopping-cart", .cafe: "coffee", .snack: "cookie",
        .sns: "smartphone", .shorts: "youtube", .gaming: "gamepad-2",
    ]

    public static func presets(for currency: AppCurrency) -> [HabitPreset] {
        let amounts = moneyAmounts[currency.code]
        return PresetID.allCases.map { id in
            let rate: Habit.Rate
            if let minutes = timeMinutes[id] {
                rate = .time(minutes: minutes)
            } else if let amount = amounts?[id] {
                rate = .money(amount)
            } else {
                rate = .none   // 그 외 통화: 이름·아이콘만 채우고 단가는 빈칸 (PRD §5.3)
            }
            return HabitPreset(id: id, nameKey: "preset.\(id.rawValue)",
                               icon: icons[id]!, defaultRate: rate)
        }
    }
}
