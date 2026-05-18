import Foundation

enum AquaGenreCatalog {
    static let allMoods: [AquaMoodDefinition] = [
        AquaMoodDefinition(moodKey: "calm", displayTitle: "Calm", subjectSlugs: ["poetry", "classics", "nature"]),
        AquaMoodDefinition(moodKey: "inspired", displayTitle: "Inspired", subjectSlugs: ["self-help", "biography", "philosophy"]),
        AquaMoodDefinition(moodKey: "melancholy", displayTitle: "Melancholy", subjectSlugs: ["drama", "literary-fiction"]),
        AquaMoodDefinition(moodKey: "romantic", displayTitle: "Romantic", subjectSlugs: ["romance"]),
        AquaMoodDefinition(moodKey: "adventure", displayTitle: "Adventure", subjectSlugs: ["adventure", "fantasy", "travel"]),
        AquaMoodDefinition(moodKey: "thoughtful", displayTitle: "Thoughtful", subjectSlugs: ["philosophy", "science", "psychology"]),
        AquaMoodDefinition(moodKey: "light", displayTitle: "Light read", subjectSlugs: ["humor", "young-adult-fiction"]),
        AquaMoodDefinition(moodKey: "dark", displayTitle: "Dark & tense", subjectSlugs: ["horror", "mystery-and-detective-stories", "crime"]),
        AquaMoodDefinition(moodKey: "motivation", displayTitle: "Motivation", subjectSlugs: ["business", "productivity", "biography"]),
    ]

    static let onboardingGenres: [(slug: String, title: String)] = [
        ("fantasy", "Fantasy"),
        ("romance", "Romance"),
        ("science_fiction", "Sci-Fi"),
        ("mystery", "Mystery"),
        ("horror", "Horror"),
        ("history", "History"),
        ("biography", "Biography"),
        ("philosophy", "Philosophy"),
        ("psychology", "Psychology"),
        ("business", "Business"),
        ("poetry", "Poetry"),
        ("classics", "Classics"),
        ("adventure", "Adventure"),
        ("young-adult-fiction", "Young Adult"),
        ("art", "Art"),
        ("science", "Science"),
    ]

    static let popularSubjects: [(slug: String, title: String)] = [
        ("fantasy", "Fantasy"),
        ("romance", "Romance"),
        ("science_fiction", "Sci-Fi"),
        ("mystery", "Mystery"),
        ("horror", "Horror"),
        ("history", "History"),
        ("biography", "Biography"),
        ("young-adult-fiction", "YA"),
    ]
}
