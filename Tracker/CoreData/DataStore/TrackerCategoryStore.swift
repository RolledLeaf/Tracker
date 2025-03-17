import CoreData

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    private let context: NSManagedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "title", // группируем по названию категории
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    
    func fetchAllTrackerCategories() -> [TrackerCategoryCoreData] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            let categories = try context.fetch(request)
            return categories
        } catch {
            print("error fetching categories: \(error)")
            return []
        }
    }
    
    func getCategory(at indexPath: IndexPath) -> TrackerCategoryCoreData? {
        let category = fetchedResultsController.object(at: indexPath)
        return category
    }
    
    func deleteTrackerCategory(_ category: TrackerCategoryCoreData) {
        context.delete(category)
        do {
            try context.save()
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
    
    func fetchCategories() -> [TrackerCategoryCoreData] {
            let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            do {
                return try context.fetch(request)
            } catch {
                print("Failed to fetch categories: \(error)")
                return []
            }
        }

    func saveCategory(name: String) {
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = name
            do {
                try context.save()
            } catch {
                print("Failed to save category: \(error)")
            }
        }
    
}

