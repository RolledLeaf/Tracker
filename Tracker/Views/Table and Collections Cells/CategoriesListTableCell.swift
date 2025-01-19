import UIKit

class CategoriesListTableCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    static let identifier = "CategoriesListTableCell" //
    
     let categoryNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor.custom(.createButtonColor)
        label.backgroundColor = UIColor.custom(.backgroundGray)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkMark: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = UIColor.custom(.backgroundGray)
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
        contentView.addSubview(categoryNameLabel)
        contentView.addSubview(checkMark)
        contentView.backgroundColor = UIColor.custom(.backgroundGray)
        
        NSLayoutConstraint.activate([
            // Расположение titleLabel
            categoryNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Расположение arrowImageView
            checkMark.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkMark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkMark.widthAnchor.constraint(equalToConstant: 10),
            checkMark.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)
        contentView.backgroundColor = selected ? UIColor.custom(.backgroundGray) : UIColor.custom(.backgroundGray)
           if selected {
               checkMark.tintColor = UIColor.custom(.toggleSwitchBlue) // Цвет при выделении
           } else {
               checkMark.tintColor = UIColor.custom(.backgroundGray) // Цвет при отмене выделения
           }
       }
    
    // MARK: - Configuration Method
    func configure(with title: String){
        categoryNameLabel.text = title
    }
}
