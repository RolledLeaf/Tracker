import CoreData

protocol TrackerRecordStoreProtocol {
    func getTrackerRecords(for trackerID: UUID) -> [TrackerRecordCoreData]
}

final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func fetchAllRecords() -> [TrackerRecordCoreData] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch: \(error)")
        }
        return []
    }
}
