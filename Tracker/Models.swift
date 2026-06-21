//
//  Models.swift
//  Tracker
//

import UIKit

enum WeekDay: Int, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var displayName: String {
        switch self {
        case .sunday: return "Воскресенье"
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        }
    }

    var shortName: String {
        switch self {
        case .sunday: return "Вс"
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        }
    }

    static var ordered: [WeekDay] {
        [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }
}

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Set<WeekDay>?
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecord: Hashable {
    let trackerId: UUID
    let date: Date

    func hash(into hasher: inout Hasher) {
        hasher.combine(trackerId)
        hasher.combine(Calendar.current.startOfDay(for: date))
    }

    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        lhs.trackerId == rhs.trackerId &&
        Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
}
