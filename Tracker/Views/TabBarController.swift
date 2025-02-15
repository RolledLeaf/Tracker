import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let trackerVC = TrackersViewController()
        let statisticsVC = StatisticsViewController()
        
        trackerVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "tracker"), tag: 0)
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "statistics"), tag: 1)
        
        viewControllers = [UINavigationController(rootViewController: trackerVC),
                           UINavigationController(rootViewController: statisticsVC)]
        
        tabBar.backgroundColor = UIColor.custom(.mainBackgroundColor)
        
        addSeparatorLine()
    }
    
    private func addSeparatorLine() {
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.custom(.tabBarSeparateLineColor) // Цвет линии (можно настроить по желанию)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(separatorLine)
        
        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            separatorLine.topAnchor.constraint(equalTo: tabBar.topAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1) //
        ])
    }
}
