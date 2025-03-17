

class CategoriesListViewModel {
    private let categoryStore: TrackerCategoryStore
    private(set) var categories: [TrackerCategoryCoreData] = [] {
        didSet {
            onCategoriesUpdate?(categories)
        }
    }

    var onCategoriesUpdate: (([TrackerCategoryCoreData]) -> Void)?
    var onCategorySelected: ((TrackerCategoryCoreData) -> Void)?

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
}
