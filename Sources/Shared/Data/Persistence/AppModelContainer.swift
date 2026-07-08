import SwiftData

public enum AppModelContainer {
    public static func make(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema([HabitModel.self, DayCloseModel.self, HabitDayMarkModel.self,
                             StreakStateModel.self, BadgeAwardModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
