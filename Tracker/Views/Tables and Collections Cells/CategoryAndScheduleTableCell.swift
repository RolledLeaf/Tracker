import UIKit

class CategoryAndScheduleTableViewCell: UITableViewCell {
    
    static let identifier = "CategoryAndScheduleTableViewCell"
    
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
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var subtitleConstraints: [NSLayoutConstraint] = []
    private var noSubtitleConstraints: [NSLayoutConstraint] = []
    private var hasSubtitle: Bool = false {
        didSet {
            updateConstraintsForSubtitle()
        }
    }
    
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
        contentView.backgroundColor = UIColor.custom(.tablesColor)
        
        NSLayoutConstraint.activate([
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 10),
            arrowImageView.heightAnchor.constraint(equalToConstant: 15)
        ])
        
        subtitleConstraints = [
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            
            detailedTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailedTextLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            detailedTextLabel.widthAnchor.constraint(equalToConstant: 271),
            detailedTextLabel.heightAnchor.constraint(equalToConstant: 22),
        ]
        
        noSubtitleConstraints = [
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
    }
    
    // MARK: - Configuration Method
    
    private func updateConstraintsForSubtitle() {
        if hasSubtitle {
            detailedTextLabel.isHidden = false
            NSLayoutConstraint.deactivate(noSubtitleConstraints)
            NSLayoutConstraint.activate(subtitleConstraints)
        } else {
            detailedTextLabel.isHidden = true
            NSLayoutConstraint.deactivate(subtitleConstraints)
            NSLayoutConstraint.activate(noSubtitleConstraints)
        }
    }
    
    func configure(with option: (title: String, subtitle: String?)) {
        // Устанавливаем текст для заголовка
        titleLabel.text = option.title
        
        // Устанавливаем текст для subtitle и обновляем состояние
        if let subtitle = option.subtitle, !subtitle.isEmpty {
            detailedTextLabel.text = subtitle
            hasSubtitle = true
        } else {
            detailedTextLabel.text = nil
            hasSubtitle = false
        }
    }
}
