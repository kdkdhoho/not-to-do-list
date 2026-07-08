import SwiftUI
import Shared

/// 소급 확인 카드 — 어느 답도 강조하지 않는다 (design.md yesterday-card)
struct YesterdayCardView: View {
    let onAnswer: (YesterdayAnswer) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(AppStrings.Yesterday.title)
                .font(AppTypography.heading)
                .foregroundStyle(AppColor.Text.primary)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Theme.Spacing.sm) { answerButtons }
                VStack(spacing: Theme.Spacing.sm) { answerButtons }   // SE·영어 라벨 폴백
            }
        }
        .padding(Theme.Spacing.lg)
        .background(AppColor.Background.secondary,
                    in: RoundedRectangle(cornerRadius: Theme.CornerRadius.lg, style: .continuous))
    }

    @ViewBuilder private var answerButtons: some View {
        answerButton(AppStrings.Yesterday.resisted, .resisted)
        answerButton(AppStrings.Yesterday.lapsed, .lapsed)
        answerButton(AppStrings.Yesterday.unknown, .unknown)
    }

    private func answerButton(_ title: String, _ answer: YesterdayAnswer) -> some View {
        Button { onAnswer(answer) } label: {
            Text(title)
                .font(AppTypography.caption)
                .fontWeight(.semibold)
                .foregroundStyle(AppColor.Text.primary)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(AppColor.Background.elevated,
                            in: RoundedRectangle(cornerRadius: Theme.CornerRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
