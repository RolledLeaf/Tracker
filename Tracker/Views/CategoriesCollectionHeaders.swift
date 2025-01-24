import UIKit

final class CategoriesCollectionHeaderView: UICollectionReusableView {
    static let identifier = "CategoriesCollectionHeaderView"
    
     let titleLabel: UILabel = {
        let label = UILabel()
         label.font = .systemFont(ofSize: 19, weight: .bold)
         label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
       
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                    titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                    titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
                ])
    }
    
    func configure(with title: String) {
        titleLabel.text = title.isEmpty ? "Untitled" : title
    }
    
}
