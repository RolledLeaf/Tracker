import UIKit
import CoreData

protocol CategoriesListViewControllerDelegate: AnyObject {
    func updateCategory(with category: TrackerCategoryCoreData)
}

final class CategoriesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: CategoriesListViewControllerDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.custom(.textColor)
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.text = "Категория"
        return label
    }()
    
    private lazy var categoriesListTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.custom(.textFieldGray)
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.custom(.backgroundGray)
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        return tableView
    }()
    
    private lazy var emptyFieldStarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dizzyStar")
        return imageView
    }()
    
    private lazy var emptyFieldLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.custom(.textColor)
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Привычки и события можно \n объединить по смыслу"
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor.custom(.createButtonTextColor), for: .normal)
        button.backgroundColor = UIColor.custom(.createButtonColor)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private let categoriesKey = "categoriesListKey"
    private let notificationKey = "NewCategoryAdded"
    private var tableHeightConstraint: NSLayoutConstraint?
    private var contentViewHeightConstraint: NSLayoutConstraint?
    private var categoriesList: [TrackerCategoryCoreData] = []
    private var tableHeight: CGFloat = 75
    private var contentViewHeight: CGFloat = 260
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        fetchCategories()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewCategoryAdded), name: NSNotification.Name(notificationKey), object: nil)
    }
    
    private func updateUI() {
        let isEmpty = categoriesList.isEmpty
        emptyFieldLabel.isHidden = !isEmpty
        emptyFieldStarImage.isHidden = !isEmpty
        categoriesListTableView.isHidden = isEmpty
        updateTableHeight()
        updateContentViewHeight()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: CustomColor.mainBackgroundColor.rawValue)
        let stackView = UIStackView(arrangedSubviews: [emptyFieldStarImage, emptyFieldLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        
        let uiElements = [titleLabel, emptyFieldLabel, emptyFieldStarImage, categoriesListTableView]
        uiElements.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        uiElements.forEach { contentView.addSubview($0) }
        view.addSubview(addCategoryButton)
        
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        
        categoriesListTableView.register(CategoriesListTableCell.self, forCellReuseIdentifier: CategoriesListTableCell.identifier)
        
        let tableHeightConstraint = categoriesListTableView.heightAnchor.constraint(equalToConstant: tableHeight)
        self.tableHeightConstraint = tableHeightConstraint
        
        let contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: contentViewHeight)
        self.contentViewHeightConstraint = contentViewHeightConstraint
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: -50),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentViewHeightConstraint,
            
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 200),
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            
            categoriesListTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoriesListTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoriesListTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            categoriesListTableView.widthAnchor.constraint(equalToConstant: 343),
            tableHeightConstraint,
            
            emptyFieldStarImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emptyFieldStarImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 232),
            emptyFieldStarImage.heightAnchor.constraint(equalToConstant: 80),
            emptyFieldStarImage.widthAnchor.constraint(equalToConstant: 80),
            
            emptyFieldLabel.topAnchor.constraint(equalTo: emptyFieldStarImage.bottomAnchor, constant: 8),
            emptyFieldLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emptyFieldLabel.widthAnchor.constraint(equalToConstant: 343),
            emptyFieldLabel.heightAnchor.constraint(equalToConstant: 72),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16) //
        ])
        categoriesListTableView.dataSource = self
        categoriesListTableView.delegate = self
    }
    
    private func updateTableHeight() {
        let rowHeight: CGFloat = 75
        let newHeight = rowHeight * CGFloat(categoriesList.count)
        tableHeightConstraint?.constant = newHeight
        view.layoutIfNeeded()
        print("Table height updated to \(newHeight)")
    }
    
    
    private func updateContentViewHeight() {
        let rowHeight: CGFloat = contentViewHeight
        let newHeight = rowHeight + CGFloat(tableHeightConstraint?.constant ?? 500)
        contentViewHeightConstraint?.constant = newHeight
        view.layoutIfNeeded()
        print("Content view height updated to \(newHeight)")
    }
    
    
    private func createContextMenu(for indexPath: IndexPath) -> UIMenu {
        // Пункт "Редактировать"
        let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
            self.editItem(at: indexPath)
        }
        
        let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.deleteItem(at: indexPath)
        }
        return UIMenu(title: "", children: [editAction, deleteAction])
    }
    
    private func editItem(at indexPath: IndexPath) {
        guard categoriesListTableView.cellForRow(at: indexPath) is CategoriesListTableCell else { return }
        
        let category = categoriesList[indexPath.row] // Получаем объект Core Data
        let currentText = category.title ?? ""
        
        let alert = UIAlertController(title: "Редактировать", message: "Введите новое название категории", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = currentText
            textField.placeholder = "Название категории"
        }
        
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let newText = alert.textFields?.first?.text, !newText.isEmpty else { return }
            category.title = newText
            
            do {
                try CoreDataStack.shared.context.save() // Сохраняем изменения
                self?.categoriesListTableView.reloadRows(at: [indexPath], with: .automatic)
            } catch {
                print("❌ Ошибка при обновлении категории: \(error)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        let category = categoriesList[indexPath.row]
        trackerCategoryStore.deleteTrackerCategory(category)
        
        categoriesList.remove(at: indexPath.row)
        categoriesListTableView.deleteRows(at: [indexPath], with: .automatic)
        updateUI()
    }
    
    private func fetchCategories() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)] // Сортируем по названию
        
        do {
            let categories = try CoreDataStack.shared.context.fetch(fetchRequest)
            categoriesList = categories // Сохраняем категории в массив
            categoriesListTableView.reloadData() // Обновляем таблицу
            updateUI() // Скрываем/показываем пустые состояния
        } catch {
            print("❌ Ошибка при получении категорий: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = categoriesList.count
        return sections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesListTableCell.identifier, for: indexPath) as? CategoriesListTableCell else {
            print("CategoriesTableView wasn't able to dequeue cell")
            return UITableViewCell()
        }
        
        
        let category = categoriesList[indexPath.row]
        cell.configure(with: category.title ?? "Без названия")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = categoriesList[indexPath.row]
        delegate?.updateCategory(with: category)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let configuration = UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            previewProvider: nil
        ) { _ in
            return self.createContextMenu(for: indexPath)
        }
        return configuration
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
    
    @objc private func handleNewCategoryAdded() {
        fetchCategories()
    }
    
    @objc private func addCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        let navigationController = UINavigationController(rootViewController: newCategoryVC)
        navigationController.modalPresentationStyle = .automatic
        present(navigationController, animated: true)
    }
    
}

