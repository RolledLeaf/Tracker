
import UIKit

enum CustomColor: String {
    case backgroundGray = "backgroundGray"
    case textColor = "TextColor"
    case dataGray = "dataGray"
    case createButtonColor = "createButtonColor"
    case createButtonTextColor = "createButtonTextColor"
    case textFieldGray = "textFieldGray"
    case cancelButtonRed = "cancelButtonRed"
    case toggleSwitchBlue = "toggleSwitchBlue"
    case mainBackgroundColor = "mainBackgroundColor"
    case tabBarSeparateLineColor = "tabBarSeparateLineColor"
    case tablesColor = "tablesColor"
}

enum CollectionColors: String  {
    case collectionRed1 = "collectionRed1"
    case collectionOrange2 = "collectionOrange2"
    case collectionBlue3 = "collectionBlue3"
    case collectionPurple4 = "collectionPurple4"
    case collectionLightGreen5 = "collectionLightGreen5"
    case collectionViolet6 = "collectionViolet6"
    case collectionBeige7 = "collectionBeige7"
    case collectionLightBlue8 = "collectionLightBlue8"
    case collectionJadeGreen9 = "collectionJadeGreen9"
    case collectionDarkPurple10 = "collectionDarkPurple10"
    case collectionCarrotOrange11 = "collectionCarrotOrange11"
    case collectionPink12 = "collectionPink12"
    case collectionLightBrick13 = "collectionLightBrick13"
    case collectionSemiblue14 = "collectionSemiblue14"
    case collectionLightPurple15 = "collectionLightPurple15"
    case collectionDarkViolet16 = "collectionDarkViolet16"
    case collectionPalePurple17 = "collectionPalePurple17"
    case collectionGreen18 = "collectionGreen18"
    
    var uiColor: UIColor? {
            return UIColor(named: self.rawValue)
        }
}

 func adjustAlpha(_ color: UIColor, to alpha: CGFloat) -> UIColor {
        return color.withAlphaComponent(alpha)
    }



func lightenColor(_ color: UIColor, by percentage: CGFloat) -> UIColor {
    // Ограничиваем процент в пределах от 0 до 1
    let percentage = max(0, min(percentage, 1))
    
    // Получаем компоненты цвета (red, green, blue, alpha)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    // Убедимся, что цвет может быть представлен в RGB
    guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
        return color // Возвращаем исходный цвет, если не удалось извлечь компоненты
    }
    
    // Увеличиваем компоненты на указанный процент
    red = min(red + (1 - red) * percentage, 1)
    green = min(green + (1 - green) * percentage, 1)
    blue = min(blue + (1 - blue) * percentage, 1)
    
    // Возвращаем новый цвет
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
}

extension UIColor {
    static func custom(_ color: CustomColor) -> UIColor? {
        return UIColor(named: color.rawValue) ?? .clear
    }
    
        static func fromCollectionColor(_ color: CollectionColors) -> UIColor? {
            return UIColor(named: color.rawValue)
        }
    }

