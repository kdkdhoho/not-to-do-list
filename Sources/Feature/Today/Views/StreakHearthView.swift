import SwiftUI
import Shared

/// 홈 상단 히어로 — 카드가 아니다, 화면 그 자체가 화로다 (design.md streak-hearth)
struct StreakHearthView: View {
    let streakDays: Int
    let isClosedToday: Bool
    let freezeCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(alignment: .top) {
                HStack(alignment: .bottom, spacing: Theme.Spacing.sm + 4) {
                    Image(appIcon: .flame)
                        .font(.system(size: 44))
                        .foregroundStyle(AppColor.Brand.primary)
                        .shadow(color: AppColor.Brand.primary.opacity(0.35), radius: 12)
                    Text("\(streakDays)")
                        .font(AppTypography.numeralHero)
                        .tracking(AppTypography.Tracking.numeralHero)
                        .foregroundStyle(AppColor.Text.primary)
                }
                Spacer()
                FreezeChip(count: freezeCount)
            }
            Text(isClosedToday ? AppStrings.Today.streakLabel : AppStrings.Today.streakLabelOpen)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.Text.secondary)
                .padding(.leading, 56)
        }
        .accessibilityElement(children: .combine)
    }
}
