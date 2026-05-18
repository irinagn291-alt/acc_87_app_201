import Foundation
import SwiftData

@MainActor
final class AquaProgressStore: AquaProgressRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func logDelta(bookId: UUID, delta: Int) throws {
        guard delta != 0 else { return }
        context.insert(SDPilotProgressEvent(bookId: bookId, pagesDelta: delta))
        try context.save()
    }

    func events(for bookId: UUID) throws -> [AquaProgressEvent] {
        let fd = FetchDescriptor<SDPilotProgressEvent>(
            predicate: #Predicate { $0.bookId == bookId },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return try context.fetch(fd).map {
            AquaProgressEvent(id: $0.id, bookId: $0.bookId, date: $0.date, pagesDelta: $0.pagesDelta)
        }
    }

    func allEvents() throws -> [AquaProgressEvent] {
        let fd = FetchDescriptor<SDPilotProgressEvent>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return try context.fetch(fd).map {
            AquaProgressEvent(id: $0.id, bookId: $0.bookId, date: $0.date, pagesDelta: $0.pagesDelta)
        }
    }
}
