import SwiftUI

// MARK: - App Typography
// 디자인 토큰 소스: DESIGN.pen (Foundation / Typography) — 잉걸(Ember) 시스템
// 두 목소리: UI는 Pretendard가 말하고, 수치는 IBM Plex Mono가 기록한다.
// 숫자가 주인공인 자리(스트릭·D+N·아낀 돈·캘린더 날짜)는 반드시 numeral* 토큰을 쓴다.
// 본문 문장 안에 섞이는 숫자("3일 연속")는 Pretendard 그대로.

public enum AppTypography {

    // MARK: - Font Family
    public enum Family {
        public static let ui = "Pretendard"
        public static let mono = "IBM Plex Mono"
    }

    // MARK: - Numerals (IBM Plex Mono — 수치 전용, tabular)

    /// numeral-hero · 64 · 600 — 홈 스트릭 카운터. 앱에서 가장 큰 활자
    public static let numeralHero = Font.custom("IBMPlexMono-SemiBold", size: 64)
    /// numeral-lg · 34 · 600 — 습관 상세 D+N, 복귀 화면 자산, 중형 위젯
    public static let numeralLg = Font.custom("IBMPlexMono-SemiBold", size: 34)
    /// numeral-md · 20 · 500 — 통계 값(총 절제일·아낀 돈), 소형 위젯
    public static let numeralMd = Font.custom("IBMPlexMono-Medium", size: 20)
    /// numeral-sm · 15 · 500 — 리스트 행의 D+N, 프리즈 보유 수
    public static let numeralSm = Font.custom("IBMPlexMono-Medium", size: 15)
    /// numeral-cal · 13 · 500 — 캘린더 날짜
    public static let numeralCal = Font.custom("IBMPlexMono-Medium", size: 13)

    // MARK: - UI Scale (Pretendard)

    /// display · 28 · 700 — 온보딩·복귀 화면 헤드라인. 700은 display 전용
    public static let display = Font.custom("Pretendard-Bold", size: 28)
    /// title · 22 · 600 — 화면 타이틀
    public static let title = Font.custom("Pretendard-SemiBold", size: 22)
    /// heading · 18 · 600 — 카드·시트 제목
    public static let heading = Font.custom("Pretendard-SemiBold", size: 18)
    /// body-strong · 16 · 600 — 습관 이름, 버튼 라벨
    public static let bodyStrong = Font.custom("Pretendard-SemiBold", size: 16)
    /// body · 16 · 400 — 본문, 설명
    public static let body = Font.custom("Pretendard-Regular", size: 16)
    /// caption · 13 · 500 — 보조 설명, 수치 라벨
    public static let caption = Font.custom("Pretendard-Medium", size: 13)
    /// label · 12 · 500 — 칩, 탭 라벨, 캘린더 요일
    public static let label = Font.custom("Pretendard-Medium", size: 12)
    /// micro · 11 · 500 — 위젯 라벨, 법적 고지
    public static let micro = Font.custom("Pretendard-Medium", size: 11)

    // MARK: - Letter Spacing → `.tracking()`
    // 마이너스 트래킹은 22pt 이상에서만. 캡션·라벨은 +0.2로 살짝 벌린다.
    public enum Tracking {
        public static let numeralHero: CGFloat = -1.0
        public static let numeralLg: CGFloat = -0.5
        public static let display: CGFloat = -0.5
        public static let title: CGFloat = -0.3
        public static let heading: CGFloat = -0.2
        public static let label: CGFloat = 0.2
        public static let micro: CGFloat = 0.2
    }

    // MARK: - Line Height (fontSize 배수 — lineSpacing 계산용)
    public enum LineHeight {
        /// 수치는 한 줄 활자 (1.0–1.2)
        public static let numeral: CGFloat = 1.1
        /// 헤드라인 1.25–1.35
        public static let headline: CGFloat = 1.25
        /// 본문 행간은 1.5 아래로 줄이지 않는다
        public static let body: CGFloat = 1.5
    }

    // MARK: - Hero Icon Sizes (SF Symbol 히어로 아이콘 — size만 의미)
    public static let heroIcon = Font.custom("Pretendard-Regular", size: 48)
    public static let heroIconLarge = Font.custom("Pretendard-Regular", size: 64)

    // MARK: - Legacy Aliases (템플릿 화면 호환 — 잉걸 화면 구현 시 스케일 토큰으로 교체)
    public static let title2 = display          // 28 · 700
    public static let title3 = title            // 22 · 600
    public static let title4 = heading          // 18 · 600
    public static let body1Regular = body       // 16 · 400
    public static let body2 = Font.custom("Pretendard-Regular", size: 14)  // 오프스케일 — 교체 대상
    public static let caption1 = caption        // 13 · 500
    public static let button1 = bodyStrong      // 16 · 600
}
