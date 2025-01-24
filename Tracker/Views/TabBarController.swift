import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        
    }
    
    
    private func setupTabBar() {
        let trackerVC = TrackersViewController()
        let statisticsVC = StatisticsViewController()
        
        trackerVC.tabBarItem = UITabBarItem(title: "Tracker", image: UIImage(named: "tracker"), tag: 0)
        statisticsVC.tabBarItem = UITabBarItem(title: "Statistics", image: UIImage(named: "statistics"), tag: 1)
        
        viewControllers = [UINavigationController(rootViewController: trackerVC),
                           UINavigationController(rootViewController: statisticsVC)]
        
        tabBar.backgroundColor = UIColor.custom(.createButtonTextColor)
        
    }
}
