import CoreData
import UIKit

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    
    // Инициализатор, который принимает контекст из CoreDataStack
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    // Пример метода для получения всех записей трекеров
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

    // Пример метода для создания новой записи
    func saveTrackerRecord(trackerID: Int16, date: Date) {
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

    // Пример метода для удаления записи
    func deleteTrackerRecord(_ record: TrackerRecord) {
        context.delete(record)
        do {
            try context.save()
        } catch {
            print("Error deleting tracker record: \(error)")
        }
    }
}
