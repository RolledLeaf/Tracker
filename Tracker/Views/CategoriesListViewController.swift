
import UIKit

final class CategoriesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewCategoryDelegate {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.custom(.textColor)
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.text = "Категория"
        return label
    }()
    
    private let categoriesListTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.custom(.textFieldGray)
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.custom(.backgroundGray)
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        return tableView
    }()
    
    private let emptyFieldStarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dizzyStar")
        return imageView
    }()
    
    private let emptyFieldLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.custom(.textColor)
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Привычки и события можно \n объединить по смыслу"
        return label
    }()
    
    private let addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(UIColor.custom(.createButtonTextColor), for: .normal)
        button.backgroundColor = UIColor.custom(.createButtonColor)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var tableHeightConstraint: NSLayoutConstraint?
    
    var categoriesList: [String] = []
    
    var tableHeight: CGFloat {
        return 75
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
    }
    
    
    
    private func updateUI() {
        updateTableHeight()
        if  categoriesList.isEmpty == true {
            emptyFieldLabel.isHidden = false
            emptyFieldStarImage.isHidden = false
            categoriesListTableView.isHidden = true
        } else {
            emptyFieldLabel.isHidden = true
            emptyFieldStarImage.isHidden = true
            categoriesListTableView.isHidden = false
        }
    }
    
    
    func setupUI() {
        view.backgroundColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [emptyFieldStarImage, emptyFieldLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        
        let uiElements = [titleLabel, emptyFieldLabel, emptyFieldStarImage, categoriesListTableView, addCategoryButton]
        uiElements.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        uiElements.forEach { contentStackView.addSubview($0) }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        categoriesListTableView.dataSource = self
        categoriesListTableView.delegate = self
        
        categoriesListTableView.register(CategoriesListTableCell.self, forCellReuseIdentifier: CategoriesListTableCell.identifier)
        
        let tableHeightConstraint = categoriesListTableView.heightAnchor.constraint(equalToConstant: tableHeight)
           self.tableHeightConstraint = tableHeightConstraint
        
        contentStackView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor).isActive = true
        
        NSLayoutConstraint.activate([
            // Настройка scrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: -50),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Настройка contentStackView
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentStackView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor), // Устанавливаем минимальную высоту

            // Настройка titleLabel
            titleLabel.centerXAnchor.constraint(equalTo: contentStackView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentStackView.topAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 200),
            titleLabel.heightAnchor.constraint(equalToConstant: 40),

            // Настройка categoriesListTableView
            categoriesListTableView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: -16),
            categoriesListTableView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor, constant: 16),
            categoriesListTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            categoriesListTableView.widthAnchor.constraint(equalToConstant: 343),
            tableHeightConstraint, // Убедитесь, что этот constraint корректный

            // Настройка emptyFieldStarImage
            emptyFieldStarImage.centerXAnchor.constraint(equalTo: contentStackView.centerXAnchor),
            emptyFieldStarImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 232),
            emptyFieldStarImage.heightAnchor.constraint(equalToConstant: 80),
            emptyFieldStarImage.widthAnchor.constraint(equalToConstant: 80),

            // Настройка emptyFieldLabel
            emptyFieldLabel.topAnchor.constraint(equalTo: emptyFieldStarImage.bottomAnchor, constant: 8),
            emptyFieldLabel.centerXAnchor.constraint(equalTo: contentStackView.centerXAnchor),
            emptyFieldLabel.widthAnchor.constraint(equalToConstant: 343),
            emptyFieldLabel.heightAnchor.constraint(equalToConstant: 72),

            // Настройка addCategoryButton
            addCategoryButton.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
             // Исправление привязки
            addCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -45) // Привязываем к contentStackView
        ])
        
        
    }
    
    private func updateTableHeight() {
        let rowHeight: CGFloat = 75
        let newHeight = rowHeight * CGFloat(categoriesList.count)
        tableHeightConstraint?.constant = newHeight
        view.layoutIfNeeded()
        print("Table height updated to \(newHeight)")// Применяем изменения макета
    }
    
    @objc private func addCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.delegate = self 
        let navigationController = UINavigationController(rootViewController: newCategoryVC)
        navigationController.modalPresentationStyle = .automatic
        present(navigationController, animated: true)
    }
    
    
    
    func didAddCategory(_ category: String) {
        print("Вызван метод didAddCategory")
        categoriesList.append(category)
        print("Добавлена новая категория \(category)")
        categoriesListTableView.reloadData() // Обновляем таблицу после добавления
        updateUI()
        
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
        cell.configure(with: category)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Вы выбрали ячейку: \(categoriesList[indexPath.row])")
        if let cell = tableView.cellForRow(at: indexPath) as? CategoriesListTableCell {
            
            cell.selectionStyle = .none
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            
            if let cell = tableView.cellForRow(at: indexPath) as? CategoriesListTableCell {
                cell.setSelected(false, animated: true)
            }
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
    
    private func createContextMenu(for indexPath: IndexPath) -> UIMenu {
            // Пункт "Редактировать"
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self.editItem(at: indexPath)
            }
            
            // Пункт "Удалить"
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.deleteItem(at: indexPath)
            }
            
            // Создание меню
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
        
        private func editItem(at indexPath: IndexPath) {
            // Получаем текущий текст из лейбла ячейки
            guard let cell = categoriesListTableView.cellForRow(at: indexPath) as? CategoriesListTableCell else { return }
                let currentText = cell.categoryNameLabel.text ?? ""
                
                // Создаём UIAlertController с текстовым полем
                let alert = UIAlertController(title: "Редактировать", message: "Введите новое название категории", preferredStyle: .alert)
                alert.addTextField { textField in
                    textField.text = currentText
                    textField.placeholder = "Название категории"
                }
                
                // Добавляем действия
                let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
                    guard let newText = alert.textFields?.first?.text, !newText.isEmpty else { return }
                    
                    // Обновляем текст лейбла
                    cell.categoryNameLabel.text = newText
                    
                    // Если текст привязан к данным, обновляем и их
                    self?.categoriesList[indexPath.row] = newText
                }
                let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
                
                alert.addAction(saveAction)
                alert.addAction(cancelAction)
                
                // Показываем UIAlertController
                present(alert, animated: true, completion: nil)
            print("Редактировать элемент: \(categoriesList[indexPath.row])")
        }
        
        private func deleteItem(at indexPath: IndexPath) {
            categoriesList.remove(at: indexPath.row)
            categoriesListTableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateTableHeight()
            self.categoriesListTableView.reloadData()
        }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = 16

        // Сброс настроек для всех ячеек
        cell.layer.cornerRadius = 0
        cell.layer.maskedCorners = []
        cell.clipsToBounds = true
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Обычные отступы для разделителя

        // Скругление первой ячейки
        if indexPath.row == 0 {
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // Разделитель остается видимым
        }

        // Скругление последней ячейки
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        }
    }
}

