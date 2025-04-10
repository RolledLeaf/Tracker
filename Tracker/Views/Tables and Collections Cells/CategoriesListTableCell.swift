import UIKit

final class CategoriesListTableCell: UITableViewCell {
    
    static let identifier = "CategoriesListTableCell" //
    
     lazy var categoryNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor.custom(.createButtonColor)
         label.backgroundColor = .clear
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        contentView.backgroundColor = UIColor.custom(.tablesColor)
        
        NSLayoutConstraint.activate([
            // Расположение titleLabel
            categoryNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
        ])
    }
    
 
    
    // MARK: - Configuration Method
    func configure(with title: String){
        categoryNameLabel.text = title
    }
    
    func setHidden(_ hidden: Bool) {
        self.isHidden = hidden
        self.isUserInteractionEnabled = false
        self.contentView.isHidden = hidden
    }
}
