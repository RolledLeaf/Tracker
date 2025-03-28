class CategoriesViewModel {
    private let categoryStore: TrackerCategoryStore
    
    private(set) var categories: [TrackerCategoryCoreData] = [] {
        didSet {
            onCategoriesUpdate?(categories)
        }
    }

    var onCategoriesUpdate: (([TrackerCategoryCoreData]) -> Void)?
    var onCategorySelected: ((TrackerCategoryCoreData) -> Void)?
    var onEditCategoryRequest: ((TrackerCategoryCoreData, String) -> Void)?

    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        fetchCategories()
    }

    func fetchCategories() {
        categories = categoryStore.fetchCategories()
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
