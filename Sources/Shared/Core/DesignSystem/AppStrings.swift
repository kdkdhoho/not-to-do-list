import SwiftUI

// MARK: - App Strings

/// 로컬라이즈된 문자열에 대한 타입-세이프 접근을 제공한다.
///
/// 새 문자열 추가 절차:
///   1. Sources/Shared/Resources/Localizable.xcstrings 에 키-값 추가
///   2. 아래 enum에 해당 키에 대응하는 static property 추가
///   3. 코드에서 AppStrings.Tab.home 등으로 사용
///
/// 키 이름 규칙: {화면}.{용도} (예: onboarding.welcome)

public enum AppStrings {
    // MARK: - Tab
    public enum Tab {
        public static var home: String {
            String(localized: "tab.home", bundle: .module)
        }

        public static var explore: String {
            String(localized: "tab.explore", bundle: .module)
        }

        public static var settings: String {
            String(localized: "tab.settings", bundle: .module)
        }

        public static var today: String {
            String(localized: "tab.today", bundle: .module)
        }

        public static var record: String {
            String(localized: "tab.record", bundle: .module)
        }
    }

    // MARK: - Today
    public enum Today {
        /// "일째 마무리"
        public static var streakLabel: String {
            String(localized: "today.streakLabel", bundle: .module)
        }

        /// "오늘 마무리가 남아 있어요"
        public static var streakLabelOpen: String {
            String(localized: "today.streakLabelOpen", bundle: .module)
        }

        /// "오늘 하루 마무리하기"
        public static var closeCTA: String {
            String(localized: "today.closeCTA", bundle: .module)
        }

        /// "오늘 하루 마무리했어요 · 내일 봐요"
        public static var closedChip: String {
            String(localized: "today.closedChip", bundle: .module)
        }

        /// "첫 습관 등록하기"
        public static var addFirstHabit: String {
            String(localized: "today.addFirstHabit", bundle: .module)
        }

        /// "무너짐 기록하기" (행 스와이프 액션)
        public static var lapseAction: String {
            String(localized: "today.lapseAction", bundle: .module)
        }

        /// "D+%lld"
        public static func dPlus(_ days: Int) -> String {
            String(localized: "today.dPlus \(days)", bundle: .module)
        }

        /// "%@을 아꼈어요!" (포맷된 금액)
        public static func savedMoney(_ amount: String) -> String {
            String(localized: "today.savedMoney \(amount)", bundle: .module)
        }

        /// "책 %lld권 읽을 시간을 아꼈어요"
        public static func savedBooks(_ books: Int) -> String {
            String(localized: "today.savedBooks \(books)", bundle: .module)
        }

        /// "책 %lld페이지 읽을 시간을 아꼈어요"
        public static func savedPages(_ pages: Int) -> String {
            String(localized: "today.savedPages \(pages)", bundle: .module)
        }
    }

    // MARK: - Closing
    public enum Closing {
        /// "오늘 하루 마무리할게요"
        public static var title: String {
            String(localized: "closing.title", bundle: .module)
        }

        /// "무너진 습관만 표시해요 — 나머지는 참은 거예요"
        public static var subtitle: String {
            String(localized: "closing.subtitle", bundle: .module)
        }

        /// "이대로 마무리하기"
        public static var confirm: String {
            String(localized: "closing.confirm", bundle: .module)
        }

        /// "낮에 기록했어요 · 잠김"
        public static var lockedCaption: String {
            String(localized: "closing.lockedCaption", bundle: .module)
        }
    }

    // MARK: - Lapse
    public enum Lapse {
        /// "무너진 순간을 기록할게요"
        public static var title: String {
            String(localized: "lapse.title", bundle: .module)
        }

        /// "메모를 남길 수 있어요 (선택)"
        public static var memoPlaceholder: String {
            String(localized: "lapse.memoPlaceholder", bundle: .module)
        }

        /// "기록해도 하루를 마무리하면 스트릭은 그대로예요"
        public static var keepNote: String {
            String(localized: "lapse.keepNote", bundle: .module)
        }

        /// "기록하기"
        public static var confirm: String {
            String(localized: "lapse.confirm", bundle: .module)
        }

        /// "취소"
        public static var cancel: String {
            String(localized: "lapse.cancel", bundle: .module)
        }
    }

    // MARK: - Yesterday
    public enum Yesterday {
        /// "어제는 어땠어요?"
        public static var title: String {
            String(localized: "yesterday.title", bundle: .module)
        }

        /// "참았어요"
        public static var resisted: String {
            String(localized: "yesterday.resisted", bundle: .module)
        }

        /// "못 참았어요"
        public static var lapsed: String {
            String(localized: "yesterday.lapsed", bundle: .module)
        }

        /// "기억나지 않아요"
        public static var unknown: String {
            String(localized: "yesterday.unknown", bundle: .module)
        }
    }

    // MARK: - Home
    public enum Home {
        public static var navigationTitle: String {
            String(localized: "home.navigationTitle", bundle: .module)
        }
    }

    // MARK: - Explore
    public enum Explore {
        public static var title: String {
            String(localized: "explore.title", bundle: .module)
        }

        public static var navigationTitle: String {
            String(localized: "explore.navigationTitle", bundle: .module)
        }
    }

    // MARK: - Settings
    public enum Settings {
        public static var title: String {
            String(localized: "settings.title", bundle: .module)
        }

        public static var navigationTitle: String {
            String(localized: "settings.navigationTitle", bundle: .module)
        }
    }

    // MARK: - Detail
    public enum Detail {
        public static var navigationTitle: String {
            String(localized: "detail.navigationTitle", bundle: .module)
        }

        /// ID 라벨 포맷. `String(format: AppStrings.Detail.id, value)`로 사용.
        public static var id: String {
            String(localized: "detail.id", bundle: .module)
        }
    }

    // MARK: - Onboarding
    public enum Onboarding {
        public static var welcome: String {
            String(localized: "onboarding.welcome", bundle: .module)
        }

        public static var ready: String {
            String(localized: "onboarding.ready", bundle: .module)
        }

        public static var start: String {
            String(localized: "onboarding.start", bundle: .module)
        }
    }

    // MARK: - Auth
    public enum Auth {
        public static var required: String {
            String(localized: "auth.required", bundle: .module)
        }
    }

    // MARK: - Maintenance
    public enum Maintenance {
        public static var title: String {
            String(localized: "maintenance.title", bundle: .module)
        }

        public static var retry: String {
            String(localized: "maintenance.retry", bundle: .module)
        }
    }

    // MARK: - Error
    public enum Error {
        public static var title: String {
            String(localized: "error.title", bundle: .module)
        }

        public static var retry: String {
            String(localized: "error.retry", bundle: .module)
        }
    }
}
