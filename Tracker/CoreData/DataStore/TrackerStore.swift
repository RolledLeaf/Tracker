import CoreData

struct TrackerStoreUpdate {
    let insertedIndexPaths: [IndexPath]
    let deletedIndexPaths: [IndexPath]
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}


protocol TrackerStoreProtocol {
    var numberOfSections: Int { get }
    var numberOfTrackers: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func addNewTracker(_ tracker: Tracker, toCategory category: TrackerCategory) throws
    func getTracker(by id: UUID) -> Tracker?
  
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
  
    private lazy var fetchedResultsController: NSFetchedResultsController<Tracker> = {
        
        let fetchRequest = NSFetchRequest<Tracker>(entityName: "Tracker")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "category.title", cacheName: nil)
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    var numberOfSections: Int {
           return fetchedResultsController.sections?.count ?? 0
       }
       
       var numberOfTrackers: Int {
           return fetchedResultsController.fetchedObjects?.count ?? 0
       }
       
       func numberOfRowsInSection(_ section: Int) -> Int {
           return fetchedResultsController.sections?[section].numberOfObjects ?? 0
       }
       
    func addNewTracker(name: String, selectedColor: CollectionColors, selectedEmoji: String, selectedWeekDays: [String], selectedCategory: String) throws {
            let tracker = Tracker(context: context)
            tracker.id = UUID()
            tracker.name = name
            tracker.color = selectedColor.rawValue as NSString
            tracker.emoji = selectedEmoji
            tracker.daysCount = 0
            tracker.weekDays = selectedWeekDays as NSObject
            
            let category = TrackerCategory(context: context)
            category.title = selectedCategory
            category.addToTracker(tracker)
            
            try context.save()
        }
    
    func addNewIrregularTracker(name: String, selectedColor: CollectionColors, selectedEmoji: String, selectedDates: [Date], selectedCategory: String) throws {
        let tracker = Tracker(context: context)
        tracker.id = UUID()
        tracker.name = name
        tracker.color = selectedColor.rawValue as NSString
        tracker.emoji = selectedEmoji
        tracker.daysCount = 0
        tracker.weekDays = [" "] as NSArray
        
        let category = TrackerCategory(context: context)
        category.title = selectedCategory
        category.addToTracker(tracker)
        
        try context.save()
    }
       
       func getTracker(by id: UUID) -> Tracker? {
           let fetchRequest: NSFetchRequest<Tracker> = Tracker.fetchRequest()
           fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
           fetchRequest.fetchLimit = 1
           
           do {
               return try context.fetch(fetchRequest).first
           } catch {
               print("Failed to fetch tracker by id: \(error)")
               return nil
           }
       }
       
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            var insertedIndexPaths: [IndexPath] = []
            var deletedIndexPaths: [IndexPath] = []

            switch type {
            case .insert:
                if let newIndexPath = newIndexPath {
                    insertedIndexPaths.append(newIndexPath)
                }
            case .delete:
                if let indexPath = indexPath {
                    deletedIndexPaths.append(indexPath)
                }
            default:
                break
            }

            let update = TrackerStoreUpdate(insertedIndexPaths: insertedIndexPaths, deletedIndexPaths: deletedIndexPaths)
            delegate?.didUpdate(update)
        }
    }
