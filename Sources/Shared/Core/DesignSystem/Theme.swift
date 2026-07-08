import SwiftUI

// MARK: - App Theme

public enum Theme {
    // MARK: - Spacing (DESIGN.pen — 기본 단위 4pt, 구조 간격은 8/16/24/32/48로 스냅)
    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        /// 홈 스트릭 헤더 아래 전용 — 불꽃에게 숨 쉴 공간
        public static let xxl: CGFloat = 48
        /// 화면 좌우 패딩 — 모든 화면 공통
        public static let screenH: CGFloat = 20
    }

    // MARK: - Corner Radius (DESIGN.pen — 모든 라운딩은 continuous corner로 적용)
    public enum CornerRadius {
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        /// 카드, 습관 행, 위젯 내부 블록, 하루 마무리 CTA
        public static let lg: CGFloat = 16
        /// 바텀시트 상단 모서리
        public static let xl: CGFloat = 24
        /// 상태 칩 전용 (프리즈 칩, 마무리 완료 칩) — 필은 상태 문법
        public static let pill: CGFloat = 9999
    }
}

// MARK: - View State

public enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case failure(Error)

    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    public var data: T? {
        if case .success(let data) = self { return data }
        return nil
    }
}

extension ViewState: Equatable where T: Equatable {
    public static func == (lhs: ViewState<T>, rhs: ViewState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.success(let a), .success(let b)):
            return a == b
        default:
            return false
        }
    }
}
