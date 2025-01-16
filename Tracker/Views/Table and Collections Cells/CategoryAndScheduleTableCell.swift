import UIKit

class CategoryAndScheduleTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    static let identifier = "CategoryAndScheduleTableViewCell" // Уникальный идентификатор для регистрации
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor.custom(.createButtonColor)
        label.backgroundColor = UIColor.custom(.backgroundGray)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
     let detailedTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor.custom(.textFieldGray)
        label.backgroundColor = UIColor.custom(.backgroundGray)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageView)
        contentView.addSubview(detailedTextLabel)
        contentView.backgroundColor = UIColor.custom(.backgroundGray)
        
        
        
        NSLayoutConstraint.activate([
            // Расположение titleLabel
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            
            detailedTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailedTextLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            detailedTextLabel.widthAnchor.constraint(equalToConstant: 271),
            detailedTextLabel.heightAnchor.constraint(equalToConstant: 22),
            
            // Расположение arrowImageView
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 10),
            arrowImageView.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    // MARK: - Configuration Method
    
    func configure(with option: (title: String, subtitle: String?)) {
        titleLabel.text = option.title
        detailedTextLabel.text = option.subtitle
    }
}
