import CoreData
import UIKit

protocol FetchedResultsControllerDelegate: AnyObject {
    func didChangeContent()
}

class TrackersFetchedResultsController: NSObject, NSFetchedResultsControllerDelegate {
    private var fetchedResultsController: NSFetchedResultsController<Tracker>
    weak var delegate: FetchedResultsControllerDelegate?

    init(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Tracker> = Tracker.fetchRequest()
        let categorySort = NSSortDescriptor(key: "category.title", ascending: true)
        let nameSort = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [categorySort, nameSort]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        super.init()
        fetchedResultsController.delegate = self
        performFetch()
    }

    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка загрузки данных: \(error)")
        }
    }

    func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func numberOfItems(in section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func object(at indexPath: IndexPath) -> Tracker {
        return fetchedResultsController.object(at: indexPath)
    }

    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateData()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                delegate?.didInsertItem(at: newIndexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                delegate?.didDeleteItem(at: indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                delegate?.didUpdateItem(at: indexPath)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                delegate?.didMoveItem(from: indexPath, to: newIndexPath)
            }
        @unknown default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateData()
    }
}
