import UIKit

final class TrackerCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    
    let habbitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.custom(.textColor)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emojiLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 32) // Настроить размер эмоджи
            label.textAlignment = .center
            return label
        }()
    
    private let backgroundContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .blue //узнать логику цвета привычек
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
           super.init(style: style, reuseIdentifier: reuseIdentifier)
           setupUI()
       }

       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }

    
}
