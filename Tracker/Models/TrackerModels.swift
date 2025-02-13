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
    let trackerID: Int
    let date: Date
}

 var shortWeekdaySymbols: [String] = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
