import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        delegate = self
    }
    
    private func setupTabBar() {
        let trackerVC = TrackersViewController()
        let statisticsVC = StatisticsViewController()
        
        trackerVC.tabBarItem = UITabBarItem(title: NSLocalizedString("trackers", comment: ""), image: UIImage(named: "tracker"), tag: 0)
        
        statisticsVC.tabBarItem = UITabBarItem(title: NSLocalizedString("statistics", comment: ""), image: UIImage(named: "statistics"), tag: 1)
        
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
            separatorLine.heightAnchor.constraint(equalToConstant: 1) //
        ])
    }
}
    
extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is TrackersViewController {
            print("TrackersViewController is selected")
        } else if viewController is StatisticsViewController {
            Analytics.logEvent(.statisticsViewed)
        }
    }
    
}
