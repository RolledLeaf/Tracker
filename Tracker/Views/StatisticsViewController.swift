
import Foundation
import UIKit

final class StatisticsViewController: UIViewController {
    
    
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CustomColor.textColor.rawValue)
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        label.text = "Статистика"
        return label
    }()
    
    lazy var statisticsPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: CustomColor.textColor.rawValue)
        label.text = "Анализировать пока нечего"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var statisticsTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = 90
        let layer = tableView.layer
        layer.cornerRadius = 16
        return tableView
    }()
    
    private let statisticsPlaceholderImage = UIImageView()
    private var bestPeriod: Int?
    private var perfectDays: Int?
    private var completedTrackers: Int?
    private var averageStat: Int?
    
    var statisticsTableParameters: [(title: Int, subtitle: String)] = [
        (title: 0, subtitle: "Лучший период"),
        (title: 0, subtitle: "Идеальные дни"),
        (title: 0, subtitle: "Трекеров завершено"),
        (title: 0, subtitle: "Среднее значение")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updatePlaceholderVisibility()
    }
    
    private func updatePlaceholderVisibility() {
        statisticsPlaceholderLabel.isHidden = bestPeriod != nil
        statisticsPlaceholderImage.isHidden = bestPeriod != nil
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: CustomColor.mainBackgroundColor.rawValue)
        
        statisticsPlaceholderImage.image = UIImage(named: "statisticsPlaceholder")
        
        let uiElements = [titleLabel, statisticsPlaceholderLabel, statisticsPlaceholderImage, statisticsTableView]
        uiElements.forEach { view.addSubview($0) }
        uiElements.forEach { $0 .translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            statisticsPlaceholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticsPlaceholderLabel.topAnchor.constraint(equalTo: statisticsPlaceholderImage.bottomAnchor, constant: 8),
            
            statisticsPlaceholderImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 375),
            statisticsPlaceholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticsPlaceholderImage.widthAnchor.constraint(equalToConstant: 80),
            statisticsPlaceholderImage.heightAnchor.constraint(equalToConstant: 80),
            
            statisticsTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            statisticsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticsTableView.heightAnchor.constraint(equalToConstant: 396)
            
        ])
        statisticsTableView.dataSource = self
        statisticsTableView.register(StatisticsCell.self, forCellReuseIdentifier: StatisticsCell.identifier)
    }
}
    
extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        statisticsTableParameters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsCell.identifier, for: indexPath) as? StatisticsCell else {
            print("Unable to dequeue cell")
            return UITableViewCell()
        }
        cell.configure(with: statisticsTableParameters[indexPath.row])
        return cell
    }
}
    


