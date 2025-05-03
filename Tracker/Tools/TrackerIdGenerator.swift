import Foundation

final class TrackerIdGenerator {
    private static let trackerIdKey = "trackerIdKey"
    
    static func generateId() -> UUID {
        let newId = UUID()
        UserDefaults.standard.set(newId.uuidString, forKey: trackerIdKey)
        return newId
    }
}

func getDayWord(for count: Int16) -> String {
   let format = NSLocalizedString("daysCount", comment: "Количество дней")
   return String.localizedStringWithFormat(format, count)
}
