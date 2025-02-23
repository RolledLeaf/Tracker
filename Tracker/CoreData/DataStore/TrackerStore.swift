import CoreData
import UIKit

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func createNewTracker(id: Int16, name: String, color: CollectionColorsTransformer, emoji: String, daysCount: Int16, weekDays: [String]) {
        let tracker = Tracker(context: context)
        tracker.id = id
        tracker.name = name
        tracker.color = color
        tracker.emoji = emoji
        tracker.daysCount = daysCount
        tracker.weekDays = weekDays as NSObject
    }
}
