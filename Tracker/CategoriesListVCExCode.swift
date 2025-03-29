//func previewForHighlightingContextMenu(with configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
//    let parameters = UIPreviewParameters()
//    parameters.backgroundColor = .clear
//    parameters.visiblePath = UIBezierPath(roundedRect: backgroundContainer.bounds, cornerRadius: 16)
//    
//    let preview = UITargetedPreview(view: backgroundContainer, parameters: parameters)
//    return preview
//}
//
//func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//    guard let viewController = viewController,
//          let indexPath = viewController.categoriesCollectionView.indexPath(for: self)
//    else { return nil }
//    
//    return UIContextMenuConfiguration(identifier: nil, previewProvider: {
//        let previewController = UIViewController()
//        previewController.view.backgroundColor = .clear
//
//        let snapshot = self.backgroundContainer.snapshotView(afterScreenUpdates: true) ?? UIView()
//        snapshot.layer.cornerRadius = 16
//        snapshot.layer.masksToBounds = true
//        snapshot.translatesAutoresizingMaskIntoConstraints = false
//
//        previewController.view.addSubview(snapshot)
//        NSLayoutConstraint.activate([
//            snapshot.topAnchor.constraint(equalTo: previewController.view.topAnchor),
//            snapshot.bottomAnchor.constraint(equalTo: previewController.view.bottomAnchor),
//            snapshot.leadingAnchor.constraint(equalTo: previewController.view.leadingAnchor),
//            snapshot.trailingAnchor.constraint(equalTo: previewController.view.trailingAnchor)
//        ])
//
//   
//        previewController.preferredContentSize = self.backgroundContainer.bounds.size
//        return previewController
//    }, actionProvider: { _ in
//        let isPinned = viewController.ifTrackerPinned
//        let pinTitle = isPinned ? "Открепить" : "Закрепить"
//        
//        let pinAction = UIAction(title: pinTitle, image: nil) { _ in
//            viewController.pinTracker(at: indexPath)
//        }
//        
//        let editAction = UIAction(title: "Редактировать", image: nil) { _ in
//            viewController.editTracker(at: indexPath)
//        }
//        
//        let deleteAction = UIAction(title: "Удалить", image: nil, attributes: .destructive) { _ in
//            viewController.deleteTracker(at: indexPath)
//        }
//        
//        return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
//    })
//}
