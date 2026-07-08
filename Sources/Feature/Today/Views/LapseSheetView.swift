import SwiftUI
import Shared

/// 즉시 무너짐 기록 시트 — 확정 버튼은 잉걸이 아니다 (design.md lapse-sheet)
struct LapseSheetView: View {
    let viewModel: TodayViewModel
    let router: TodayRouter
    let habitID: UUID
    @State private var memo = ""

    private var habitRow: TodayViewModel.HabitRow? {
        viewModel.habitRows.first { $0.id == habitID }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(AppStrings.Lapse.title)
                .font(AppTypography.heading)
                .foregroundStyle(AppColor.Text.primary)

            if let row = habitRow {
                HStack(spacing: Theme.Spacing.sm + 4) {
                    ZStack {
                        Circle().fill(Color(hex: row.colorHex).opacity(0.12)).frame(width: 40, height: 40)
                        Image(systemName: row.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(Color(hex: row.colorHex))
                    }
                    Text(row.name)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColor.Text.primary)
                }
            }

            TextField(AppStrings.Lapse.memoPlaceholder, text: $memo)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.Text.primary)
                .padding(.horizontal, Theme.Spacing.md)
                .frame(minHeight: 48)
                .background(AppColor.Background.primary,
                            in: RoundedRectangle(cornerRadius: Theme.CornerRadius.md, style: .continuous))

            Text(AppStrings.Lapse.keepNote)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.Text.secondary)

            SecondaryButton(title: AppStrings.Lapse.confirm, isOnSheet: true) {
                let id = habitID
                let note = memo
                Task {
                    await viewModel.recordLapse(habitID: id, memo: note)
                    router.dismissSheet()
                }
            }

            Button(AppStrings.Lapse.cancel) { router.dismissSheet() }
                .font(AppTypography.bodyStrong)
                .foregroundStyle(AppColor.Text.secondary)
                .frame(maxWidth: .infinity)
        }
        .padding(Theme.Spacing.lg)
    }
}
