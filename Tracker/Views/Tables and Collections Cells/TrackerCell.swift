import UIKit

protocol TrackerCategoryCellDelegate: AnyObject {
    func trackerExecution(_ cell: TrackerCell, didTapDoneButtonFor trackerID: Int, selectedDate: Date)
}

final class TrackerCell: UICollectionViewCell {
    weak var delegate: TrackerCategoryCellDelegate?
    weak var viewController: TrackersViewController?
    
    static let reuseIdentifier = "TrackerCell"
    
    var currentSelectedTracker: Tracker?
    var trackerID: Int?
    var currentDate: Date = Date()
    var selectedIndexPaths: Set<IndexPath> = []
    
    
    let habbitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.custom(.createButtonTextColor)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
     let doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .black
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = UIColor.custom(.createButtonTextColor)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var isChecked = false
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    var daysNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emojiContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
     let doneButtonContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 17
        view.layer.masksToBounds = true
        return view
    }()
    
    private let backgroundContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.systemGray5
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
        
        let uiElements: [UIView] = [backgroundContainer,  habbitLabel, daysNumberLabel, daysCountLabel, emojiContainer, emojiLabel, doneButtonContainer, doneButton ]
        uiElements.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        uiElements.forEach { contentView.addSubview($0) }
        
        
        
        NSLayoutConstraint.activate([
            daysNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysNumberLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            daysCountLabel.leadingAnchor.constraint(equalTo: daysNumberLabel.trailingAnchor, constant: 5),
            daysCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            daysCountLabel.heightAnchor.constraint(equalToConstant: 18),
            daysCountLabel.widthAnchor.constraint(equalToConstant: 101),
            
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            doneButtonContainer.centerXAnchor.constraint(equalTo: doneButton.centerXAnchor),
            doneButtonContainer.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
            doneButtonContainer.heightAnchor.constraint(equalToConstant: 34),
            doneButtonContainer.widthAnchor.constraint(equalToConstant: 34),
            
            backgroundContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundContainer.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: backgroundContainer.topAnchor, constant: 8),
            emojiLabel.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 8),
            
            emojiContainer.centerXAnchor.constraint(equalTo: emojiLabel.centerXAnchor),
            emojiContainer.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor),
            emojiContainer.heightAnchor.constraint(equalToConstant: 24),
            emojiContainer.widthAnchor.constraint(equalToConstant: 24),
            
            habbitLabel.topAnchor.constraint(equalTo: backgroundContainer.topAnchor, constant: 44),
            habbitLabel.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 12),
            habbitLabel.trailingAnchor.constraint(equalTo: backgroundContainer.trailingAnchor, constant: -12)
        ])
    }
    
    private func getDayWord(for count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if remainder10 == 1 && remainder100 != 11 {
            return "день"
        } else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
            return "дня"
        } else {
            return "дней"
        }
    }
    
    
    
    func configure(with tracker: Tracker, trackerRecords: [TrackerRecord]) {
        
        currentSelectedTracker = tracker
        trackerID = tracker.id
        emojiLabel.text = tracker.emoji
        habbitLabel.text = tracker.name
        backgroundContainer.backgroundColor = UIColor.fromCollectionColor(tracker.color) ?? .clear
        doneButtonContainer.backgroundColor = UIColor.fromCollectionColor(tracker.color) ?? .clear
        emojiContainer.backgroundColor = lightenColor(UIColor.fromCollectionColor(tracker.color) ?? .clear, by: 0.3)
        
        // Проверяем, был ли выполнен трекер на текущую дату
           let currentDate = Date()
        let isCompleted = trackerRecords.contains { $0.trackerID == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: viewController?.selectedDate ?? currentDate) }
        
        
        // Обновляем кнопку в зависимости от состояния выполнения
       doneButton.setImage(UIImage(systemName: isCompleted ? "checkmark" : "plus"), for: .normal)
        
        let baseColor = UIColor.fromCollectionColor(currentSelectedTracker?.color ?? .collectionBeige7) ?? .collectionBeige7
    
           
           let adjustedColor = isCompleted ? lightenColor(baseColor, by: 0.3) : baseColor
           doneButtonContainer.backgroundColor = adjustedColor

        // Отображаем количество дней
        let daysCount = tracker.daysCount 
        daysNumberLabel.text = "\(daysCount)"
        daysCountLabel.text = getDayWord(for: daysCount)
    }
    
    
    
    @objc func doneButtonTapped() {
           guard let trackerID = trackerID else {
               print("Tracker ID is missing!")
               return
           }
           
           guard let selectedDate = viewController?.getSelectedDate() else {
               print("Date Picker is not set!")
               return
           }
        
           delegate?.trackerExecution(self, didTapDoneButtonFor: trackerID, selectedDate: selectedDate)
        
       }
    }

