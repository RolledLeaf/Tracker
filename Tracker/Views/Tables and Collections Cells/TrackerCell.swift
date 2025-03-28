import UIKit

protocol TrackerCategoryCellDelegate: AnyObject {
    func trackerExecution(_ cell: TrackerCell, didTapDoneButtonFor trackerID: UUID, selectedDate: Date)
}

final class TrackerCell: UICollectionViewCell, UIContextMenuInteractionDelegate {
    weak var delegate: TrackerCategoryCellDelegate?
    weak var viewController: TrackersViewController?
    
    static let reuseIdentifier = "TrackerCell"
    
    
    
    private var currentSelectedTracker: TrackerCoreData?
    private var trackerID: UUID?
    private var currentDate: Date = Date()
    private var selectedIndexPaths: Set<IndexPath> = []
    
    private lazy var habbitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.custom(.createButtonTextColor)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .black
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = UIColor.custom(.createButtonTextColor)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private var isChecked = false
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var doneButtonContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 17
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var backgroundContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        let interaction = UIContextMenuInteraction(delegate: self)
        contentView.addInteraction(interaction)
        
        let uiElements: [UIView] = [backgroundContainer, daysCountLabel, doneButtonContainer, doneButton]
        uiElements.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        uiElements.forEach { contentView.addSubview($0) }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doneButtonTapped))
        doneButtonContainer.addGestureRecognizer(tapGesture)
        doneButton.isUserInteractionEnabled = false
        
        let backgroundContainerElements: [UIView] = [habbitLabel, emojiContainer, emojiLabel]
        backgroundContainerElements.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        backgroundContainerElements.forEach { backgroundContainer.addSubview($0) }
        
        NSLayoutConstraint.activate([
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            daysCountLabel.heightAnchor.constraint(equalToConstant: 18),
            daysCountLabel.widthAnchor.constraint(equalToConstant: 101),
            
            doneButton.centerXAnchor.constraint(equalTo: doneButtonContainer.centerXAnchor),
            doneButton.centerYAnchor.constraint(equalTo: doneButtonContainer.centerYAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 12),
            doneButton.widthAnchor.constraint(equalToConstant: 12),
            
            doneButtonContainer.trailingAnchor.constraint(equalTo: backgroundContainer.trailingAnchor, constant: -12),
            doneButtonContainer.topAnchor.constraint(equalTo: backgroundContainer.bottomAnchor, constant: 8),
            doneButtonContainer.heightAnchor.constraint(equalToConstant: 34),
            doneButtonContainer.widthAnchor.constraint(equalToConstant: 34),
            
            backgroundContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundContainer.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainer.centerYAnchor),
            emojiLabel.heightAnchor.constraint(equalToConstant: 22),
            emojiLabel.widthAnchor.constraint(equalToConstant: 22),
            
            emojiContainer.topAnchor.constraint(equalTo: backgroundContainer.topAnchor, constant: 8),
            emojiContainer.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 8),
            emojiContainer.heightAnchor.constraint(equalToConstant: 24),
            emojiContainer.widthAnchor.constraint(equalToConstant: 24),
            
            habbitLabel.topAnchor.constraint(equalTo: backgroundContainer.topAnchor, constant: 44),
            habbitLabel.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 12),
            habbitLabel.trailingAnchor.constraint(equalTo: backgroundContainer.trailingAnchor, constant: -12)
        ])
    }
    
    func previewForHighlightingContextMenu(with configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: backgroundContainer.bounds, cornerRadius: 16)
        
        let preview = UITargetedPreview(view: backgroundContainer, parameters: parameters)
        return preview
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let viewController = viewController,
              let indexPath = viewController.categoriesCollectionView.indexPath(for: self)
        else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            let previewController = UIViewController()
            previewController.view.backgroundColor = .clear

            // Снимок с backgroundContainer, включая вложенные в него элементы
            let snapshot = self.backgroundContainer.snapshotView(afterScreenUpdates: true) ?? UIView()
            snapshot.layer.cornerRadius = 16
            snapshot.layer.masksToBounds = true
            snapshot.translatesAutoresizingMaskIntoConstraints = false

            previewController.view.addSubview(snapshot)
            NSLayoutConstraint.activate([
                snapshot.topAnchor.constraint(equalTo: previewController.view.topAnchor),
                snapshot.bottomAnchor.constraint(equalTo: previewController.view.bottomAnchor),
                snapshot.leadingAnchor.constraint(equalTo: previewController.view.leadingAnchor),
                snapshot.trailingAnchor.constraint(equalTo: previewController.view.trailingAnchor)
            ])

            // Размер превью совпадает с backgroundContainer
            previewController.preferredContentSize = self.backgroundContainer.bounds.size
            return previewController
        }, actionProvider: { _ in
            let isPinned = viewController.ifTrackerPinned
            let pinTitle = isPinned ? "Открепить" : "Закрепить"
            
            let pinAction = UIAction(title: pinTitle, image: UIImage(systemName: "pin")) { _ in
                viewController.pinTracker(at: indexPath)
            }
            
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                viewController.editTracker(at: indexPath)
            }
            
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                viewController.deleteTracker(at: indexPath)
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        })
    }
    
    private func getDayWord(for count: Int16) -> String {
        let format = NSLocalizedString("daysCount", comment: "Количество дней")
        return String.localizedStringWithFormat(format, count)
    }
    
    func configure(with tracker: TrackerCoreData, trackerRecords: [TrackerRecordCoreData]) {
        currentSelectedTracker = tracker
        trackerID = tracker.id
        emojiLabel.text = tracker.emoji
        habbitLabel.text = tracker.name
        
        let defaultColor = "collectionPalePurple17"
        let trackerColor = UIColor.fromCollectionColor(tracker.color as? String ?? defaultColor) ?? .clear
        
        backgroundContainer.backgroundColor = trackerColor
        doneButtonContainer.backgroundColor = trackerColor
        emojiContainer.backgroundColor = lightenColor(trackerColor, by: 0.3)
        
        let currentDate = Date()
        let isCompleted = trackerRecords.contains { $0.trackerID == tracker.id && Calendar.current.isDate($0.date ?? currentDate, inSameDayAs: viewController?.selectedDate ?? currentDate) }
        
        doneButton.setImage(UIImage(systemName: isCompleted ? "checkmark" : "plus"), for: .normal)
        
        let baseColor = trackerColor
        let adjustedColor = isCompleted ? lightenColor(baseColor, by: 0.3) : baseColor
        doneButtonContainer.backgroundColor = adjustedColor
        
        let daysCount = tracker.daysCount
        daysCountLabel.text = getDayWord(for: daysCount)
    }
    
    @objc func doneButtonTapped() {
        guard let trackerID = trackerID else {
            return
        }
        
        guard let selectedDate = viewController?.getSelectedDate() else {
            print("Date Picker is not set!")
            return
        }
        delegate?.trackerExecution(self, didTapDoneButtonFor: trackerID, selectedDate: selectedDate)
    }
}

