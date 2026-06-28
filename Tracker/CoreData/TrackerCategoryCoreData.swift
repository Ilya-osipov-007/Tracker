import CoreData

@objc(TrackerCategoryCoreData)
final class TrackerCategoryCoreData: NSManagedObject {
    @NSManaged var title: String?
    @NSManaged var trackers: NSSet?

    static func fetchRequest() -> NSFetchRequest<TrackerCategoryCoreData> {
        NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
    }
}
