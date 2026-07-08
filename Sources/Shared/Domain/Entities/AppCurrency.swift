import Foundation

/// 앱 통화 — 전역 1개. 환율 연동·재환산 없음 (PRD §6.2)
public struct AppCurrency: Hashable, Codable, Sendable {
    public let code: String

    public init(code: String) {
        self.code = code
    }

    /// v1 지원 통화 (PRD §6.2 — 주요 통화 약 20종)
    public static let supported: [AppCurrency] = [
        "KRW", "USD", "EUR", "JPY", "GBP", "CNY", "TWD", "HKD", "SGD", "THB",
        "VND", "IDR", "PHP", "INR", "AUD", "CAD", "NZD", "BRL", "MXN", "CHF",
    ].map(AppCurrency.init(code:))

    /// 최초 실행 시 기기 로케일의 통화. 미지원 로케일은 USD (PRD §11)
    public static func `default`(for locale: Locale) -> AppCurrency {
        guard let code = locale.currency?.identifier,
              supported.contains(AppCurrency(code: code)) else {
            return AppCurrency(code: "USD")
        }
        return AppCurrency(code: code)
    }
}
