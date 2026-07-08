import SwiftUI

/// 하루 마무리 이외의 확정 행동 (design.md button-secondary).
/// 시트(surface-raised) 위에서는 배경을 canvas로 반전해 색 단차를 만든다.
public struct SecondaryButton: View {
    private let title: String
    private let isOnSheet: Bool
    private let action: () -> Void

    public init(title: String, isOnSheet: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isOnSheet = isOnSheet
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColor.Text.primary)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(
                    isOnSheet ? AppColor.Background.primary : AppColor.Background.elevated,
                    in: RoundedRectangle(cornerRadius: Theme.CornerRadius.md, style: .continuous)
                )
        }
        .buttonStyle(.plain)
    }
}
