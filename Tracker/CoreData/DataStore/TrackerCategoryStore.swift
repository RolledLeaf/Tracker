import CoreData
import UIKit

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func fetchAllTrackerCategories() -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategory> = TrackerCategory.fetchRequest()
        do {
            let categories = try context.fetch(request)
            return categories
        } catch {
            print("error fetching categories: \(error)")
            return []
        }
    }
    
    func createTrackerCategory(title: String) {
        let category = TrackerCategory(context: context)
        category.title = title
    
        
        do {
            try context.save()
        } catch {
            print("error saving new category: \(error)")
        }
    }
    
    func deleteTrackerCategory(_ category: TrackerCategory) {
        context.delete(category)
        do {
            try context.save()
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
}

