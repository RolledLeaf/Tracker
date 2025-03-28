
enum OnboardingImage: String {
    case firstPage = "firstPage"
    case secondPage = "secondPage"
}

enum UserDefaultsKeys {
    static let hasSeenOnboarding = "hasSeenOnboarding"
}

enum EditAction: String {
    case pin = "Закрепить"
    case edit = "Редактировать"
    case delete = "Удалить"
}
