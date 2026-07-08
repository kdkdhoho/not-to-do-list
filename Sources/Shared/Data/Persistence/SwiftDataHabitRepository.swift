import Foundation
import SwiftData

@ModelActor
public actor SwiftDataHabitRepository: HabitRepository {
    public func habits(includeArchived: Bool) async throws -> [Habit] {
        let all = try modelContext.fetch(FetchDescriptor<HabitModel>(
            sortBy: [SortDescriptor(\.createdDayKey)]))
        let entities = all.map(\.entity)
        return includeArchived ? entities : entities.filter { $0.archivedDay == nil }
    }

    public func activeHabits(on day: DayStamp) async throws -> [Habit] {
        try await habits(includeArchived: true).filter { $0.isActive(on: day) }
    }

    public func save(_ habit: Habit) async throws {
        try deleteModel(id: habit.id)
        modelContext.insert(HabitModel(habit))
        try modelContext.save()
    }

    public func archive(id: UUID, on day: DayStamp) async throws {
        guard let model = try fetchModel(id: id) else { return }
        model.archivedDayKey = day.storageKey
        try modelContext.save()
    }

    public func unarchive(id: UUID) async throws {
        guard let model = try fetchModel(id: id) else { return }
        model.archivedDayKey = nil
        try modelContext.save()
    }

    public func delete(id: UUID) async throws {
        try deleteModel(id: id)
        try modelContext.delete(model: HabitDayMarkModel.self,
                                where: #Predicate { $0.habitID == id })
        try modelContext.save()
    }

    private func fetchModel(id: UUID) throws -> HabitModel? {
        try modelContext.fetch(FetchDescriptor<HabitModel>(
            predicate: #Predicate { $0.id == id })).first
    }

    private func deleteModel(id: UUID) throws {
        try modelContext.delete(model: HabitModel.self, where: #Predicate { $0.id == id })
    }
}
