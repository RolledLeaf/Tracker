import Foundation
import UIKit

class AlertController: UIViewController {
    func showAlert(message: String) {
       let alert = UIAlertController(title: "Missing Information", message: message, preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "OK", style: .default))
       present(alert, animated: true)
   }

}
