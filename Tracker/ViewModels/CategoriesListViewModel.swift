class CategoriesViewModel {
    private let categoryStore: TrackerCategoryStoreProtocol
    
    private(set) var categories: [TrackerCategoryCoreData] = [] {
        didSet {
            onCategoriesUpdate?(categories)
        }
    }
    var selectedFilter: TrackerFilterType = .all {
        didSet {
            onFilterChanged?(selectedFilter)
        }
    }
    var onFilterChanged: ((TrackerFilterType) -> Void)?
    var onCategoriesUpdate: (([TrackerCategoryCoreData]) -> Void)?
    var onCategorySelected: ((TrackerCategoryCoreData) -> Void)?
    var onEditCategoryRequest: ((TrackerCategoryCoreData, String) -> Void)?

    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
        fetchCategories()
    }

    func fetchCategories() {
        categories = categoryStore.fetchAllTrackerCategories()
    }

    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        let selectedCategory = categories[index]
        onCategorySelected?(selectedCategory)
    }

    func addCategory(name: String) {
        categoryStore.saveCategory(name: name)
        fetchCategories()
    }
    
    func deleteCategory(at index: Int) {
        guard index < categories.count else { return }
        let category = categories[index]

        categoryStore.deleteTrackerCategory(category)
        fetchCategories()
    }
    
    func editCategory(at index: Int, newName: String) {
        guard index < categories.count else { return }
        let category = categories[index]
        onEditCategoryRequest?(category, category.title ?? "")
    }

    func updateCategoryName(at index: Int, newName: String) {
        guard index < categories.count else { return }
        let category = categories[index]
        category.title = newName
        categoryStore.saveChanges()
        fetchCategories()
    }
}
