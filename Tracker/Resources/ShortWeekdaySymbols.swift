import Foundation

 var shortWeekdaySymbols: [String] {
    return Bundle.main.localizedString(forKey: "shortWeekDaysSymbols", value: nil, table: nil).components(separatedBy: ", ")
}
