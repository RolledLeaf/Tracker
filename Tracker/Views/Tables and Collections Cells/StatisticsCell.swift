import UIKit

final class StatisticsCell: UITableViewCell {
    
    static let identifier = "StatisticsCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor.custom(.createButtonColor)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var detailedTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor.custom(.textFieldGray)
        label.backgroundColor = .clear
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailedTextLabel)
        contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            
            detailedTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailedTextLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            detailedTextLabel.widthAnchor.constraint(equalToConstant: 271),
            detailedTextLabel.heightAnchor.constraint(equalToConstant: 22),
        ])
        
       
    }
    
    // MARK: - Configuration Method
    
  
    
    func configure(with option: (title: Int, subtitle: String)) {
        // Устанавливаем текст для заголовка
        titleLabel.text = "\(option.title)"
        detailedTextLabel.text = option.subtitle
        
    }
}
