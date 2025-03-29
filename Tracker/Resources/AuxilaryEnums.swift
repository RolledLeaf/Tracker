
enum OnboardingImage: String {
    case firstPage = "firstPage"
    case secondPage = "secondPage"
}

enum UserDefaultsKeys {
    static let hasSeenOnboarding = "hasSeenOnboarding"
}

enum EditAction: String {
    case pin = "Закрепить"
    case unpin = "Открепить"
    case edit = "Редактировать"
    case delete = "Удалить"
}
