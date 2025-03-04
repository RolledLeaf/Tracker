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
    func addNewTracker(name: String, selectedColor: CollectionColors, selectedEmoji: String, selectedWeekDays: [String], selectedCategory: String) throws
    func getTracker(by id: UUID) -> TrackerCoreData?
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
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "category.title", cacheName: nil)
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
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
        guard let inserted = insertedIndexes, let deleted = deletedIndexes else {
            return
        }
        
        let update = TrackerStoreUpdate(insertedIndexes: inserted, deletedIndexes: deleted)
        delegate?.didUpdate(update)
    }
    
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerStoreUpdate(
               insertedIndexes: IndexSet(),
               deletedIndexes: IndexSet()
           ))
       }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard  (insertedIndexes != nil),  (deletedIndexes != nil) else { return }
        print("📌 controllerDidChangeContent вызван")
           guard let inserted = insertedIndexes, let deleted = deletedIndexes else { return }
           
           print("🔹 Вставленные индексы: \(inserted)")
           print("🔹 Удалённые индексы: \(deleted)")
        delegate?.didUpdate(TrackerStoreUpdate(
            insertedIndexes: inserted,
            deletedIndexes: deleted
        )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
}

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
    
    func addNewTracker(name: String, selectedColor: CollectionColors, selectedEmoji: String, selectedWeekDays: [String], selectedCategory: String) throws {
        let tracker = TrackerCoreData(context: context)
        tracker.id = UUID()
        tracker.name = name
        tracker.color = selectedColor.rawValue as NSString
        tracker.emoji = selectedEmoji
        tracker.daysCount = 0
        tracker.weekDays = selectedWeekDays as NSObject
        
        let category = TrackerCategoryCoreData(context: context)
        category.title = selectedCategory
        category.addToTracker(tracker)
        
        try context.save()
    }
    
    func addNewIrregularTracker(name: String, selectedColor: CollectionColors, selectedEmoji: String, selectedDates: [Date], selectedCategory: String) throws {
        let tracker = TrackerCoreData(context: context)
        tracker.id = UUID()
        tracker.name = name
        tracker.color = selectedColor.rawValue as NSString
        tracker.emoji = selectedEmoji
        tracker.daysCount = 0
        tracker.weekDays = [" "] as NSArray
        
        let category = TrackerCategoryCoreData(context: context)
        category.title = selectedCategory
        category.addToTracker(tracker)
        
        try context.save()
    }
    
    func tracker(at indexPath: IndexPath) -> TrackerCoreData {
        return fetchedResultsController.object(at: indexPath)
    }
    
    
    func getTrackerByIndex(at indexPath: IndexPath) -> TrackerCoreData? {
        let objects = fetchedResultsController.fetchedObjects ?? []
        guard indexPath.row < objects.count else { return nil }
        return objects[indexPath.row]
    }
    
    func getTracker(by id: UUID) -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch tracker by id: \(error)")
            return nil
        }
    }
    
    func getTrackersForCategory(_ category: TrackerCategoryCoreData) -> [TrackerCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", category.title!)
        
        do {
            let trackers = try context.fetch(fetchRequest)
            return trackers
        } catch {
            print("Failed to fetch trackers for category \(category.title): \(error)")
            return []
        }
    }
    
}
