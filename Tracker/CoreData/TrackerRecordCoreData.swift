import CoreData

@objc(TrackerRecordCoreData)
final class TrackerRecordCoreData: NSManagedObject {
    @NSManaged var trackerId: UUID?
    @NSManaged var date: Date?

    static func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }
}
