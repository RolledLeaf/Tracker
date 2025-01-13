import UIKit

class ColorsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Identifier
    
    static let identifier = "ColorsCollectionViewCell"
    
    // MARK: - UI Setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }
    
    // MARK: - Configuration Method
    
    func configure(with color: UIColor) {
        contentView.backgroundColor = color
    }
}
