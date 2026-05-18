import Foundation

enum AquaReadStatus: String, Codable, CaseIterable, Sendable {
    case wantToRead
    case reading
    case finished
    case paused
    case dropped

    var label: String {
        switch self {
        case .wantToRead: "Want to read"
        case .reading: "Reading"
        case .finished: "Finished"
        case .paused: "Paused"
        case .dropped: "Dropped"
        }
    }
}
