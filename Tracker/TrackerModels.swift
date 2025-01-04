import Foundation

struct Tracker {
    let id: String
    let name: String
    let color: CollectionColors
    let emoji: String
    let schedule: TrackerSchedule
    
    
    struct TrackerSchedule {
        let daysCount: Int
        let dayDays: String
    }
}


struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecord {
    let executedTracker: Tracker
    let date: Date
}
