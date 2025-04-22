import XCTest
@testable import Tracker
import CoreData

final class MockingTrackerStore: TrackerStoreMethodsProtocol {
    
    var deletedTracker: TrackerCoreData?
    var mockTrackers: [TrackerCoreData] = []
    
    func deleteTracker(at indexPath: IndexPath) {
        deletedTracker = mockTrackers.remove(at: indexPath.row)
    }
}

    final class TrackersViewModelTest: XCTestCase {
        
        func makeInMemoryContainer() -> NSPersistentContainer {
            guard let modelURL = Bundle.main.url(forResource: "TrackerDB", withExtension: "momd"),
                  let model = NSManagedObjectModel(contentsOf: modelURL) else {
                XCTFail("Не удалось загрузить модель TrackerDB.momd")
                return NSPersistentContainer(name: "Fallback") // безопасный возврат
            }
            
            let container = NSPersistentContainer(name: UUID().uuidString, managedObjectModel: model)
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
            container.loadPersistentStores { description, error in
                XCTAssertNil(error)
                XCTAssertEqual(description.type, NSInMemoryStoreType, "Persistent store должен быть in-memory")
            }
            return container
        }
        
        func testLoadUserDefaults() {
            let mockTrackerStore = MockingTrackerStore()
            let viewModel = TrackersViewModel(trackerStore: mockTrackerStore)
            
            UserDefaults.standard.set(TrackerFilterType.all.rawValue, forKey: UserDefaultsKeys.selectedFilter)
            
            viewModel.loadUserDefaultsFilter()
            
            XCTAssertEqual(viewModel.selectedFilter, .all, "Фильтр должен быть загружен из UserDefaults")
        }
        
        func testDeleteTracker() {
            let container = makeInMemoryContainer()
            let context = container.viewContext
            let dummyTracker = TrackerCoreData(context: context)
            dummyTracker.name = "Test"
            
            let mockTrackerStore = MockingTrackerStore()
            mockTrackerStore.mockTrackers = [dummyTracker]
            
            let viewModel = TrackersViewModel(trackerStore: mockTrackerStore)
           
            
            let indexPath = IndexPath(row: 0, section: 0)
            viewModel.deleteTracker(at: indexPath)
            
            XCTAssertEqual(mockTrackerStore.deletedTracker, dummyTracker)
            XCTAssertEqual(mockTrackerStore.mockTrackers.count, 0)
        }
        
        func testAddTracker() {
            let container = makeInMemoryContainer()
            let context = container.viewContext
            
            let dummyTracker1 = TrackerCoreData(context: context)
            dummyTracker1.name = "Test1"
            let dummyTracker2 = TrackerCoreData(context: context)
            dummyTracker2.name = "Test2"
            let mockTrackerStore = MockingTrackerStore()
            mockTrackerStore.mockTrackers = [dummyTracker1, dummyTracker2]
            
         
            let newTracker1 = TrackerCoreData(context: context)
            mockTrackerStore.mockTrackers.append(newTracker1)
            
            XCTAssertEqual(mockTrackerStore.mockTrackers.count, 3)
        }
    }
    

