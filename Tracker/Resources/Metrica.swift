import AppMetricaCore
 
enum AnalyticsEvent: String {
    case addTrackerButtonTapped = "User pressed add tracker button"
    case filterCompletedActive = "User activated completed trackers filter"
    case statisticsViewed = "Statistics view opened"
}

let metricaKey: String = "09742745-3d71-4136-b67c-a2d931f6e96a"


final class Analytics {
    
    static func logEvent(_ event: AnalyticsEvent) {
        AppMetrica.reportEvent(name: event.rawValue) { error in
            print("Did fail to report event: \(event.rawValue)")
            print("Report error: %@", error.localizedDescription)
        }
    }
}
