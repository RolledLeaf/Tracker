import CoreData
import UIKit


protocol TrackerRecordStoreProtocol {
    func getTrackerRecords(for trackerID: UUID) -> [TrackerRecordCoreData]
}


final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    
    // Инициализатор, который принимает контекст из CoreDataStack
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
        
        func createNewTrackerRecord(trackerID: UUID, date: Date) {
            let trackerRecord = TrackerRecordCoreData(context: context)
            trackerRecord.trackerID = trackerID
            trackerRecord.date = date
            saveContext()
        }
        
        func fetchAllTrackerRecords() -> [TrackerRecordCoreData] {
            let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
            do {
                let records = try context.fetch(fetchRequest)
                return records
            } catch {
                print("Error fetching tracker records: \(error)")
                return []
            }
        }
        
        
        
        
        func saveTrackerRecord(trackerID: UUID, date: Date) {
            let record = TrackerRecordCoreData(context: context)
            record.trackerID = trackerID
            record.date = date
            
            // Сохраняем изменения
            do {
                try context.save()
            } catch {
                print("Error saving tracker record: \(error)")
            }
        }
        
        
        func deleteTrackerRecord(_ record: TrackerRecordCoreData) {
            context.delete(record)
            do {
                try context.save()
            } catch {
                print("Error deleting tracker record: \(error)")
            }
        }
    }
}

extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func getTrackerRecords(for trackerID: UUID) -> [TrackerRecordCoreData] {
           guard let records = fetchedResultsController.fetchedObjects else { return [] }
           return records.filter { $0.trackerID == trackerID }
       }
    }
    
    

