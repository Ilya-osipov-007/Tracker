import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeDidUpdate()
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?

    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()

    init(context: NSManagedObjectContext = PersistentContainer.shared.viewContext) {
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        super.init()
        _ = fetchedResultsController
    }

    var categories: [TrackerCategory] {
        (fetchedResultsController.fetchedObjects ?? []).compactMap { category(from: $0) }
    }

    var categoryTitles: [String] {
        (fetchedResultsController.fetchedObjects ?? []).compactMap { $0.title }
    }

    func addTracker(_ tracker: Tracker, toCategory title: String) throws {
        let entity = try findOrCreateCategory(title: title)
        try trackerStore.makeEntity(from: tracker, category: entity)
    }

    func addCategory(title: String) throws {
        guard !categoryTitles.contains(title) else { return }
        let entity = TrackerCategoryCoreData(context: context)
        entity.title = title
        try context.save()
    }

    private func findOrCreateCategory(title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        if let existing = try context.fetch(request).first {
            return existing
        }
        let entity = TrackerCategoryCoreData(context: context)
        entity.title = title
        return entity
    }

    private func category(from entity: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = entity.title else { return nil }
        let trackers = (entity.trackers as? Set<TrackerCoreData> ?? [])
            .compactMap { trackerStore.tracker(from: $0) }
            .sorted { $0.name < $1.name }
        return TrackerCategory(title: title, trackers: trackers)
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate()
    }
}
