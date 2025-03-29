import CoreData

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    private let context: NSManagedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "title",
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
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "title != %@", "Закреплённые") // исключаем
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Ошибка получения категорий: \(error)")
            return []
        }
    }
    
    func getOrCreatePinnedCategory() -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", "Закреплённые")
        fetchRequest.fetchLimit = 1
        do {
            if let category = try context.fetch(fetchRequest).first {
                return category
            } else {
                let newCategory = TrackerCategoryCoreData(context: context)
                newCategory.title = "Закреплённые"
                newCategory.sortOrder = 0
                try context.save()
                return newCategory
            }
        } catch {
            print("Ошибка при получении/создании категории 'Закреплённые': \(error)")
            return nil
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
    
    func saveChanges() {
        do {
            try context.save()
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
    
}
