import Foundation
import SwiftData

@MainActor
final class AquaMoodStore: AquaMoodListRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func allLists() throws -> [AquaMoodListRow] {
        let fd = FetchDescriptor<SDPilotMoodList>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try context.fetch(fd).map { list in
            AquaMoodListRow(
                id: list.id,
                title: list.title,
                moodKey: list.moodKey,
                createdAt: list.createdAt,
                books: list.books.map {
                    AquaSavedMoodBook(
                        id: $0.id,
                        openLibraryId: $0.openLibraryId,
                        title: $0.title,
                        authors: AquaDataMapper.decodeStrings($0.authorsJSON),
                        coverId: $0.coverId
                    )
                }
            )
        }
    }

    func saveList(title: String, moodKey: String, books: [AquaSearchHit]) throws {
        let list = SDPilotMoodList(title: title, moodKey: moodKey)
        context.insert(list)
        for h in books {
            context.insert(SDPilotMoodBook(
                openLibraryId: h.openLibraryId,
                title: h.title,
                authorsJSON: AquaDataMapper.encodeStrings(h.authors),
                coverId: h.coverId,
                moodList: list
            ))
        }
        try context.save()
    }

    func deleteList(id: UUID) throws {
        let fd = FetchDescriptor<SDPilotMoodList>(predicate: #Predicate { $0.id == id })
        for o in try context.fetch(fd) { context.delete(o) }
        try context.save()
    }
}
