import Foundation
import Testing
@testable import Shared

struct PresetCatalogTests {
    @Test func 한국로케일은_KRW가_기본이다() {
        let locale = Locale(identifier: "ko_KR")
        #expect(AppCurrency.default(for: locale).code == "KRW")
    }

    @Test func 미지원_로케일통화는_USD_폴백() {
        let locale = Locale(identifier: "fa_IR")   // 이란 리알 — 미지원
        #expect(AppCurrency.default(for: locale).code == "USD")
    }

    @Test func KRW는_근거기반_단가가_채워진다() {
        let presets = PresetCatalog.presets(for: AppCurrency(code: "KRW"))
        let cigarette = presets.first { $0.id == .cigarette }!
        #expect(cigarette.defaultRate == .money(3000))
        let delivery = presets.first { $0.id == .delivery }!
        #expect(delivery.defaultRate == .money(30000))
    }

    @Test func USD_테이블() {
        let presets = PresetCatalog.presets(for: AppCurrency(code: "USD"))
        #expect(presets.first { $0.id == .cigarette }!.defaultRate == .money(6))
    }

    @Test func 그외통화는_돈프리셋_단가가_빈칸이다() {
        let presets = PresetCatalog.presets(for: AppCurrency(code: "EUR"))
        #expect(presets.first { $0.id == .cigarette }!.defaultRate == Habit.Rate.none)
        // 시간 프리셋은 지역 무관 공통 (PRD §5.3)
        #expect(presets.first { $0.id == .sns }!.defaultRate == .time(minutes: 60))
    }

    @Test func 프리셋은_10종이다() {
        #expect(PresetCatalog.presets(for: AppCurrency(code: "KRW")).count == 10)
    }
}
