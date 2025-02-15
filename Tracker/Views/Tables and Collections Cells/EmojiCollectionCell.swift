import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Identifier
    
    static let identifier = "EmojiCollectionViewCell"
    
    // MARK: - UI Elements
    
    lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var selectionBackgroundView: UIView?
    
    override var isSelected: Bool {
        didSet {
            updateSelectionState()
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0
    }
    
    func updateSelectionState() {
        if isSelected {
            addSelectionBackgroundView()
        } else {
            removeSelectionBackgroundView()
        }
    }
    
    private func addSelectionBackgroundView() {
        if selectionBackgroundView != nil { return }
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.custom(CustomColor.backgroundGray)
        backgroundView.layer.cornerRadius = 16
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentView.insertSubview(backgroundView, at: 0)
        
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 52),
            backgroundView.widthAnchor.constraint(equalToConstant: 52)
        ])
        
        selectionBackgroundView = backgroundView
    }
    
    private func removeSelectionBackgroundView() {
        selectionBackgroundView?.removeFromSuperview()
        selectionBackgroundView = nil
    }
    
    // MARK: - Configuration Method
    
    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }
}
