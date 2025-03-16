import UIKit

final class ColorsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Identifier
    static let identifier = "ColorsCollectionViewCell"
    
    lazy var colorBlockImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var baseColor: UIColor = .clear
    
    // MARK: - UI Elements
    override var isSelected: Bool {
        didSet {
            updateSelectionState()
        }
    }
    
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
        contentView.layer.borderWidth = 0
        contentView.addSubview(colorBlockImage)
        
        NSLayoutConstraint.activate([
            colorBlockImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorBlockImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorBlockImage.widthAnchor.constraint(equalToConstant: 40),
            colorBlockImage.heightAnchor.constraint(equalToConstant: 40)])
    }
    
    private func updateSelectionState() {
        if isSelected {
            contentView.layer.borderColor = UIColor.blue.cgColor
            contentView.layer.borderColor = adjustAlpha(baseColor, to: 0.3).cgColor
            contentView.layer.borderWidth = 3
            contentView.layer.cornerRadius = 8
        } else {
            contentView.layer.borderColor = UIColor.clear.cgColor
            contentView.layer.borderWidth = 0
        }
    }
    
    // MARK: - Configuration Method
    
    func configure(with color: CollectionColors) {
        let colorValue = color.uiColor
        baseColor = colorValue ?? .gray
        colorBlockImage.backgroundColor = color.uiColor
    }
}
