import SwiftUI
import Shared

// MARK: - Record Placeholder View

/// 기록 탭 자리 — Plan 3에서 캘린더·배지·진도로 대체한다.
public struct RecordPlaceholderView: View {
    public init() {}

    public var body: some View {
        ZStack {
            AppColor.Background.primary.ignoresSafeArea()
            Text(AppStrings.Tab.record)
                .font(AppTypography.title)
                .foregroundStyle(AppColor.Text.tertiary)
        }
    }
}
