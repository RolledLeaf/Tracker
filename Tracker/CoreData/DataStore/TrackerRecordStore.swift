import CoreData
import UIKit

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    
    // Инициализатор, который принимает контекст из CoreDataStack
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
        
        func createNewTrackerRecord(trackerID: UUID, date: Date) {
            let trackerRecord = TrackerRecord(context: context)
            trackerRecord.trackerID = trackerID
            trackerRecord.date = date
            saveContext()
        }
        
        func fetchAllTrackerRecords() -> [TrackerRecord] {
            let fetchRequest: NSFetchRequest<TrackerRecord> = TrackerRecord.fetchRequest()
            do {
                let records = try context.fetch(fetchRequest)
                return records
            } catch {
                print("Error fetching tracker records: \(error)")
                return []
            }
        }
        
        
        func saveTrackerRecord(trackerID: UUID, date: Date) {
            let record = TrackerRecord(context: context)
            record.trackerID = trackerID
            record.date = date
            
            // Сохраняем изменения
            do {
                try context.save()
            } catch {
                print("Error saving tracker record: \(error)")
            }
        }
        
        
        func deleteTrackerRecord(_ record: TrackerRecord) {
            context.delete(record)
            do {
                try context.save()
            } catch {
                print("Error deleting tracker record: \(error)")
            }
        }
    }
}
