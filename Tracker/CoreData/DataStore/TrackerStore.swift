import CoreData
import UIKit

final class TrackerStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func createNewTracker(id: Int16, name: String, color: CollectionColors, emoji: String, daysCount: Int16, weekDays: [String], category: TrackerCategory) {
        let tracker = Tracker(context: context)
        tracker.id = id
        tracker.name = name
        tracker.color = color.rawValue as NSString
        tracker.emoji = emoji
        tracker.daysCount = daysCount
        tracker.weekDays = weekDays as NSObject
        
        do {
               try context.save()
           } catch {
               print("Failed to save context: \(error)")
           }
    }
    
    
    
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
        
        func fetchAllTrackers() {
            let trackerFetchRequest: NSFetchRequest<Tracker> = Tracker.fetchRequest()
            
            do {
                let trackers = try CoreDataStack.shared.context.fetch(trackerFetchRequest)
                
                if trackers.isEmpty {
                    print("Нет трекеров в базе данных.")
                } else {
                    print("Найдено \(trackers.count) трекеров:")
                    for tracker in trackers {
                        print("Трекер: \(tracker.name ?? "Без названия"), Цвет: \(tracker.color ?? "Не задан" as NSObject), Эмодзи: \(tracker.emoji ?? "Не задан")")
                        print("Дни недели: \(tracker.weekDays ?? "Не заданы" as NSObject)")
                    }
                }
            } catch {
                print("Ошибка при извлечении трекеров из базы данных: \(error.localizedDescription)")
            }
        }
        
        // MARK: - Получение трекера по ID
        func fetchTrackerById(id: Int) -> Tracker? {
            let fetchRequest: NSFetchRequest<Tracker> = Tracker.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
            
            do {
                let trackers = try context.fetch(fetchRequest)
                return trackers.first
            } catch {
                print("Error fetching tracker by ID: \(error)")
                return nil
            }
        }
        
        // MARK: - Удаление трекера
        func deleteTracker(_ tracker: Tracker) {
            context.delete(tracker)
            saveContext()
        }
    }
}
