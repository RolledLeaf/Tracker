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
    
   func getCategory(by index: Int) -> TrackerCategory? {
            let fetchRequest: NSFetchRequest<TrackerCategory> = TrackerCategory.fetchRequest()
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

