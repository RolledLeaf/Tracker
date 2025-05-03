import UserNotifications
import UIKit

final class Notifications: NSObject,  UNUserNotificationCenterDelegate {
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func registerNotifications() {
        notificationCenter.delegate = self
        
        let notificationOptions = UNAuthorizationOptions([.alert, .badge, .sound])
        
        notificationCenter.requestAuthorization(options: notificationOptions) { granted, error in
            if granted {
                self.setupNotificationCategories()
                print("Notifications granted")
            } else {
                print("Notifications not granted")
            }
        }
    }
    
    func scheduleNotification(notificationType: NotificationType,  target: NotificationTarget) {
        let content = UNMutableNotificationContent()
        content.title = notificationType.title
        content.subtitle = "subtitle"
        content.body = notificationType.body
        content.badge = 1
        content.sound = .default
        content.userInfo = ["target": target.rawValue]
        content.categoryIdentifier = "category"
        
        //Настройка триггера
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4, repeats: false)
        
        let request = UNNotificationRequest(identifier: "welcome notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification \(error)")
            } else {
                print("Notification scheduled")
            }
        }
    }
    
    private func setupNotificationCategories() {
        let openAction = UNNotificationAction(identifier: "open",
                                              title: "Open",
                                              options: [.foreground])
        
        let dismissAcion = UNNotificationAction(identifier: "dissmiss_action",
                                                title: "Dismiss",
                                                options: [])
        
        let category = UNNotificationCategory(identifier: "category",
                                              actions: [openAction, dismissAcion],
                                              intentIdentifiers: [],
                                              options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
    
    private func handleNtification(response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        if let target = NotificationTarget(userInfo: userInfo) {
            
            print("Target: \(target) tapped")
            if let window = UIApplication.shared.windows.first {
                if let tabBarController = window.rootViewController as? UITabBarController {
                    switch target {
                    case .categories:
                        let trackersVC = TrackersViewController()
                        
                        let navigationController = UINavigationController(rootViewController: trackersVC)
                        
                        let createHabitTypeVC = CreateHabitTypeViewController()
                        navigationController.pushViewController(createHabitTypeVC, animated: true)
                        
                        let newHabitVC = NewHabitViewController()
                        navigationController.pushViewController(newHabitVC, animated: true)
                        
                        let categoryListVC = CategoriesListViewController()
                        navigationController.modalPresentationStyle = .automatic
                        navigationController.pushViewController(categoryListVC, animated: true)
                        
                        window.rootViewController?.present(navigationController, animated: true)
                    case .statistics:
                        tabBarController.selectedIndex = 1
                    }
                }
            }
        }
    }
}

extension Notifications {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        handleNtification(response: response)
        if response.actionIdentifier == "Open" {
            print("Пользователь нажал Открыть")
            // Здесь можно сделать переход
        } else if response.actionIdentifier == "Dismiss" {
            print("Пользователь нажал Отменить")
            // Можно ничего не делать или что-то отменить
        } else {
            handleNtification(response: response)
        }
    
        //Очищение бейджа количества уведомлений при его прочтении
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
}

extension Notifications {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .badge, .sound])
        }
    }
}

enum NotificationType {
    case statistics
    case tips
    
    var title: String {
        switch self {
        case .statistics:
            return "Статистика"
        case .tips:
            return "Советы"
        }
    }
    
    var body: String {
        switch self {
        case .statistics:
            return "Нажмите, чтобы посмотреть статистику"
        case .tips:
            return "Нажмите, чтобы получить советы"
        }
    }
}

enum NotificationTarget: String {
    case categories
    case statistics
    
    init?(userInfo: [AnyHashable: Any]) {
        guard let rawValue = userInfo["target"] as? String else { return nil }
        self.init(rawValue: rawValue)
    }
}
