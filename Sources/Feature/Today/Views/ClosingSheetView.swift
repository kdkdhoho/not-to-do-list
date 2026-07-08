import SwiftUI
import Shared

/// 하루 마무리 플로우 시트 — 기본 전원 "참았어요", 무너진 습관만 탭해서 전환 (design.md closing-sheet)
struct ClosingSheetView: View {
    let viewModel: TodayViewModel
    let router: TodayRouter
    @State private var lapsedIDs: Set<UUID> = []

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(AppStrings.Closing.title)
                .font(AppTypography.heading)
                .foregroundStyle(AppColor.Text.primary)
            Text(AppStrings.Closing.subtitle)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.Text.secondary)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.habitRows) { row in
                        closingRow(row)
                        if row.id != viewModel.habitRows.last?.id {
                            Rectangle().fill(AppColor.Border.primary).frame(height: 1)
                        }
                    }
                }
            }

            EmberCTAButton(title: AppStrings.Closing.confirm) {
                let ids = lapsedIDs
                Task {
                    await viewModel.closeToday(lapsedHabitIDs: ids)
                    router.dismissSheet()
                }
            }
        }
        .padding(Theme.Spacing.lg)
        .onAppear {
            lapsedIDs = Set(viewModel.habitRows.filter(\.lapsedToday).map(\.id))
        }
    }

    private func closingRow(_ row: TodayViewModel.HabitRow) -> some View {
        let isLapsed = lapsedIDs.contains(row.id)
        return Button {
            guard !row.lapsedToday else { return }   // 즉시 기록은 잠김
            if isLapsed { lapsedIDs.remove(row.id) } else { lapsedIDs.insert(row.id) }
        } label: {
            HStack(spacing: Theme.Spacing.sm + 4) {
                ZStack {
                    Circle().fill(Color(hex: row.colorHex).opacity(0.12)).frame(width: 40, height: 40)
                    Image(systemName: row.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(Color(hex: row.colorHex))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(row.name)
                        .font(AppTypography.bodyStrong)
                        .foregroundStyle(AppColor.Text.primary)
                    if row.lapsedToday {
                        Text(AppStrings.Closing.lockedCaption)
                            .font(AppTypography.label)
                            .foregroundStyle(AppColor.Text.tertiary)
                    }
                }
                Spacer()
                stateGlyph(isLapsed: isLapsed, locked: row.lapsedToday)
            }
            .padding(.vertical, Theme.Spacing.sm + 4)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private func stateGlyph(isLapsed: Bool, locked: Bool) -> some View {
        ZStack {
            if isLapsed {
                Circle().strokeBorder(AppColor.Text.primary, lineWidth: 2)
                if locked {
                    Image(appIcon: .lock)
                        .font(.system(size: 11))
                        .foregroundStyle(AppColor.Text.tertiary)
                }
            } else {
                Circle().fill(AppColor.Text.primary)
                Image(appIcon: .check)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.Background.primary)
            }
        }
        .frame(width: 28, height: 28)
    }
}
