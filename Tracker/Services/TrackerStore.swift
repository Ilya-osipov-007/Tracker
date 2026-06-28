import CoreData
import UIKit

final class TrackerStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistentContainer.shared.viewContext) {
        self.context = context
    }

    func makeEntity(from tracker: Tracker, category: TrackerCategoryCoreData) throws {
        let entity = TrackerCoreData(context: context)
        entity.id = tracker.id
        entity.name = tracker.name
        entity.emoji = tracker.emoji
        entity.colorHex = tracker.color.hexString
        entity.schedule = tracker.schedule.map { s in
            s.days.map { String($0.rawValue) }.joined(separator: ",")
        }
        entity.category = category
        try context.save()
    }

    func tracker(from entity: TrackerCoreData) -> Tracker? {
        guard
            let id = entity.id,
            let name = entity.name,
            let emoji = entity.emoji,
            let colorHex = entity.colorHex,
            let color = UIColor(hexString: colorHex)
        else { return nil }

        let schedule: Schedule?
        if let raw = entity.schedule, !raw.isEmpty {
            let days = raw.components(separatedBy: ",")
                .compactMap { Int($0) }
                .compactMap { WeekDay(rawValue: $0) }
            schedule = Schedule(Set(days))
        } else {
            schedule = nil
        }

        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
}
