import UIKit

final class TrackerCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    
    let habbitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.custom(.textColor)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let doneButton = UIButton ()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    let daysNumberLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let daysTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        contentView.addSubview(backgroundContainer)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(habbitLabel)
        contentView.addSubview(doneButton)
        contentView.addSubview(daysNumberLabel)
        contentView.addSubview(daysTextLabel)
        
        
        doneButton.setImage(UIImage(systemName: "plus"), for: .normal)
        doneButton.setImage(UIImage(systemName: "checkmark"), for: .highlighted)
        doneButton.tintColor = .systemBlue
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Установим ограничения для backgroundContainer
        NSLayoutConstraint.activate([
            
            daysNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysNumberLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            daysTextLabel.leadingAnchor.constraint(equalTo: daysNumberLabel.trailingAnchor, constant: 5),
            daysTextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            backgroundContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -90),
            
            emojiLabel.topAnchor.constraint(equalTo: backgroundContainer.topAnchor, constant: 8),
            emojiLabel.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 8),
            
            habbitLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 44),
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
    
    func configure(with tracker: Tracker, completedCount: Int) {
        emojiLabel.text = tracker.emoji // Присваиваем эмоджи из модели
        habbitLabel.text = tracker.name // Присваиваем название привычки
        backgroundContainer.backgroundColor = UIColor.fromCollectionColor(tracker.color) ?? .clear // Применяем цвет из модели
        
        let daysCount = tracker.schedule.daysCount
          daysNumberLabel.text = "\(daysCount)"
          daysTextLabel.text = getDayWord(for: daysCount)
    }
}
