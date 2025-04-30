import UIKit

final class NewCategoryViewController: UIViewController {
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.custom(.textColor)
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.text = NSLocalizedString("newCategoryTitleLabel", comment: "")
        return label
    }()
    
    private lazy var categoryNameTextField:UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.placeholder = NSLocalizedString("categoryNameTextField", comment: "")
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = UIColor.custom(.createButtonColor)
        textField.backgroundColor = UIColor.custom(.tablesColor)
        textField.textAlignment = .left
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: NSLocalizedString("doneButton", comment: ""), style: .done, target: textField, action: #selector(UIResponder.resignFirstResponder))
        toolbar.items = [flexSpace, doneButton]
        
        textField.inputAccessoryView = toolbar
        return textField
    }()
    
    private lazy var characterLimitLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("categoryCharacterLimitLabel", comment: "")
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.custom(.cancelButtonRed)
        label.isHidden = false
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("doneButton", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.custom(.createButtonTextColor), for: .normal)
        button.backgroundColor = UIColor.custom(.textFieldGray)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: CustomColor.mainBackgroundColor.rawValue)
        setupViews()
        categoryNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupViews() {
        let uiElements = [titleLabel, categoryNameTextField, characterLimitLabel, doneButton]
        uiElements.forEach { view.addSubview($0) }
        uiElements.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        categoryNameTextField.delegate = self
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 200),
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            categoryNameTextField.widthAnchor.constraint(equalToConstant: 343),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            characterLimitLabel.heightAnchor.constraint(equalToConstant: 20),
            characterLimitLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 44),
            characterLimitLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -44),
            characterLimitLabel.topAnchor.constraint(equalTo: categoryNameTextField.bottomAnchor, constant: 2),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func updateDoneButtonColor() {
        if let name = categoryNameTextField.text, !name.isEmpty {
            doneButton.backgroundColor =  UIColor.custom(.createButtonColor)
            print("Условия выполнены, кнопка Готово перекрашена в \(UIColor.custom(.createButtonColor))")
        } else {
            doneButton.backgroundColor = UIColor.custom(.textFieldGray)
            print("Условия не выполнены, кнопка Готово снова \(UIColor.custom(.textFieldGray)) цвета")
        }
    }
    
    private func saveCategoryToCoreData(_ categoryName: String) {
        let context = CoreDataStack.shared.context
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = categoryName
        newCategory.sortOrder = trackerCategoryStore.nextAvailableSortOrder()
        
        do {
            try context.save()
            print("Категория \(categoryName) сохранена в базу данных")
            NotificationCenter.default.post(name: NSNotification.Name("NewCategoryAdded"), object: nil)
        } catch {
            print("Ошибка сохранения категории: \(error)")
        }
    }
    
    @objc func textFieldDidChange() {
        updateDoneButtonColor()
    }
    
    @objc func doneButtonTapped() {
        guard let categoryName = categoryNameTextField.text, !categoryName.isEmpty else { return }
        saveCategoryToCoreData(categoryName)
        dismiss(animated: true, completion: nil)
        
    }
}

extension NewCategoryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text, let textRange = Range(range, in: currentText) else {
            return true
        }
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
       let shouldHide = updatedText.count < 35
        
        UIView.animate(withDuration: 0.25) {
            self.characterLimitLabel.isHidden = false
            self.characterLimitLabel.alpha = shouldHide ? 0 : 1
            
        }
        return shouldHide
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.25) {
            self.characterLimitLabel.alpha = 0
            self.characterLimitLabel.isHidden = true
        }
        return true
    }
}
