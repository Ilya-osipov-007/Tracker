import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistentContainer.shared.viewContext) {
        self.context = context
    }

    var completedTrackers: Set<TrackerRecord> {
        let request = TrackerRecordCoreData.fetchRequest()
        let entities = (try? context.fetch(request)) ?? []
        return Set(entities.compactMap { entity -> TrackerRecord? in
            guard let id = entity.trackerId, let date = entity.date else { return nil }
            return TrackerRecord(trackerId: id, date: date)
        })
    }

    func add(_ record: TrackerRecord) throws {
        let entity = TrackerRecordCoreData(context: context)
        entity.trackerId = record.trackerId
        entity.date = Calendar.current.startOfDay(for: record.date)
        try context.save()
    }

    func remove(_ record: TrackerRecord) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "trackerId == %@ AND date == %@",
            record.trackerId as CVarArg,
            Calendar.current.startOfDay(for: record.date) as CVarArg
        )
        let entities = try context.fetch(request)
        entities.forEach { context.delete($0) }
        try context.save()
    }
}
