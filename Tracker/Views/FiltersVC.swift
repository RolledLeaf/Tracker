import UIKit

final class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    lazy var filtersTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = 75
        let layer = tableView.layer
        layer.cornerRadius = 16
        return tableView
    }()
    
    var onFilterSelected: ((TrackerFilterType) -> Void)?
    private var filterTitles: [String] = ["Все трекеры", "Трекеры на сегодня", "Завершённые", "Не завершённые"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: CustomColor.mainBackgroundColor.rawValue)
        view.addSubview(titleLabel)
        view.addSubview(filtersTableView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        filtersTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 152),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -152),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            filtersTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            filtersTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            filtersTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            filtersTableView.heightAnchor.constraint(equalToConstant: 300)
            
        ])
        
        filtersTableView.register(FiltersTableCell.self, forCellReuseIdentifier: FiltersTableCell.identifier)
        
        filtersTableView.dataSource = self
        filtersTableView.delegate = self
    }
}

extension FiltersViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filterTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FiltersTableCell.identifier, for: indexPath) as? FiltersTableCell else {
            print("Unable to dequeue cell")
            return UITableViewCell()
        }
        cell.configure(with: filterTitles[indexPath.row])
        cell.customSeparator.isHidden = indexPath.row == filterTitles.count - 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter: TrackerFilterType
        
        switch indexPath.row {
        case 0:
            selectedFilter = .all
        case 1:
            selectedFilter = .today
        case 2:
            selectedFilter = .completed
        case 3:
            selectedFilter = .uncompleted
        default:
            selectedFilter = .all
        }
        onFilterSelected?(selectedFilter)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = 16
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)

        cell.layer.cornerRadius = 0
        cell.layer.maskedCorners = []

        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        if indexPath.row == 0 {
            cell.contentView.layer.cornerRadius = cornerRadius
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.contentView.clipsToBounds = false
        } else if indexPath.row == totalRows - 1 {
            cell.contentView.layer.cornerRadius = cornerRadius
            cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.contentView.clipsToBounds = false

           
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        } else {
            cell.contentView.layer.cornerRadius = 0
            cell.contentView.layer.maskedCorners = []
            cell.contentView.clipsToBounds = false
        }
    }
}
