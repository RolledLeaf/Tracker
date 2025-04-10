
//Расширение, исключающее пустые строки, заполненные символами переноса или табуляции, пробелами

extension String {
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
