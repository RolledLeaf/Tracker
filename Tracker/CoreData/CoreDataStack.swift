import CoreData

final class CoreDataStack {

    static let shared = CoreDataStack() // Синглтон для удобства
    private init() {}

       lazy var persistentContainer: NSPersistentContainer = {
           let container = NSPersistentContainer(name: "TrackerDB")
           container.loadPersistentStores { storeDescription, error in
               if let error = error {
                   fatalError("Failed to load persistent stores: \(error)")
               }
           }
           return container
       }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }


    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }

    func registerColorValueTransformers() {
        let transformer = CollectionColorsTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName(rawValue: "CollectionColorsTransformer"))
    }
    
    func registerStringArrayTransformers() {
        let stringArrayTransformer = StringArrayTransformer()
        ValueTransformer.setValueTransformer(stringArrayTransformer, forName: NSValueTransformerName(rawValue: "StringArrayTransformer"))
    }

}


