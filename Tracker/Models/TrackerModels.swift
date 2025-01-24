import Foundation

struct Tracker {
    let id: Int
    let name: String
    let color: CollectionColors
    let emoji: String
    let daysCount: Int
    let weekDays: [String]
}



struct TrackerCategory {
    let title: String
    let tracker: [Tracker]
}

struct TrackerRecord {
    let executedTracker: Tracker
    let date: Date
}
