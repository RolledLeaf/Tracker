import Foundation

struct StatisticsData {
    let bestPeriod: Int
    let perfectDays: Int
    let completedTrackers: Int
    let averageValue: Int
}

final class StatisticsViewModel {
    
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    var onStatisticsCalculated: ((StatisticsData) -> Void)?
    
    func calculateStatistics() {
        let records = trackerRecordStore.fetchAllRecords()
        let allTrackers = trackerStore.fetchAllTrackers()
        let calendar = Calendar.current

        let groupedByDate = Dictionary(grouping: records) { $0.date?.startOfDay ?? Date() }
        let completedTrackers = records.count

        let bestPeriod = groupedByDate.values.map { $0.count }.max() ?? 0

        let perfectDays = groupedByDate.filter { (date, recordsForDate) in
            let weekday = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            let expectedTrackers = allTrackers.filter {
                guard let days = $0.weekDays as? [String] else { return false }
                return days.contains(weekday) || days.contains(" ")
            }

            let performedTrackerIDs = Set(recordsForDate.compactMap { $0.trackerID })
            let expectedTrackerIDs = Set(expectedTrackers.compactMap { $0.id })

            return performedTrackerIDs == expectedTrackerIDs
        }.count

        let daysPerformed = groupedByDate.count
        let averageValue = daysPerformed > 0 ? Int(completedTrackers) / Int(daysPerformed) : 0

        let result = StatisticsData(
            bestPeriod: bestPeriod,
            perfectDays: perfectDays,
            completedTrackers: completedTrackers,
            averageValue: averageValue
        )
        onStatisticsCalculated?(result)
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
