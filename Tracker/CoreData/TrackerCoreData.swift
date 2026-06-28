import CoreData

@objc(TrackerCoreData)
final class TrackerCoreData: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var emoji: String?
    @NSManaged var colorHex: String?
    @NSManaged var schedule: String?
    @NSManaged var category: TrackerCategoryCoreData?

    static func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }
}
