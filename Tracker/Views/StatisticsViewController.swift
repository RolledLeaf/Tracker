
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
        tableView.showsVerticalScrollIndicator = false
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
        statisticsTableView.isScrollEnabled = false
        
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
            statisticsTableView.heightAnchor.constraint(equalToConstant: 410)
            
        ])
        statisticsTableView.dataSource = self
        statisticsTableView.register(StatisticsCell.self, forCellReuseIdentifier: StatisticsCell.identifier)
        statisticsTableView.delegate = self
    }
    
}

extension StatisticsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        statisticsTableParameters.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsCell.identifier, for: indexPath) as? StatisticsCell else {
            print("Unable to dequeue cell")
            return UITableViewCell()
        }
        cell.configure(with: statisticsTableParameters[indexPath.section])
        
        return cell
    }
}

extension StatisticsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12 // отступ между ячейками
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        return spacer
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let gradient = CAGradientLayer()
        gradient.name = "gradientBorder"
        gradient.frame = cell.bounds
        gradient.colors = [
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor,  // #FD4C49
            
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor, // #46E69D
            
            UIColor(red: 0.0, green: 123/255, blue: 250/255, alpha: 1).cgColor // #007BFA
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        
        // Создаём маску — рамка толщиной 2 pt
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: cell.bounds.insetBy(dx: 1.5, dy: 1.5), cornerRadius: 16)
        let outerPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 16)
        path.append(outerPath.reversing())
        maskLayer.path = path.cgPath
        gradient.mask = maskLayer
        
        cell.contentView.layer.insertSublayer(gradient, at: 0)
        
        
        cell.layer.cornerRadius = 16
        cell.clipsToBounds = true
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.systemGray6.cgColor
    }
    
}

