import Foundation

final class TrackersViewModel {
    private var trackerStore = TrackerStore()
    
    private(set) var trackers: [TrackerCoreData] = [] {
        didSet {
            onTrackersUpdate?(trackers)
        }
    }
    
    var onTrackersUpdate: (([TrackerCoreData]) -> Void)?
    
    var onFilterChanged: ((TrackerFilterType) -> Void)?
    var selectedFilter: TrackerFilterType = .all {
        didSet {
            onFilterChanged?(selectedFilter)
        }
    }
    
    init(trackerStore: TrackerStore) {
        self.trackerStore = trackerStore
        loadUserDefaultsFilter()
    }
    
    func loadUserDefaultsFilter() {
        if let savedFilter = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedFilter),
           let filter = TrackerFilterType(rawValue: savedFilter) {
            self.selectedFilter = filter
        } else {
            self.selectedFilter = .all
        }
        print("Filter \(selectedFilter) loaded from UserDefaults")
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        trackerStore.deleteTracker(at: indexPath)
    }
}
