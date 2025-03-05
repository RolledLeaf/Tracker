import Foundation

@objc(StringArrayTransformer)
class StringArrayTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? [String] else { return nil }
        return value.joined(separator: " ")
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let value = value as? String else { return nil }
        return value.components(separatedBy: " ") 
    }
}
