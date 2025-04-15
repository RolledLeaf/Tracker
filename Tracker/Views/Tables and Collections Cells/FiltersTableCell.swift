import UIKit

final class FiltersTableCell: UITableViewCell {
    
    static let identifier = "FiltersTableCell"
    
     lazy var categoryNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor.custom(.createButtonColor)
         label.backgroundColor = .clear
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var checkMark: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = UIColor.custom(.toggleSwitchBlue)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
     let customSeparator: UIView = {
        let view = UIView()
         view.backgroundColor = UIColor.custom(.textFieldGray)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        contentView.addSubview(customSeparator)
        
        NSLayoutConstraint.activate([
         
            categoryNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            customSeparator.heightAnchor.constraint(equalToConstant: 0.5),
                customSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                customSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                customSeparator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      
            checkMark.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkMark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkMark.widthAnchor.constraint(equalToConstant: 15),
            checkMark.heightAnchor.constraint(equalToConstant: 20)
        ])
        checkMark.isHidden = true
    }
    
    func showCheckmark(_ visible: Bool) {
        checkMark.isHidden = !visible
    }
    
    // MARK: - Configuration Method
    func configure(with title: String){
        categoryNameLabel.text = title
        setSelected(true , animated: true)
    }
}
