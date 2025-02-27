import CoreData

@objc(CollectionColorsTransformer)
class CollectionColorsTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSString.self // Возвращаем NSString, так как color — это строка.
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let colorString = value as? String else { return nil }
        return CollectionColors(rawValue: colorString)?.rawValue // Конвертируем строку в rawValue.
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let colorString = value as? String else { return nil }
        return CollectionColors(rawValue: colorString) // Возвращаем соответствующий enum.
    }
}
