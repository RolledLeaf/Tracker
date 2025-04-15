import XCTest
import CoreData

@testable import Tracker

final class TrackerStoreTests: XCTestCase {
    
    var trackerStore: TrackerStore?
    var context: NSManagedObjectContext?
    
    override func setUp() {
        super.setUp()
        
        let expectation = self.expectation(description: "Persistent store loaded")
        
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores { _, error in
            if let error = error {
                XCTFail("Failed to load persistent stores: \(error)")
            } else {
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5.0) { error in
            if let error = error {
                XCTFail("Timeout waiting for persistent store: \(error)")
            }
        }
        
        context = container.viewContext
        
        if let context = context {
            trackerStore = TrackerStore(context: context)
        } else {
            XCTFail("Context is nil in setUp")
        }
    }
    
    override func tearDown() {
        super.tearDown()
        context = nil
        trackerStore = nil
    }
    
    func testFetchAllTrackers() {
        
        //Arrange
        guard let context = context else {
            return XCTFail("Failed to create context")
        }
        let tracker1 = TrackerCoreData(context: context)
        tracker1.name = "TestTracker1"
        tracker1.emoji = "😄"
        tracker1.color = "#FFFFFF" as NSObject
        tracker1.weekDays = ["Mon"] as NSObject
        
        let tracker2 = TrackerCoreData(context: context)
        tracker2.name = "TestTracker2"
        tracker2.emoji = "😄"
        tracker2.color = "#FFFFFF" as NSObject
        tracker2.weekDays = ["Mon", "Tue"] as NSObject
        
        do {
            try context.save()
        } catch {
            XCTFail("Failed to save context")
        }
            
        //Act
        guard let trackers = trackerStore?.fetchAllTrackers() else {
            return XCTFail("Failed to fetch all trackers")
        }
        
        //Assert
        XCTAssertEqual(trackers.count, 2)
        
        }
        
    }
    
