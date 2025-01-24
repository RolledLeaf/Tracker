

import UIKit

final class TrackerCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    
    let habbitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.custom(.createButtonTextColor)
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
    
    let daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .black
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
        
        let uiElements: [UIView] = [backgroundContainer, emojiLabel, habbitLabel, doneButton, daysNumberLabel, daysCountLabel, ]
        uiElements.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        uiElements.forEach { contentView.addSubview($0) }
        
        doneButton.setImage(UIImage(systemName: "plus"), for: .normal)
        doneButton.setImage(UIImage(systemName: "checkmark"), for: .highlighted)
        doneButton.tintColor = .systemBlue
        
        
        NSLayoutConstraint.activate([
            
            daysNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysNumberLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            daysCountLabel.leadingAnchor.constraint(equalTo: daysNumberLabel.trailingAnchor, constant: 5),
            daysCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            daysCountLabel.heightAnchor.constraint(equalToConstant: 18),
            daysCountLabel.widthAnchor.constraint(equalToConstant: 101),
            
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            backgroundContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundContainer.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: backgroundContainer.topAnchor, constant: 8),
            emojiLabel.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 8),
            
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
    
    //Конфигурация ячейки привычки, которая находится внутри ячейки категории
    func configure(with tracker: Tracker) {
        emojiLabel.text = tracker.emoji
        habbitLabel.text = tracker.name
        backgroundContainer.backgroundColor = UIColor.fromCollectionColor(tracker.color) ?? .clear
        
        let daysCount = tracker.daysCount
        daysNumberLabel.text = "\(daysCount)"
        daysCountLabel.text = getDayWord(for: daysCount)
    }
}
