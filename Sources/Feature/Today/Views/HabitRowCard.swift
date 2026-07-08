import SwiftUI
import Shared

/// 습관 리스트 행 — 습관의 색은 44px 원 안에만 산다 (design.md habit-row)
struct HabitRowCard: View {
    let row: TodayViewModel.HabitRow

    var body: some View {
        HStack(spacing: Theme.Spacing.sm + 4) {
            ZStack {
                Circle()
                    .fill(Color(hex: row.colorHex).opacity(0.12))
                    .frame(width: 44, height: 44)
                // 습관 아이콘은 사용자 데이터(동적 rawValue)라 AppIcon enum을 거칠 수 없다 —
                // HabitRowCard에서만 예외적으로 Image(systemName:) 직접 사용 (image-resource.md 예외).
                Image(systemName: row.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: row.colorHex))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(row.name)
                    .font(AppTypography.bodyStrong)
                    .foregroundStyle(AppColor.Text.primary)
                if !row.subtitle.isEmpty {
                    Text(row.subtitle)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.Text.secondary)
                }
            }
            Spacer()
            Text(row.dPlusText)
                .font(AppTypography.numeralSm)
                .foregroundStyle(AppColor.Text.primary)
        }
        .padding(Theme.Spacing.md)
        .background(AppColor.Background.secondary,
                    in: RoundedRectangle(cornerRadius: Theme.CornerRadius.lg, style: .continuous))
    }
}
