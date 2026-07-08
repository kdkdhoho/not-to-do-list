import SwiftUI

/// ❄ 프리즈 보유 칩 (design.md freeze-chip). frost는 프리즈 표기 전용 — 인터랙티브 금지.
public struct FreezeChip: View {
    private let count: Int

    public init(count: Int) {
        self.count = count
    }

    public var body: some View {
        HStack(spacing: Theme.Spacing.xs + 2) {
            Image(appIcon: .snowflake)
                .font(.system(size: 14))
                .foregroundStyle(count > 0 ? AppColor.Functional.frost : AppColor.Text.tertiary)
            Text("×\(count)")
                .font(AppTypography.numeralSm)
                .foregroundStyle(count > 0 ? AppColor.Functional.frost : AppColor.Text.tertiary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            count > 0 ? AppColor.Functional.frostSoft : AppColor.Background.secondary,
            in: Capsule()
        )
    }
}
