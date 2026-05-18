import Foundation

struct AquaProgressEvent: Identifiable, Hashable, Sendable {
    var id: UUID
    var bookId: UUID
    var date: Date
    var pagesDelta: Int
}
