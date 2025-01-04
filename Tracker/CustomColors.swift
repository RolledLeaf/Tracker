
import UIKit

enum CustomColors: String {
    case backgroundGray = "backgroundGray"
    case textColor = "textColor"
    case dataGray = "dataGray"
}

enum CollectionColors: String  {
    case collectionOrange = "collectionOrange"
    
}

extension UIColor {
    static func custom(_ color: CustomColors) -> UIColor? {
        return UIColor(named: color.rawValue) ?? .clear
    }
}
