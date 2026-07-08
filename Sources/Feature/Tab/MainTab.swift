import SwiftUI
import Shared

// MARK: - Main Tab

public enum MainTab: String, CaseIterable {
    case today
    case record
    case settings

    var title: String {
        switch self {
        case .today: return AppStrings.Tab.today
        case .record: return AppStrings.Tab.record
        case .settings: return AppStrings.Tab.settings
        }
    }

    var icon: AppIcon {
        switch self {
        case .today: return .house
        case .record: return .calendar
        case .settings: return .settings
        }
    }
}
