import UIKit

protocol TrackerCategoryCellDelegate: AnyObject {
    func trackerExecution(_ cell: TrackerCell, didTapDoneButtonFor trackerID: UUID, selectedDate: Date)
}

final class TrackerCell: UICollectionViewCell {
    weak var delegate: TrackerCategoryCellDelegate?
    weak var viewController: TrackersViewController?
    
    static let reuseIdentifier = "TrackerCell"
    
    private var currentSelectedTracker: Tracker?
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
    
    lazy var daysNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doneButtonTapped))
        doneButtonContainer.addGestureRecognizer(tapGesture)
        doneButton.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
            daysNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysNumberLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            daysCountLabel.leadingAnchor.constraint(equalTo: daysNumberLabel.trailingAnchor, constant: 5),
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
    
    private func getDayWord(for count: Int16) -> String {
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
        
        // Преобразуем цвет только один раз
        let trackerColor = UIColor.fromCollectionColor(tracker.color as! String) ?? .clear
        
        // Настроим фоны
        backgroundContainer.backgroundColor = trackerColor
        doneButtonContainer.backgroundColor = trackerColor
        emojiContainer.backgroundColor = lightenColor(trackerColor, by: 0.3)
        
        let currentDate = Date()
        let isCompleted = trackerRecords.contains { $0.trackerID == tracker.id && Calendar.current.isDate($0.date ?? currentDate, inSameDayAs: viewController?.selectedDate ?? currentDate) }

        // Настроим кнопку в зависимости от состояния
        doneButton.setImage(UIImage(systemName: isCompleted ? "checkmark" : "plus"), for: .normal)

        // Цвет фона кнопки в зависимости от состояния
        let baseColor = trackerColor
        let adjustedColor = isCompleted ? lightenColor(baseColor, by: 0.3) : baseColor
        doneButtonContainer.backgroundColor = adjustedColor
        
        // Настроим отображение количества дней
        let daysCount = tracker.daysCount
        daysNumberLabel.text = "\(daysCount)"
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

