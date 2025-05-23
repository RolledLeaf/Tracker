import UIKit

final class CreateHabitTypeViewController: UIViewController {
    
    weak var delegate: NewTrackerDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackerCreationTitle", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.custom(.textColor)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("habitButton", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.custom(.createButtonTextColor), for: .normal)
        button.backgroundColor = UIColor.custom(.createButtonColor)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("irregularButton", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.custom(.createButtonTextColor), for: .normal)
        button.backgroundColor = UIColor.custom(.createButtonColor)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: CustomColor.mainBackgroundColor.rawValue)
        setupUI()
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [habitButton, irregularEventButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.heightAnchor.constraint(equalToConstant: 136),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 344),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func habitButtonTapped() {
        let newHabitVC = NewHabitViewController()
        newHabitVC.delegate = delegate
        let navigationController = UINavigationController(rootViewController: newHabitVC)
        navigationController.modalPresentationStyle = .automatic
        present(navigationController, animated: true)
    }
    
    @objc private func irregularEventButtonTapped() {
        let newIrregularEventVC = NewIrregularEventViewController()
        newIrregularEventVC.delegate = delegate
        let navigationController = UINavigationController(rootViewController: newIrregularEventVC)
        navigationController.modalPresentationStyle = .automatic
        present(navigationController, animated: true)
    }
}
