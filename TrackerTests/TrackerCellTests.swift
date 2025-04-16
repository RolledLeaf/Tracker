import XCTest
import CoreData
@testable import Tracker

private func makeInMemoryContainer(name: String = "TrackerDB") -> NSPersistentContainer {
    let container = NSPersistentContainer(name: name)
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    container.persistentStoreDescriptions = [description]
    
    container.loadPersistentStores { _, error in
        XCTAssertNil(error)
    }
    return container
}
    
    final class TrackerCellTests: XCTestCase {
        
        func testGetDayWord() {
            let cell = TrackerCell()
            
            let oneDayWord = "1 day"
            let twoDaysWord = "2 days"
            
            XCTAssertEqual(cell.getDayWord(for: 1), oneDayWord)
            XCTAssertEqual(cell.getDayWord(for: 2), twoDaysWord)
        }
        
        func testCellConfiguration() {
            let container = makeInMemoryContainer()
            let context = container.viewContext
            
            let tracker = TrackerCoreData(context: context)
            tracker.id = UUID()
            tracker.name = "Test"
            tracker.emoji = "😄"
            tracker.color = "collectionRed1" as NSObject
            tracker.daysCount = 3
            
            let category = TrackerCategoryCoreData(context: context)
            category.title = "Закреплённые"
            tracker.category = category
            
            let record = TrackerRecordCoreData(context: context)
            record.date = Date()
            record.trackerID = tracker.id
            
            let cell = TrackerCell()
            cell.configure(with: tracker, trackerRecords: [record])
            
            XCTAssertEqual(cell.emojiLabel.text, "😄")
            XCTAssertEqual(cell.habitLabel.text, "Test")
            XCTAssertFalse(cell.pinImageView.isHidden)
            
        }
    }
