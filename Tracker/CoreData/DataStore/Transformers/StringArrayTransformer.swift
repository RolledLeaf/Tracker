import Foundation

class StringArrayTransformer: ValueTransformer {
    
    // Преобразуем массив строк в данные
    override func transformedValue(_ value: Any?) -> Any? {
        guard let stringArray = value as? [String] else { return nil }
        return try? PropertyListEncoder().encode(stringArray)
    }
    
    // Преобразуем данные обратно в массив строк
     func transformedValueForReverseTransformation(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        
        do {
            let decodedArray = try PropertyListDecoder().decode([String].self, from: data)
            return decodedArray
        } catch {
            print("Failed to decode data: \(error)")
        }
        
        return nil
    }
}
