enum OnboardingImage: String {
    case firstPage = "firstPage"
    case secondPage = "secondPage"
}

enum UserDefaultsKeys {
    static let hasSeenOnboarding = "hasSeenOnboarding"
    static let selectedFilter = "selectedFilter"
}

enum TrackerFilterType: String {
    case all = "all"
    case today = "today"
    case completed = "completed"
    case uncompleted = "uncompleted"
}
