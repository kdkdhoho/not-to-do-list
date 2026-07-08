import SwiftUI
import Shared

public struct TodayView: View {
    let viewModel: TodayViewModel
    let router: TodayRouter

    public var body: some View {
        ZStack(alignment: .bottom) {
            AppColor.Background.primary.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    StreakHearthView(streakDays: viewModel.streakDays,
                                     isClosedToday: viewModel.isClosedToday,
                                     freezeCount: viewModel.freezeCount)
                        .padding(.top, Theme.Spacing.sm)
                        .padding(.bottom, Theme.Spacing.xl)   // 불꽃에게 숨 쉴 공간 (합계 48)

                    if viewModel.showYesterdayCard {
                        YesterdayCardView { answer in
                            Task { await viewModel.answerYesterday(answer) }
                        }
                    }

                    LazyVStack(spacing: Theme.Spacing.sm) {
                        ForEach(viewModel.habitRows) { row in
                            HabitRowCard(row: row)
                                .contextMenu {
                                    Button(AppStrings.Today.lapseAction) {
                                        router.presentSheet(.lapse(habitID: row.id))
                                    }
                                }
                        }
                    }

                    Spacer(minLength: 96)   // 하단 고정 CTA 공간
                }
                .padding(.horizontal, Theme.Spacing.screenH)
            }

            bottomBar
                .padding(.horizontal, Theme.Spacing.screenH)
                .padding(.bottom, Theme.Spacing.md)
        }
        .task { await viewModel.refresh() }
        .toolbarVisibility(.hidden, for: .navigationBar)
    }

    @ViewBuilder private var bottomBar: some View {
        if viewModel.isClosedToday {
            Text(AppStrings.Today.closedChip)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.Text.secondary)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(AppColor.Background.secondary, in: Capsule())
        } else if viewModel.habitRows.isEmpty {
            EmberCTAButton(title: AppStrings.Today.addFirstHabit) {
                // 습관 추가 플로우는 Plan 3 — 현재는 비활성 자리만 유지
            }
        } else {
            EmberCTAButton(title: AppStrings.Today.closeCTA) {
                router.presentSheet(.closing)
            }
        }
    }
}
