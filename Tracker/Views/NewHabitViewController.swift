import UIKit

protocol NewTrackerDelegate: AnyObject {
    func didCreateTracker(_ tracker: TrackerCoreData,_ category: TrackerCategoryCoreData)
}

final class NewHabitViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: NewTrackerDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("newHabitTitleLabel", comment: "")
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.custom(.createButtonColor)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var characterLimitLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("characterLimitLabel", comment: "")
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.custom(.cancelButtonRed)
        label.alpha = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("trackerNameTextField", comment: "")
        textField.layer.cornerRadius = 16
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
    
    private lazy var categoryAndScheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.custom(.textFieldGray)
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.rowHeight = 75
        let layer = tableView.layer
        layer.cornerRadius = 16
        return tableView
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 3
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 3
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorsCollectionViewCell.self, forCellWithReuseIdentifier: ColorsCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var createTrackerButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("createTrackerButton", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.custom(.textColor), for: .normal)
        button.backgroundColor = UIColor.custom(.textFieldGray)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createTrackerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.custom(.cancelButtonRed), for: .normal)
        button.backgroundColor = .clear
        button.layer.borderWidth = 1   // Толщина рамки
        button.layer.borderColor = UIColor.custom(.cancelButtonRed)?.cgColor
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    var tableViewOptions: [(title: String, subtitle: String?)] = [
        (title: NSLocalizedString("tableViewOptionCategory", comment: ""), subtitle: nil),
        (title: NSLocalizedString("tableViewOptionSchedule", comment: ""), subtitle: nil)
    ]
    
    
    var selectedWeekDays: [String]? {
        didSet {
            updateCreateCategoryButtonColor()
        }
    }
    
    var selectedColor: CollectionColors? {
        didSet {
            updateCreateCategoryButtonColor()
        }
    }
    var selectedEmoji: String? {
        didSet {
            updateCreateCategoryButtonColor()
        }
    }
    
    var selectedCategory: TrackerCategoryCoreData? {
        didSet {
            updateCreateCategoryButtonColor()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        trackerNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        view.backgroundColor = UIColor(named: CustomColor.mainBackgroundColor.rawValue)
    }
    
    private func setupViews() {
        let buttonsStackView = UIStackView(arrangedSubviews: [ cancelButton, createTrackerButton])
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 8
        buttonsStackView.distribution = .fillEqually
        
        let collectionsStackView = UIStackView(arrangedSubviews: [ emojiCollectionView, colorsCollectionView])
        collectionsStackView.axis = .vertical
        collectionsStackView.spacing = 34
        collectionsStackView.distribution = .fillEqually
        
        let uiElements = [titleLabel, trackerNameTextField, characterLimitLabel, categoryAndScheduleTableView, collectionsStackView, buttonsStackView]
        uiElements.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        uiElements.forEach { contentView.addSubview($0) }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        trackerNameTextField.delegate = self
        
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 962),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -33),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            trackerNameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            trackerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            characterLimitLabel.heightAnchor.constraint(equalToConstant: 20),
            characterLimitLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 44),
            characterLimitLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -44),
            characterLimitLabel.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 2),
            
            categoryAndScheduleTableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            categoryAndScheduleTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryAndScheduleTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryAndScheduleTableView.heightAnchor.constraint(equalToConstant: 150),
            
            collectionsStackView.topAnchor.constraint(equalTo: categoryAndScheduleTableView.bottomAnchor, constant: 50),
            collectionsStackView.heightAnchor.constraint(equalToConstant: 442),
            collectionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 23),
            collectionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -23),
            
            buttonsStackView.topAnchor.constraint(equalTo: collectionsStackView.bottomAnchor, constant: 46),
            
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)])
        
        emojiCollectionView.delegate = self
        colorsCollectionView.delegate = self
        categoryAndScheduleTableView.delegate = self
        
        emojiCollectionView.dataSource = self
        colorsCollectionView.dataSource = self
        categoryAndScheduleTableView.dataSource = self
        
        emojiCollectionView.register(
            EmojiAndColorCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: EmojiAndColorCollectionHeaderView.identifier
        )
        
        colorsCollectionView.register(
            EmojiAndColorCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: EmojiAndColorCollectionHeaderView.identifier
        )
        
        categoryAndScheduleTableView.register(CategoryAndScheduleTableViewCell.self, forCellReuseIdentifier: CategoryAndScheduleTableViewCell.identifier)
    }
    
    @objc func textFieldDidChange() {
        updateCreateCategoryButtonColor()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: NSLocalizedString("alertTrackerNotCreated", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func updateCreateCategoryButtonColor() {
        if let name = trackerNameTextField.text, !name.isEmpty, !name.isBlank,
           selectedColor != nil,
           selectedEmoji != nil,
           let selectedWeekDays = selectedWeekDays, !selectedWeekDays.isEmpty,
           selectedCategory != nil {
            createTrackerButton.titleLabel?.textColor = UIColor.custom(.createButtonTextColor)
            createTrackerButton.backgroundColor = UIColor.custom(.createButtonColor)
            print("Условия выполнены, кнопка Создать перекрашена в \(String(describing: UIColor.custom(.createButtonColor)))")
        } else {
            createTrackerButton.backgroundColor = UIColor.custom(.textFieldGray)  // Неактивный цвет
            createTrackerButton.titleLabel?.textColor = UIColor.custom(.textColor)
            print("Условия не выполнены, кнопка Создать снова \(String(describing: UIColor.custom(.textFieldGray))) цвета")
        }
    }
    
    @objc private func createTrackerButtonTapped(_ sender: UIButton) {
        guard let name = trackerNameTextField.text, !name.isEmpty, !name.isBlank,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji,
              let selectedWeekDays = selectedWeekDays,
              let selectedCategory = selectedCategory
        else {
            showAlert(message: NSLocalizedString("alertFieldsMissed", comment: ""))
            print("Не все данные выбраны!")
            return
        }
        print("Создаём трекер с названием: \(name), цвет: \(selectedColor), эмодзи: \(selectedEmoji), категория: \(selectedCategory), дни недели: \(selectedWeekDays.joined(separator: ", "))")
        
        let context = CoreDataStack.shared.context
        let tracker = TrackerCoreData(context: context)
        tracker.id = TrackerIdGenerator.generateId()
        tracker.name = name
        tracker.color = selectedColor.rawValue as NSString
        tracker.emoji = selectedEmoji
        tracker.daysCount = 0
        tracker.weekDays = selectedWeekDays as NSObject
        
        let category = selectedCategory
        tracker.category = selectedCategory
        category.addToTracker(tracker)
        
        do {
            try context.save()
            print("📌 Создаём трекер '\(String(describing: tracker.name))' для категории '\(category.title ?? "Без названия")'")
            print("Контекст перед сохранением трекера: \(context)")
            print("Контекст категории: \(String(describing: selectedCategory.managedObjectContext))")
            delegate?.didCreateTracker(tracker, category)
            presentingViewController?.presentingViewController?.dismiss(animated: true)
        } catch {
            print("Ошибка при сохранении трекера: \(error)")
        }
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print("Requested supplementary view for kind: \(kind), section: \(indexPath.section)")
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            print("Invalid kind requested")
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: EmojiAndColorCollectionHeaderView.identifier,
            for: indexPath
        ) as? EmojiAndColorCollectionHeaderView else {
            print("Failed to dequeue CollectionHeaderView")
            return UICollectionReusableView()
        }
        
        print("Successfully dequeued CollectionHeaderView for section \(indexPath.section)")
        
        if collectionView == emojiCollectionView {
            header.configure(with: "Emoji")
        } else if collectionView == colorsCollectionView {
            header.configure(with: NSLocalizedString("colorCollectionViewTitle", comment: ""))
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size = CGSize(width: 52, height: 18)
        print("Header size for section \(section): \(size)")
        return size
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else if collectionView == colorsCollectionView {
            return trackerCollectionColors.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as? EmojiCollectionViewCell else {
                print("Collection wasn't able to dequeue cell")
                return UICollectionViewCell()
            }
            
            cell.configure(with: emojis[indexPath.item])
            return cell
        } else if collectionView == colorsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorsCollectionViewCell.identifier, for: indexPath) as? ColorsCollectionViewCell else {
                return UICollectionViewCell()
            }
            let color = trackerCollectionColors[indexPath.item]
            cell.configure(with: color)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorsCollectionView {
            selectedColor = trackerCollectionColors[indexPath.item]
            if let selectedColor = selectedColor {
                print("Selected color: \(selectedColor)")
            }
        } else if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
            if let selectedEmoji = selectedEmoji {
                print("Selected emoji: \(selectedEmoji)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryAndScheduleTableViewCell.identifier, for: indexPath) as? CategoryAndScheduleTableViewCell else {
            print("Unable to dequeue cell")
            return UITableViewCell()
        }
        cell.configure(with: tableViewOptions[indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            view.endEditing(true)
            let categoryListVC = CategoriesListViewController()
            categoryListVC.delegate = self
            let navigationController = UINavigationController(rootViewController: categoryListVC)
            navigationController.modalPresentationStyle = .automatic
            present(navigationController, animated: true)
        } else if indexPath.row == 1 {
            view.endEditing(true)
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            let navigationController = UINavigationController(rootViewController: scheduleVC)
            navigationController.modalPresentationStyle = .popover
            present(navigationController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = 16
        
        cell.layer.cornerRadius = 0
        cell.layer.maskedCorners = []
        cell.clipsToBounds = true
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        if indexPath.row == 0 {
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        }
    }
}

extension NewHabitViewController: ScheduleViewControllerDelegate {
    func updateSchedule(for title: String, with subtitle: String?) {
        print("Вызов делегата обновления расписания")
        if let index = tableViewOptions.firstIndex(where: { $0.title == title }) {
            tableViewOptions[index].subtitle = subtitle
            categoryAndScheduleTableView.reloadData()
        }
        if title == NSLocalizedString("tableViewOptionSchedule", comment: ""), let subtitle = subtitle {
            if subtitle == NSLocalizedString("everyday", comment: "") {
                selectedWeekDays = shortWeekdaySymbols
            } else {
                selectedWeekDays = subtitle.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            }
        }
    }
}

extension NewHabitViewController: CategoriesListViewControllerDelegate {
    func updateCategory(with category: TrackerCategoryCoreData) {
        print("Вызов делегата обновления категорий")
        if let index = tableViewOptions.firstIndex(where: { $0.title == NSLocalizedString("tableViewOptionCategory", comment: "") }) {
            tableViewOptions[index].subtitle = category.title
        }
        selectedCategory = category 
        categoryAndScheduleTableView.reloadData()
    }
}

extension NewHabitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text, let textRange = Range(range, in: currentText) else {
            return true
        }
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
       let shouldHide = updatedText.count < 38
        
        UIView.animate(withDuration: 0.25) {
            self.characterLimitLabel.alpha = shouldHide ? 0 : 1
        }
        return shouldHide
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.25) {
            self.characterLimitLabel.alpha = 0
        }
        return true
    }
}
