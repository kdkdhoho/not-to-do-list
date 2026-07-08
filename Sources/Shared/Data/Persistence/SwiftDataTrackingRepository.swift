import Foundation
import SwiftData

@ModelActor
public actor SwiftDataTrackingRepository: TrackingRepository {
    public func closes(in range: ClosedRange<DayStamp>) async throws -> [DayClose] {
        let lower = range.lowerBound.storageKey
        let upper = range.upperBound.storageKey
        return try modelContext.fetch(FetchDescriptor<DayCloseModel>(
            predicate: #Predicate { $0.dayKey >= lower && $0.dayKey <= upper },
            sortBy: [SortDescriptor(\.dayKey)])).map(\.entity)
    }

    public func close(on day: DayStamp) async throws -> DayClose? {
        let key = day.storageKey
        return try modelContext.fetch(FetchDescriptor<DayCloseModel>(
            predicate: #Predicate { $0.dayKey == key })).first?.entity
    }

    public func saveClose(_ close: DayClose) async throws {
        modelContext.insert(DayCloseModel(close))
        try modelContext.save()
    }

    public func marks(in range: ClosedRange<DayStamp>) async throws -> [HabitDayMark] {
        let lower = range.lowerBound.storageKey
        let upper = range.upperBound.storageKey
        return try modelContext.fetch(FetchDescriptor<HabitDayMarkModel>(
            predicate: #Predicate { $0.dayKey >= lower && $0.dayKey <= upper })).map(\.entity)
    }

    public func marks(habitID: UUID) async throws -> [HabitDayMark] {
        try modelContext.fetch(FetchDescriptor<HabitDayMarkModel>(
            predicate: #Predicate { $0.habitID == habitID })).map(\.entity)
    }

    public func saveMark(_ mark: HabitDayMark) async throws {
        try await deleteMark(habitID: mark.habitID, day: mark.day)
        modelContext.insert(HabitDayMarkModel(mark))
        try modelContext.save()
    }

    public func deleteMark(habitID: UUID, day: DayStamp) async throws {
        let key = "\(habitID.uuidString)|\(day.storageKey)"
        try modelContext.delete(model: HabitDayMarkModel.self,
                                where: #Predicate { $0.compositeKey == key })
        try modelContext.save()
    }

    public func streakState() async throws -> StreakState {
        try modelContext.fetch(FetchDescriptor<StreakStateModel>()).first?.entity ?? StreakState()
    }

    public func saveStreakState(_ state: StreakState) async throws {
        try modelContext.delete(model: StreakStateModel.self)
        modelContext.insert(StreakStateModel(state))
        try modelContext.save()
    }

    public func badges() async throws -> [BadgeAward] {
        try modelContext.fetch(FetchDescriptor<BadgeAwardModel>(
            sortBy: [SortDescriptor(\.earnedAt)])).compactMap(\.entity)
    }

    public func saveBadges(_ awards: [BadgeAward]) async throws {
        for award in awards { modelContext.insert(BadgeAwardModel(award)) }
        try modelContext.save()
    }

    public func deleteAllData() async throws {
        try modelContext.delete(model: DayCloseModel.self)
        try modelContext.delete(model: HabitDayMarkModel.self)
        try modelContext.delete(model: StreakStateModel.self)
        try modelContext.delete(model: BadgeAwardModel.self)
        try modelContext.delete(model: HabitModel.self)
        try modelContext.save()
    }
}
