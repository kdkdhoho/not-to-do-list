import Observation
import Shared
import Feature
import SwiftData

// MARK: - DI Container

@Observable
final class AppDIContainer {
    // MARK: - Init
    init() {}

    // MARK: - View Model Factory

    @MainActor
    func makeTodayViewModel() -> TodayViewModel {
        TodayViewModel(checkInService: checkInService,
                       habitRepository: habitRepository,
                       trackingRepository: trackingRepository,
                       currency: AppCurrency.default(for: .current))
    }

    // MARK: - 잉걸 도메인 (Plan 1)

    private let modelContainer: ModelContainer = {
        do {
            return try AppModelContainer.make(inMemory: false)
        } catch {
            fatalError("SwiftData 컨테이너 초기화 실패: \(error)")
        }
    }()

    @ObservationIgnored
    lazy var habitRepository: HabitRepository =
        SwiftDataHabitRepository(modelContainer: modelContainer)

    @ObservationIgnored
    lazy var trackingRepository: TrackingRepository =
        SwiftDataTrackingRepository(modelContainer: modelContainer)

    @ObservationIgnored
    lazy var checkInService: CheckInServicing =
        CheckInService(habitRepository: habitRepository,
                       trackingRepository: trackingRepository,
                       currency: AppCurrency.default(for: .current))
}
