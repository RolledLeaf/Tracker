
import UIKit

final class CategoriesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    
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
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.rowHeight = 75
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
    
    
    
    var categoriesList: [String]?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    
    private func updateUI() {
        if categoriesList == nil || categoriesList?.isEmpty == true {
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
        view.backgroundColor = UIColor(named: CustomColors.backgroundGray.rawValue)
        
        let tableHeight = CGFloat(categoriesList?.count ?? 1) * categoriesListTableView.rowHeight
        
        let stackView = UIStackView(arrangedSubviews: [emptyFieldStarImage, emptyFieldLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        
        let uiElements = [titleLabel, emptyFieldLabel, emptyFieldStarImage, categoriesListTableView, addCategoryButton]
        
        uiElements.forEach { view.addSubview($0) }
        
        uiElements.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        categoriesListTableView.dataSource = self
        categoriesListTableView.delegate = self
        
        categoriesListTableView.register(CategoriesListTableCell.self, forCellReuseIdentifier: CategoriesListTableCell.identifier)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 200),
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            
            categoriesListTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoriesListTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            categoriesListTableView.widthAnchor.constraint(equalToConstant: 343),
            categoriesListTableView.heightAnchor.constraint(equalToConstant: tableHeight),
            
            emptyFieldStarImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyFieldStarImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 232),
            emptyFieldStarImage.heightAnchor.constraint(equalToConstant: 80),
            emptyFieldStarImage.widthAnchor.constraint(equalToConstant: 80),
            
            emptyFieldLabel.topAnchor.constraint(equalTo: emptyFieldStarImage.bottomAnchor, constant: 8),
            emptyFieldLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyFieldLabel.widthAnchor.constraint(equalToConstant: 343),
            emptyFieldLabel.heightAnchor.constraint(equalToConstant: 72),
            
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
    }
    
   @objc private func addCategoryButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        let navigationController = UINavigationController(rootViewController: newCategoryVC)
        navigationController.modalPresentationStyle = .automatic
        present(navigationController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = categoriesList?.count
        return sections ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesListTableCell.identifier, for: indexPath) as? CategoriesListTableCell else {
            print("CategoriesTableView wasn't able to dequeue cell")
            return UITableViewCell()
        }
        
        guard categoriesList != nil else {
            print("Warning: categories is nil")
            
           return UITableViewCell()
        }
        return cell
    }
    
}
