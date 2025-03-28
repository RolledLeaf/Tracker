import CoreData

protocol TrackerRecordStoreProtocol {
    func getTrackerRecords(for trackerID: UUID) -> [TrackerRecordCoreData]
}

final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
}


