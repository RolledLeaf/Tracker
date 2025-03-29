import Foundation


final class TrackersViewModel {
    private var trackerStore = TrackerStore()
    
    private(set) var trackers: [TrackerCoreData] = [] {
        didSet {
            onTrackersUpdate?(trackers)
        }
    }
   
    var onTrackersUpdate: (([TrackerCoreData]) -> Void)?
    
    init(trackerStore: TrackerStore) {
        self.trackerStore = trackerStore
       
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        trackerStore.deleteTracker(at: indexPath)
       
    }
    
}
