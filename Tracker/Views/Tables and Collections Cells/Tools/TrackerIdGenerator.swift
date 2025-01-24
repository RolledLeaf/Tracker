import Foundation


final class TrackerIdGenerator {
    private static let trackerIdKey = "trackerIdKey"
    
    static func generateId() -> Int {
        let currentId = UserDefaults.standard.integer(forKey: trackerIdKey)
        let newId = currentId + 1
        UserDefaults.standard.set(newId, forKey: trackerIdKey)
        return newId
    }
}


