import SwiftUI
import Shared

// MARK: - Main Tab View

public struct MainTabView: View {
    @State private var appRouter: AppRouter
    private let todayViewModel: TodayViewModel

    public init(appRouter: AppRouter, todayViewModel: TodayViewModel) {
        self._appRouter = State(wrappedValue: appRouter)
        self.todayViewModel = todayViewModel
    }

    public var body: some View {
        TabView(selection: $appRouter.selectedTab) {
            TodayNavigationView(router: appRouter.today, viewModel: todayViewModel)
                .tabItem {
                    Label {
                        Text(MainTab.today.title)
                    } icon: {
                        Image(appIcon: MainTab.today.icon)
                    }
                }
                .tag(MainTab.today)

            RecordPlaceholderView()
                .tabItem {
                    Label {
                        Text(MainTab.record.title)
                    } icon: {
                        Image(appIcon: MainTab.record.icon)
                    }
                }
                .tag(MainTab.record)

            SettingsNavigationView(router: appRouter.settings)
                .tabItem {
                    Label {
                        Text(MainTab.settings.title)
                    } icon: {
                        Image(appIcon: MainTab.settings.icon)
                    }
                }
                .tag(MainTab.settings)
        }
        .tint(AppColor.Text.primary)   // 탭에 잉걸 금지 — 탭 이동은 핵심 행동이 아니다
        .task {
            // 메인 진입 — 콜드스타트로 보류된 딥링크가 있으면 적용
            appRouter.flushPendingLink()
        }
    }
}
