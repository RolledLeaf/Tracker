import UIKit

protocol ScheduleTableCellDelegate: AnyObject {
    func didChangeSwitchState(isOn: Bool, forDay day: String)
}

class ScheduleTableCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    static let identifier = "ScheduleTableCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        label.backgroundColor = UIColor.custom(.backgroundGray)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = UIColor.custom(.toggleSwitchBlue)
        toggle.thumbTintColor = .white // Цвет кружка
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    // MARK: - Properties
    weak var delegate: ScheduleTableCellDelegate?
    
    // Обработчик изменения состояния переключателя
    var onToggle: ((Bool) -> Void)?
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        toggleSwitch.addTarget(self, action: #selector(toggleSwitchChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggleSwitch)
        contentView.backgroundColor = UIColor.custom(.backgroundGray)
        
        NSLayoutConstraint.activate([
            // Расположение titleLabel
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Расположение toggleButton
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleSwitch.widthAnchor.constraint(equalToConstant: 51),
            toggleSwitch.heightAnchor.constraint(equalToConstant: 31)
        ])
    }
    
    // MARK: - Configuration Method
    
    @objc private func toggleSwitchChanged() {
        onToggle?(toggleSwitch.isOn)
        delegate?.didChangeSwitchState(isOn: toggleSwitch.isOn, forDay: titleLabel.text ?? "")
        print("Toggle switch changed")
    }
    
    func configure(with title: String, isOn: Bool) {
        titleLabel.text = title
        toggleSwitch.isOn = isOn
    }
}
