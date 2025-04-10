import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupTabBar()
    }
    
    private func setupTabBar() {
        let trackerVC = TrackersViewController()
        let statisticsVC = StatisticsViewController()
        
        trackerVC.tabBarItem = UITabBarItem(title: NSLocalizedString("trackers", comment: ""), image: UIImage(named: "tracker"), tag: 0)
        
        statisticsVC.tabBarItem = UITabBarItem(title: NSLocalizedString("statistics", comment: ""), image: UIImage(named: "statistics"), tag: 1)
        
        // Оборачиваем каждый контроллер в UINavigationController,
        // чтобы корректно отображался navigation bar и stack
        viewControllers = [UINavigationController(rootViewController: trackerVC),
                           UINavigationController(rootViewController: statisticsVC)]
        tabBar.backgroundColor = UIColor.custom(.mainBackgroundColor)
        
        addSeparatorLine()
    }
    
    private func addSeparatorLine() {
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.custom(.tabBarSeparateLineColor)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(separatorLine)
        
        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            separatorLine.topAnchor.constraint(equalTo: tabBar.topAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
    
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Получаем корневой контроллер из UINavigationController,
        // так как viewController — это UINavigationController
        if let nav = viewController as? UINavigationController,
           let root = nav.viewControllers.first {
            
            if root is TrackersViewController {
                print("TrackersViewController is selected")
                
            } else if root is StatisticsViewController {
                print("StatisticsViewController is selected")
                Analytics.logEvent(.statisticsViewed)
            }
        }
    }
}
