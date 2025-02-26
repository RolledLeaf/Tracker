import Foundation

@objc(WeekDaysTransformer)
class WeekDaysTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let daysArray = value as? [String] else { return nil }
        return daysArray.joined(separator: " ") // Преобразуем в строку через пробел
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let daysString = value as? String else { return nil }
        return daysString.components(separatedBy: " ") // Преобразуем обратно в массив строк
    }
}
