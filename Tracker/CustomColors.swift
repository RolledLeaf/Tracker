
import UIKit

enum CustomColors: String {
    case backgroundGray = "backgroundGray"
    case textColor = "textColor"
    case collectionOrange = "collectionOrange"
    case dataGray = "dataGray"
}

extension UIColor {
    static func custom(_ color: CustomColors) -> UIColor? {
        return UIColor(named: color.rawValue) ?? .clear
    }
}
