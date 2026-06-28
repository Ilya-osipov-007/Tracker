import CoreData

final class PersistentContainer {
    static let shared = PersistentContainer()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext { container.viewContext }

    private init() {
        container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Core Data failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
