import SwiftUI
import Shared

public struct TodayNavigationView: View {
    @Bindable private var router: TodayRouter
    private let viewModel: TodayViewModel

    public init(router: TodayRouter, viewModel: TodayViewModel) {
        self.router = router
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            TodayView(viewModel: viewModel, router: router)
        }
        .sheet(item: $router.sheet) { sheet in
            switch sheet {
            case .closing:
                ClosingSheetView(viewModel: viewModel, router: router)
                    .presentationDetents([.medium, .large])
                    .presentationBackground(AppColor.Background.elevated)
            case .lapse(let habitID):
                LapseSheetView(viewModel: viewModel, router: router, habitID: habitID)
                    .presentationDetents([.medium])
                    .presentationBackground(AppColor.Background.elevated)
            }
        }
    }
}
