import CoreData
import UIKit

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
    
    func getTrackerByIndex(at indexPath: IndexPath) -> TrackerCoreData? {
        guard let category = self.getCategory(at: indexPath) else {
            print("❌ Категория не найдена для секции \(indexPath.section)")
            return nil
        }
        
        let trackers = category.tracker?.allObjects as? [TrackerCoreData] ?? []
        
        guard indexPath.item < trackers.count else {
            print("❌ Ошибка индекса: \(indexPath.item) для секции \(indexPath.section)")
            return nil
        }
        
        return trackers[indexPath.item]
    }
    
    
    func getCategory(at indexPath: IndexPath) -> TrackerCategoryCoreData? {
        let category = fetchedResultsController.object(at: indexPath)
        return category
    }
    
    func getTrackers(for indexPath: IndexPath) -> [TrackerCoreData]? {
        guard let category = getCategory(at: indexPath) else {
            return nil
        }
        
        // Преобразуем NSSet в массив трекеров
        let trackers = category.tracker?.allObjects as? [TrackerCoreData] ?? []
        return trackers
    }
    
    func getCategory(by index: Int) -> TrackerCategoryCoreData? {
            let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            do {
                let categories = try CoreDataStack.shared.context.fetch(fetchRequest)
                return categories.indices.contains(index) ? categories[index] : nil
            } catch {
                print("Failed to fetch categories: \(error)")
                return nil
            }
        }
    
    func createTrackerCategory(title: String) {
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
    
        
        do {
            try context.save()
        } catch {
            print("error saving new category: \(error)")
        }
    }
    
    func deleteTrackerCategory(_ category: TrackerCategoryCoreData) {
        context.delete(category)
        do {
            try context.save()
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
}

