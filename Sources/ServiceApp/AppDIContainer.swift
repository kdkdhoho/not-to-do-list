import Observation
import Shared
import Feature
import SwiftData

// MARK: - DI Container

@Observable
final class AppDIContainer {
    // MARK: - Singletons
    private let networkClient: NetworkProviding
    private let itemRepository: ItemRepository

    // MARK: - Init
    init(
        networkClient: NetworkProviding? = nil,
        itemRepository: ItemRepository? = nil
    ) {
        let network = networkClient ?? NetworkClient()
        self.networkClient = network
        self.itemRepository = itemRepository ?? DefaultItemRepository(networkClient: network)
    }

    // MARK: - View Model Factory
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(repository: itemRepository)
    }

    func makeDetailViewModel(itemID: String) -> DetailViewModel {
        DetailViewModel(itemID: itemID, repository: itemRepository)
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
