import UIKit

class CategoriesListTableCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    static let identifier = "CategoriesListTableCell" //
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        label.backgroundColor = UIColor.custom(.backgroundGray)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkMark: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark") // Стрелка ">"
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
        contentView.addSubview(checkMark)
        contentView.backgroundColor = UIColor.custom(.backgroundGray)
        
        
        
        NSLayoutConstraint.activate([
            // Расположение titleLabel
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Расположение arrowImageView
            checkMark.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkMark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkMark.widthAnchor.constraint(equalToConstant: 10),
            checkMark.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    // MARK: - Configuration Method
    
   
}
