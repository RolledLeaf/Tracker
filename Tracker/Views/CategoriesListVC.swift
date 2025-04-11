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
        label.text = NSLocalizedString("categoryTitleLabel", comment: "")
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
        label.text = NSLocalizedString("emptyCategories", comment: "")
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("addCategoryButton", comment: ""), for: .normal)
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
    private let notificationKey = "NewCategoryAdded"
    private var tableHeightConstraint: NSLayoutConstraint?
    private var contentViewHeightConstraint: NSLayoutConstraint?
    
    private lazy var viewModel = CategoriesViewModel(categoryStore: trackerCategoryStore)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        
        viewModel.onCategoriesUpdate = { [weak self] _ in
            self?.categoriesListTableView.reloadData()
        }
        viewModel.onCategorySelected = { [weak self] category in
            self?.delegate?.updateCategory(with: category)
        }
        
        viewModel.onEditCategoryRequest = { [weak self] category, currentText in
            let alert = UIAlertController(title: NSLocalizedString("contextMenuEdit", comment: ""), message: NSLocalizedString("newCategoryNameAlert", comment: ""), preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = currentText
            }
            
            let saveAction = UIAlertAction(title: NSLocalizedString(NSLocalizedString("save", comment: ""), comment: ""), style: .default) { _ in
                guard let newText = alert.textFields?.first?.text, !newText.isEmpty else { return }
                if let index = self?.viewModel.categories.firstIndex(where: { $0 == category }) {
                    self?.viewModel.updateCategoryName(at: index, newName: newText)
                }
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            self?.present(alert, animated: true, completion: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewCategoryAdded), name: NSNotification.Name(notificationKey), object: nil)
    }
    
    private func updateUI() {
        let isEmpty = viewModel.categories.isEmpty
        emptyFieldLabel.isHidden = !(isEmpty)
        emptyFieldStarImage.isHidden = !(isEmpty)
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
        
        let tableHeightConstraint = categoriesListTableView.heightAnchor.constraint(equalToConstant: 75)
        self.tableHeightConstraint = tableHeightConstraint
        
        let contentViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 260)
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
        let newHeight = rowHeight * CGFloat(viewModel.categories.count)
        tableHeightConstraint?.constant = newHeight
        view.layoutIfNeeded()
        print("Table height updated to \(newHeight)")
    }
    
    private func updateContentViewHeight() {
        let rowHeight: CGFloat = 260
        let newHeight = rowHeight + CGFloat(tableHeightConstraint?.constant ?? 500)
        contentViewHeightConstraint?.constant = newHeight
        view.layoutIfNeeded()
        print("Content view height updated to \(newHeight)")
    }
    
    private func createContextMenu(for indexPath: IndexPath) -> UIMenu {
        
        let editAction = UIAction(title: NSLocalizedString("contextMenuEdit", comment: ""), image: UIImage(systemName: "pencil")) { _ in
            self.viewModel.editCategory(at: indexPath.row, newName: self.viewModel.categories[indexPath.row].title ?? "")
        }
        
        let deleteAction = UIAction(title: NSLocalizedString("contextMenuDelete", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.viewModel.deleteCategory(at: indexPath.row)
            self.updateUI()
            
        }
        return UIMenu(title: "", children: [editAction, deleteAction])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesListTableCell.identifier, for: indexPath) as? CategoriesListTableCell else {
            print("CategoriesTableView wasn't able to dequeue cell")
            return UITableViewCell()
        }
        
        let category = viewModel.categories[indexPath.row]
        if category.title == NSLocalizedString("pinned", comment: "") {
            cell.setHidden(true)
        }
        cell.configure(with: category.title ?? NSLocalizedString("noNameString", comment: ""))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectCategory(at: indexPath.row)
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
        viewModel.fetchCategories()
        updateUI()
    }
    
    @objc private func addCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        let navigationController = UINavigationController(rootViewController: newCategoryVC)
        navigationController.modalPresentationStyle = .automatic
        present(navigationController, animated: true)
    }
}
