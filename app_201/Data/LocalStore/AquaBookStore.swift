import Foundation
import SwiftData

@MainActor
final class AquaBookStore: AquaBookRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func allBooks() throws -> [AquaBookEntry] {
        let fd = FetchDescriptor<SDPilotBook>(sortBy: [SortDescriptor(\.lastUpdated, order: .reverse)])
        return try context.fetch(fd).map(AquaDataMapper.toDomain)
    }

    func book(id: UUID) throws -> AquaBookEntry? {
        let fd = FetchDescriptor<SDPilotBook>(predicate: #Predicate { $0.id == id })
        return try context.fetch(fd).first.map(AquaDataMapper.toDomain)
    }

    func upsert(_ book: AquaBookEntry) throws {
        let bookId = book.id
        let fd = FetchDescriptor<SDPilotBook>(predicate: #Predicate { $0.id == bookId })
        if let existing = try context.fetch(fd).first {
            AquaDataMapper.apply(book, to: existing)
        } else {
            context.insert(AquaDataMapper.newModel(from: book))
        }
        try context.save()
    }

    func delete(id: UUID) throws {
        let fd = FetchDescriptor<SDPilotBook>(predicate: #Predicate { $0.id == id })
        for o in try context.fetch(fd) { context.delete(o) }
        try context.save()
    }

    func clearAll() throws {
        let fd = FetchDescriptor<SDPilotBook>()
        for o in try context.fetch(fd) { context.delete(o) }
        try context.save()
    }
}
