import Foundation

enum AquaShelfLayout: String, Codable, CaseIterable, Sendable {
    case largeCards
    case compact

    var label: String {
        switch self {
        case .largeCards: "Large cards"
        case .compact: "Compact"
        }
    }
}
