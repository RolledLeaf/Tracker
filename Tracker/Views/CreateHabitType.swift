
import UIKit

final class CreateHabitTypeViewController: UIViewController {
    
    weak var delegate: NewHabitViewControllerDelegate?
    
    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(UIColor.custom(.createButtonTextColor), for: .normal)
        button.backgroundColor = UIColor.custom(.createButtonColor)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    private let irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(UIColor.custom(.createButtonTextColor), for: .normal)
        button.backgroundColor = UIColor.custom(.createButtonColor)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [habitButton, irregularEventButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalToConstant: 136),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -281),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func habitButtonTapped() {
        let habitCreationVC = NewHabitViewController()
        habitCreationVC.delegate = delegate
        let navigationController = UINavigationController(rootViewController: habitCreationVC)
        navigationController.modalPresentationStyle = .automatic
        present(navigationController, animated: true)
    }
    
    @objc private func irregularEventButtonTapped() {
        let eventSettingsVC = NewIrregularEventViewController()
        eventSettingsVC.delegate = delegate as? any NewIrregularEventViewControllerDelegate
        let navigationController = UINavigationController(rootViewController: eventSettingsVC)
        navigationController.modalPresentationStyle = .automatic
        present(navigationController, animated: true)
    }
}
