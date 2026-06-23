import Foundation

struct Schedule {
    private(set) var days: Set<WeekDay>

    init(_ days: Set<WeekDay> = []) {
        self.days = days
    }

    var isEmpty: Bool { days.isEmpty }
    var count: Int { days.count }

    func contains(_ day: WeekDay) -> Bool {
        days.contains(day)
    }

    mutating func insert(_ day: WeekDay) {
        days.insert(day)
    }

    mutating func remove(_ day: WeekDay) {
        days.remove(day)
    }
}
