import UIKit



final class NewCategoryViewController: UIViewController {
    

    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.custom(.textColor)
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.text = "Новая категория"
        return label
    }()
    
    private lazy var categoryNameTextField:UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.placeholder = "Введите название категории"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = UIColor.custom(.createButtonColor)
        textField.backgroundColor = UIColor.custom(.backgroundGray)
        textField.textAlignment = .left
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: textField, action: #selector(UIResponder.resignFirstResponder))
        toolbar.items = [flexSpace, doneButton]
        
        textField.inputAccessoryView = toolbar
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
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
        let uiElements = [titleLabel, categoryNameTextField, doneButton]
        uiElements.forEach { view.addSubview($0) }
        uiElements.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
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
