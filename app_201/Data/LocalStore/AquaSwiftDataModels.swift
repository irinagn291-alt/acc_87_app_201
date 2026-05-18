import Foundation
import SwiftData

@Model
final class SDPilotBook {
    @Attribute(.unique) var id: UUID
    var openLibraryId: String
    var workKey: String?
    var title: String
    var authorsJSON: String
    var coverId: Int?
    var coverURL: String?
    var firstPublishYear: Int?
    var subjectsJSON: String
    var statusRaw: String
    var currentPage: Int
    var totalPages: Int?
    var rating: Double?
    var noteText: String?
    var noteCreatedAt: Date?
    var noteUpdatedAt: Date?
    var dateAdded: Date
    var dateStarted: Date?
    var dateFinished: Date?
    var lastUpdated: Date

    init(
        id: UUID = UUID(),
        openLibraryId: String,
        workKey: String?,
        title: String,
        authorsJSON: String,
        coverId: Int?,
        coverURL: String?,
        firstPublishYear: Int?,
        subjectsJSON: String,
        statusRaw: String,
        currentPage: Int,
        totalPages: Int?,
        rating: Double?,
        noteText: String?,
        noteCreatedAt: Date?,
        noteUpdatedAt: Date?,
        dateAdded: Date,
        dateStarted: Date?,
        dateFinished: Date?,
        lastUpdated: Date
    ) {
        self.id = id
        self.openLibraryId = openLibraryId
        self.workKey = workKey
        self.title = title
        self.authorsJSON = authorsJSON
        self.coverId = coverId
        self.coverURL = coverURL
        self.firstPublishYear = firstPublishYear
        self.subjectsJSON = subjectsJSON
        self.statusRaw = statusRaw
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.rating = rating
        self.noteText = noteText
        self.noteCreatedAt = noteCreatedAt
        self.noteUpdatedAt = noteUpdatedAt
        self.dateAdded = dateAdded
        self.dateStarted = dateStarted
        self.dateFinished = dateFinished
        self.lastUpdated = lastUpdated
    }
}

@Model
final class SDPilotPrefs {
    @Attribute(.unique) var id: UUID
    var hasCompletedOnboarding: Bool
    var selectedGenresJSON: String
    var themeRaw: String
    var shelfLayoutRaw: String
    var readingGoalsJSON: String

    init(
        id: UUID = UUID(),
        hasCompletedOnboarding: Bool = false,
        selectedGenresJSON: String = "[]",
        themeRaw: String = AquaDisplayTheme.system.rawValue,
        shelfLayoutRaw: String = AquaShelfLayout.largeCards.rawValue,
        readingGoalsJSON: String = "[]"
    ) {
        self.id = id
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.selectedGenresJSON = selectedGenresJSON
        self.themeRaw = themeRaw
        self.shelfLayoutRaw = shelfLayoutRaw
        self.readingGoalsJSON = readingGoalsJSON
    }
}

@Model
final class SDPilotMoodList {
    @Attribute(.unique) var id: UUID
    var title: String
    var moodKey: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \SDPilotMoodBook.moodList)
    var books: [SDPilotMoodBook] = []

    init(id: UUID = UUID(), title: String, moodKey: String, createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.moodKey = moodKey
        self.createdAt = createdAt
    }
}

@Model
final class SDPilotMoodBook {
    @Attribute(.unique) var id: UUID
    var openLibraryId: String
    var title: String
    var authorsJSON: String
    var coverId: Int?
    var moodList: SDPilotMoodList?

    init(id: UUID = UUID(), openLibraryId: String, title: String, authorsJSON: String, coverId: Int?, moodList: SDPilotMoodList? = nil) {
        self.id = id
        self.openLibraryId = openLibraryId
        self.title = title
        self.authorsJSON = authorsJSON
        self.coverId = coverId
        self.moodList = moodList
    }
}

@Model
final class SDPilotProgressEvent {
    @Attribute(.unique) var id: UUID
    var bookId: UUID
    var date: Date
    var pagesDelta: Int

    init(id: UUID = UUID(), bookId: UUID, date: Date = .now, pagesDelta: Int) {
        self.id = id
        self.bookId = bookId
        self.date = date
        self.pagesDelta = pagesDelta
    }
}

@Model
final class SDPilotWeekEntry {
    @Attribute(.unique) var id: UUID
    var dayIndex: Int
    var openLibraryId: String
    var title: String
    var authorsJSON: String
    var coverId: Int?
    var addedAt: Date

    init(id: UUID = UUID(), dayIndex: Int, openLibraryId: String, title: String, authorsJSON: String, coverId: Int?, addedAt: Date = .now) {
        self.id = id
        self.dayIndex = dayIndex
        self.openLibraryId = openLibraryId
        self.title = title
        self.authorsJSON = authorsJSON
        self.coverId = coverId
        self.addedAt = addedAt
    }
}
