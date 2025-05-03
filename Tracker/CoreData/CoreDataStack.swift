import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerDB")
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                assertionFailure("⚠️ Failed to load persistent stores: \(error)")
                print("❌ Ошибка загрузки хранилища: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    private func registerColorValueTransformers() {
        let transformer = CollectionColorsTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName(rawValue: "CollectionColorsTransformer"))
    }
    
    private func registerStringArrayTransformers() {
        let stringArrayTransformer = StringArrayTransformer()
        ValueTransformer.setValueTransformer(stringArrayTransformer, forName: NSValueTransformerName(rawValue: "StringArrayTransformer"))
    }
}
