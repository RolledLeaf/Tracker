import CoreData

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol {
    var numberOfSections: Int { get }
    var numberOfTrackers: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func getSectionTitle(for section: Int) -> String
}

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    
    enum TrackerStoreError: Error {
        case failedToInitializeContext
    }
    
    weak var delegate: TrackerStoreDelegate?
    private let context: NSManagedObjectContext
    private let trackerCategoryStore = TrackerCategoryStore()
    private let collectionColorsTransformer = CollectionColorsTransformer()
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "category.sortOrder", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func fetchAllTrackers() -> [TrackerCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("❌ Ошибка загрузки трекеров: \(error)")
            return []
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
   
    func editTracker(at indexPath: IndexPath, with newData: TrackerEditData) {
        let tracker = fetchedResultsController.object(at: indexPath)
        tracker.name = newData.name
        tracker.emoji = newData.emoji
        tracker.color = newData.color as NSString
        tracker.daysCount = newData.daysCount

        do {
            try context.save()
            print("✏️ Трекер отредактирован: \(tracker.name ?? "Без имени")")
        } catch {
            print("❌ Ошибка при редактировании трекера: \(error)")
        }
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        let tracker = fetchedResultsController.object(at: indexPath)
        let trackerName = tracker.name ?? "Без имени"
        
        context.delete(tracker)
        
        do {
            try context.save()
            print("🗑 Трекер '\(trackerName)' удалён через TrackerStore")
        } catch {
            print("❌ Ошибка удаления трекера: \(error.localizedDescription)")
        }
    }
    
   func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexes?.insert(newIndexPath.item)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
        
        guard let inserted = insertedIndexes, let deleted = deletedIndexes else { return }
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let inserted = insertedIndexes ?? IndexSet()
        let deleted = deletedIndexes ?? IndexSet()

        print("📌 controllerDidChangeContent вызван")
        print("🔹 Вставленные индексы: \(inserted)")
        print("🔹 Удалённые индексы: \(deleted)")

        delegate?.didUpdate(TrackerStoreUpdate(insertedIndexes: inserted, deletedIndexes: deleted))

        insertedIndexes = nil
        deletedIndexes = nil
    }
}

// MARK: - TrackerStoreProtocol

extension TrackerStore: TrackerStoreProtocol {
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    var numberOfTrackers: Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func getSectionTitle(for section: Int) -> String {
        return fetchedResultsController.sections?[section].name ?? "Без категории"
    }
}


struct TrackerEditData {
    let name: String
    let emoji: String
    let color: String
    let daysCount: Int16
}
