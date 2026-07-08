import Foundation
import SwiftData

// DayStamp는 정렬 가능한 Int 키(yyyymmdd)로 저장한다. 변환은 Data 레이어에 가둔다.
extension DayStamp {
    var storageKey: Int { year * 10_000 + month * 100 + day }
    init(storageKey: Int) {
        self.init(year: storageKey / 10_000, month: (storageKey / 100) % 100, day: storageKey % 100)
    }
}

@Model
final class HabitModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var rateData: Data          // Habit.Rate를 JSONEncoder로 저장
    var createdDayKey: Int
    var firstTrackedDayKey: Int
    var archivedDayKey: Int?

    init(_ habit: Habit) {
        id = habit.id
        name = habit.name
        icon = habit.icon
        colorHex = habit.colorHex
        rateData = (try? JSONEncoder().encode(habit.rate)) ?? Data()
        createdDayKey = habit.createdDay.storageKey
        firstTrackedDayKey = habit.firstTrackedDay.storageKey
        archivedDayKey = habit.archivedDay?.storageKey
    }

    var entity: Habit {
        Habit(id: id, name: name, icon: icon, colorHex: colorHex,
              rate: (try? JSONDecoder().decode(Habit.Rate.self, from: rateData)) ?? .none,
              createdDay: DayStamp(storageKey: createdDayKey),
              firstTrackedDay: DayStamp(storageKey: firstTrackedDayKey),
              archivedDay: archivedDayKey.map(DayStamp.init(storageKey:)))
    }
}

@Model
final class DayCloseModel {
    @Attribute(.unique) var dayKey: Int
    var kindRaw: String
    var closedAt: Date

    init(_ close: DayClose) {
        dayKey = close.day.storageKey
        kindRaw = close.kind.rawValue
        closedAt = close.closedAt
    }

    var entity: DayClose {
        DayClose(day: DayStamp(storageKey: dayKey),
                 kind: DayClose.Kind(rawValue: kindRaw) ?? .sameDay, closedAt: closedAt)
    }
}

@Model
final class HabitDayMarkModel {
    @Attribute(.unique) var compositeKey: String   // "habitID|dayKey"
    var habitID: UUID
    var dayKey: Int
    var kindData: Data
    var memo: String?

    init(_ mark: HabitDayMark) {
        compositeKey = "\(mark.habitID.uuidString)|\(mark.day.storageKey)"
        habitID = mark.habitID
        dayKey = mark.day.storageKey
        kindData = (try? JSONEncoder().encode(mark.kind)) ?? Data()
        memo = mark.memo
    }

    var entity: HabitDayMark {
        HabitDayMark(habitID: habitID, day: DayStamp(storageKey: dayKey),
                     kind: (try? JSONDecoder().decode(HabitDayMark.Kind.self, from: kindData)) ?? .unknown,
                     memo: memo)
    }
}

@Model
final class StreakStateModel {
    @Attribute(.unique) var singleton: Int   // 항상 0
    var current: Int
    var best: Int
    var freezes: Int
    var freezeAccrual: Int

    init(_ state: StreakState) {
        singleton = 0
        current = state.current
        best = state.best
        freezes = state.freezes
        freezeAccrual = state.freezeAccrual
    }

    var entity: StreakState {
        StreakState(current: current, best: best, freezes: freezes, freezeAccrual: freezeAccrual)
    }
}

@Model
final class BadgeAwardModel {
    @Attribute(.unique) var kindData: Data
    var earnedAt: Date

    init(_ award: BadgeAward) {
        kindData = (try? JSONEncoder().encode(award.kind)) ?? Data()
        earnedAt = award.earnedAt
    }

    var entity: BadgeAward? {
        guard let kind = try? JSONDecoder().decode(BadgeKind.self, from: kindData) else { return nil }
        return BadgeAward(kind: kind, earnedAt: earnedAt)
    }
}
