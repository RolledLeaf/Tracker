
import UIKit

enum CustomColors: String {
    case backgroundGray = "backgroundGray"
    case textColor = "TextColor"
    case dataGray = "dataGray"
    case createButtonColor = "createButtonColor"
    case createButtonTextColor = "createButtonTextColor"
    case textFieldGray = "textFieldGray"
    case cancelButtonRed = "cancelButtonRed"
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

extension UIColor {
    static func custom(_ color: CustomColors) -> UIColor? {
        return UIColor(named: color.rawValue) ?? .clear
    }
    
        static func fromCollectionColor(_ color: CollectionColors) -> UIColor? {
            return UIColor(named: color.rawValue)
        }
    }

