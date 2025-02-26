import Foundation

@objc(WeekDaysTransformer)
class WeekDaysTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let weekDaysString = value as? String else { return nil }
        // Предполагаем, что строки представляют собой список дней через запятую или другой разделитель
        return weekDaysString.components(separatedBy: ",") // или другой разделитель
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let weekDaysArray = value as? [String] else { return nil }
        return weekDaysArray.joined(separator: ",") // Соединяем обратно в строку
    }
}
