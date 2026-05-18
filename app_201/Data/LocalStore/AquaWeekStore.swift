import Foundation
import SwiftData

struct AquaWeekItem: Identifiable, Hashable, Sendable {
    var id: UUID
    var dayIndex: Int
    var openLibraryId: String
    var title: String
    var authors: [String]
    var coverId: Int?
    var addedAt: Date
}

@MainActor
final class AquaWeekStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func allItems() throws -> [AquaWeekItem] {
        let fd = FetchDescriptor<SDPilotWeekEntry>(sortBy: [SortDescriptor(\.addedAt)])
        return try context.fetch(fd).map { e in
            AquaWeekItem(
                id: e.id,
                dayIndex: e.dayIndex,
                openLibraryId: e.openLibraryId,
                title: e.title,
                authors: AquaDataMapper.decodeStrings(e.authorsJSON),
                coverId: e.coverId,
                addedAt: e.addedAt
            )
        }
    }

    func add(hit: AquaSearchHit, dayIndex: Int) throws {
        context.insert(SDPilotWeekEntry(
            dayIndex: dayIndex,
            openLibraryId: hit.openLibraryId,
            title: hit.title,
            authorsJSON: AquaDataMapper.encodeStrings(hit.authors),
            coverId: hit.coverId
        ))
        try context.save()
    }

    func move(id: UUID, toDayIndex: Int) throws {
        let fd = FetchDescriptor<SDPilotWeekEntry>(predicate: #Predicate { $0.id == id })
        if let e = try context.fetch(fd).first {
            e.dayIndex = toDayIndex
            try context.save()
        }
    }

    func delete(id: UUID) throws {
        let fd = FetchDescriptor<SDPilotWeekEntry>(predicate: #Predicate { $0.id == id })
        for o in try context.fetch(fd) { context.delete(o) }
        try context.save()
    }
}
