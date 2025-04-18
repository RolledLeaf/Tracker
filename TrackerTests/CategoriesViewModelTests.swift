import XCTest
import CoreData
@testable import Tracker

final class MockingCategoryStore: TrackerCategoryStoreProtocol {
    
    var fetchCalled = false
    var saveCalledWithName: String?
    var deletedCategory: TrackerCategoryCoreData?
    var savedChanges = false
    var saveChangesCalled = false
    var addedCategoryName: String?
    var updatedCategoryName: (category: TrackerCategoryCoreData, newName: String)?
    var mockCategories: [TrackerCategoryCoreData] = []
    
    func fetchAllTrackerCategories() -> [TrackerCategoryCoreData] {
        fetchCalled = true
        return mockCategories
    }
    
    func saveCategory(name: String) {
        saveCalledWithName = name
        addedCategoryName = name
    }
    
    func deleteTrackerCategory(_ category: TrackerCategoryCoreData) {
        deletedCategory = category
        mockCategories.removeAll { $0 == category }
    }
    
    func saveChanges() {
        savedChanges = true
        saveChangesCalled = true
    }
}

final class CategoriesViewModelTests: XCTestCase {
    
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
    
    func testFetchCategoriesCallsStore() {
        
        //Given
        let container = makeInMemoryContainer()
        let context = container.viewContext
        
        let dummyCategory = TrackerCategoryCoreData(context: context)
        dummyCategory.title = "Test"
        
        let mockStore = MockingCategoryStore()
        
        mockStore.mockCategories = [dummyCategory]
        
        var updatedCategories: [TrackerCategoryCoreData] = []
        
        let viewModel = CategoriesViewModel(categoryStore: mockStore)
        viewModel.onCategoriesUpdate = { categories in
            updatedCategories = categories
        }
        
        //When
        viewModel.fetchCategories()
        print("Обновлённые категории:")
        updatedCategories.forEach { print($0.title ?? "Без названия") }
        
        //Then
        XCTAssertTrue(mockStore.fetchCalled, "Метод fetch был вызван")
        XCTAssertEqual(updatedCategories.count, 1, "Должна быть одна категория")
        XCTAssertEqual(updatedCategories.first?.title ?? "No name", "Test", "Название категории должно быть Test")
    }
    
    func testAddCategoryAddsCategoryAndFetches() {
        
        let container = makeInMemoryContainer()
        let context = container.viewContext
        
        let mockStore = MockingCategoryStore()
        let viewModel = CategoriesViewModel(categoryStore: mockStore)
        
        let newCategoryName = "New Category"
        let dummyCategory = TrackerCategoryCoreData(context: context)
        dummyCategory.title = newCategoryName
        mockStore.mockCategories = [dummyCategory]
        
        var updatedCategories: [TrackerCategoryCoreData] = []
        viewModel.onCategoriesUpdate = { categories in
            updatedCategories = categories
        }
        
        viewModel.addCategory(name: newCategoryName)
        
        XCTAssertEqual(mockStore.addedCategoryName, newCategoryName, "Имена категорий должны совпадать")
        XCTAssertTrue(mockStore.fetchCalled, "Функция fetch должна быть вызвана")
        XCTAssertEqual(updatedCategories.first?.title, newCategoryName)
    }
    
    func testUpdateCategoryNameUpdatesTitleAndSaves() {
        let container = makeInMemoryContainer()
        let context = container.viewContext
        
        let originalCategoryName = "Original Category"
        let updatedCategoryName = "Updated Category"
        
        let dummyCategory = TrackerCategoryCoreData(context: context)
        dummyCategory.title = originalCategoryName
        
        let mockStore = MockingCategoryStore()
        mockStore.mockCategories = [dummyCategory]
        
        let viewModel = CategoriesViewModel(categoryStore: mockStore)
        
        
        var updatedCategories: [TrackerCategoryCoreData] = []
        viewModel.onCategoriesUpdate = { categories in
            updatedCategories = categories
        }
        
        viewModel.updateCategoryName(at: 0, newName: updatedCategoryName)
        
        XCTAssertEqual(updatedCategories.first?.title, updatedCategoryName)
        XCTAssertTrue(mockStore.saveChangesCalled, "Метод saveChanges не был вызван")
    }
    
    func testSelectCategoryCallsCallbackWithCorrectCategory() {
        let container = makeInMemoryContainer()
        let context = container.viewContext
        
        let expectedCategory = TrackerCategoryCoreData(context: context)
        expectedCategory.title = "Selectable Category"
        
        let mockStore = MockingCategoryStore()
        mockStore.mockCategories = [expectedCategory]
        
        let viewModel = CategoriesViewModel(categoryStore: mockStore)
        
        var selectedCategory: TrackerCategoryCoreData?
        viewModel.onCategorySelected = { category in
            selectedCategory = category
        }
        
        viewModel.selectCategory(at: 0)
        
        XCTAssertEqual(selectedCategory?.title, expectedCategory.title)
        XCTAssertNotNil(selectedCategory)
    }
    
    func testEditCategoryCallsCallbackWithCorrectCategory() {
        let container = makeInMemoryContainer()
        let context = container.viewContext
        
        let originCategoryName = "Origin Category Name"
        
        let dummyCategory = TrackerCategoryCoreData(context: context)
        dummyCategory.title = originCategoryName
        
        let mockStore = MockingCategoryStore()
        mockStore.mockCategories = [dummyCategory]
        
        let viewModel = CategoriesViewModel(categoryStore: mockStore)
        
        var recievedCategory: TrackerCategoryCoreData?
        var recievedCategoryName: String?
        
        viewModel.onEditCategoryRequest = { category, name in
            recievedCategory = category
            recievedCategoryName = name
        }
        
        viewModel.editCategory(at: 0, newName: "New Category Name")
        
        XCTAssertEqual(recievedCategory?.title, originCategoryName)
        XCTAssertEqual(recievedCategoryName, originCategoryName)
    }
    
    func testDeleteCategoryDeletesCategoryandFetches() {
        let container = makeInMemoryContainer()
        let context = container.viewContext
        
        let categoryToDelete = "TargetCategory"
        
        let dummyCategory = TrackerCategoryCoreData(context: context)
        dummyCategory.title = categoryToDelete
        
        let mockStore = MockingCategoryStore()
        mockStore.mockCategories = [dummyCategory]
        
        let viewModel = CategoriesViewModel(categoryStore: mockStore)
        
        var updatedCategories: [TrackerCategoryCoreData] = []
        viewModel.onCategoriesUpdate = { categories in
            updatedCategories = categories
        }
        
        viewModel.deleteCategory(at: 0)
        
        XCTAssertEqual(updatedCategories.count, 0)
        XCTAssertTrue(mockStore.fetchCalled)
    }
}
