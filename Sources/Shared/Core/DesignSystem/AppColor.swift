import SwiftUI

// MARK: - App Color Palette
// 디자인 토큰 소스: DESIGN.pen (Foundation / Color Palette) — 잉걸(Ember) 시스템
// 다크 단일 모드: 시스템 라이트/다크 설정과 무관하게 동일 렌더링 (docs/design.md)
// 순수 검정(#000000)·순수 흰색(#FFFFFF)은 팔레트에 없다 — 숯과 종이 톤만 쓴다.

public enum AppColor {

    // MARK: - Brand (잉걸 — 시스템 유일의 액센트)
    // 하루 마무리 CTA·스트릭 불꽃·오늘 링·획득 배지 스트로크에만. 새 요소에 쓰기 전에 "이것이 하루 마무리인가?"를 먼저 묻는다.
    public enum Brand {
        /// ember #FF6B2C
        public static let primary = Color(hex: "FF6B2C")
        /// ember-deep — 눌림(pressed) 상태 전용
        public static let primaryPressed = Color(hex: "C94F1A")
        /// ember-soft 14% — 틴트 배경 (스트릭 헤더 승온, 획득 배지 배경)
        public static let primarySoft = Color(hex: "FF6B2C").opacity(0.14)
        /// on-ember — 잉걸 배경 위 텍스트. 흰색이 아니라 어두운 갈흑색
        public static let onPrimary = Color(hex: "1C0E04")
    }

    // MARK: - Functional
    public enum Functional {
        /// frost — ❄ 프리즈 전용 기능색. 두 번째 액센트가 아니다 — 인터랙티브 요소 금지
        public static let frost = Color(hex: "9CCFE7")
        /// frost-soft 14% — 프리즈 칩 배경 틴트
        public static let frostSoft = Color(hex: "9CCFE7").opacity(0.14)
        /// danger — 파괴적 행동(습관 삭제·데이터 초기화) 확인 전용. 무너짐 기록에는 절대 쓰지 않는다
        public static let danger = Color(hex: "E5484D")
    }

    // MARK: - Background (표면 3단 — 위계는 그림자가 아니라 색 단차가 만든다)
    public enum Background {
        /// canvas #151210 — 기본 캔버스 (숯). 화면 배경, 탭 바
        public static let primary = Color(hex: "151210")
        /// surface #1E1813 — 카드, 리스트 행 (화로). 한 단계 승온
        public static let secondary = Color(hex: "1E1813")
        /// surface-raised #282017 — 바텀시트, 칩, 입력 필드 (화로 위). 두 단계 승온
        public static let elevated = Color(hex: "282017")
        /// overlay — 시트·모달 뒤 딤, 마무리 의식의 화면 감광
        public static let overlay = Color(hex: "0C0906").opacity(0.6)
    }

    // MARK: - Text (잉크)
    public enum Text {
        /// ink #F3ECE2 — 기본 텍스트. 따뜻한 종이색
        public static let primary = Color(hex: "F3ECE2")
        /// ink-muted — 보조 텍스트, 서브카피, 비강조 수치
        public static let secondary = Color(hex: "A79A8B")
        /// ink-faint — 플레이스홀더, 미기록일, 잠긴 배지. 본문 정보 전달 금지(대비 부족)
        public static let tertiary = Color(hex: "6E6255")
        /// ink-disabled — 비활성 상태 전용
        public static let disabled = Color(hex: "4A4137")
        /// 잉걸 배경 위 텍스트 (= Brand.onPrimary)
        public static let inverse = Brand.onPrimary
    }

    // MARK: - Border & Divider
    public enum Border {
        /// hairline #352C21 — 1px 구분선. 표면 단차로 부족할 때만 최소한으로
        public static let primary = Color(hex: "352C21")
        public static let secondary = Color(hex: "352C21")
        /// 포커스 테두리는 잉크 — 잉걸이 아니다 (text-field 스펙)
        public static let focus = Text.primary
    }

    // MARK: - Status (템플릿 호환용)
    // 잉걸 시스템은 성공=초록/실패=빨강의 신호등 문법을 쓰지 않는다 (기록 표기는 채움의 문법).
    // 아래 매핑은 템플릿 화면 호환을 위한 최소 대응이다.
    public enum Status {
        public static let error = Functional.danger
        public static let errorBackground = Functional.danger.opacity(0.14)
        public static let warning = Brand.primary
        public static let warningBackground = Brand.primarySoft
        public static let success = Text.primary
        public static let successBackground = Background.secondary
        public static let info = Functional.frost
        public static let infoBackground = Functional.frostSoft
    }

    // MARK: - Interactive
    public enum Interactive {
        public static let pressed = Color(hex: "F3ECE2").opacity(0.05)
        public static let disabled = Text.disabled
        public static let disabledBackground = Background.elevated
        public static let overlay = Background.overlay
    }
}
