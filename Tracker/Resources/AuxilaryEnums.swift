enum OnboardingImage: String {
    case firstPage = "firstPage"
    case secondPage = "secondPage"
}

enum UserDefaultsKeys {
    static let hasSeenOnboarding = "hasSeenOnboarding"
    static let selectedFilter = "selectedFilter"
}

enum EditAction: String {
    case pin = "Закрепить"
    case unpin = "Открепить"
    case edit = "Редактировать"
    case delete = "Удалить"
}

enum TrackerFilterType: String {
    case all
    case today
    case completed
    case uncompleted
}

