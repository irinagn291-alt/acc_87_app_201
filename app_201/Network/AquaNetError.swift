import Foundation

enum AquaNetError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid URL"
        case .invalidResponse: "Invalid server response"
        case .httpStatus(let c): "Network error (code \(c))"
        case .decoding: "Could not parse data"
        case .noData: "No data"
        }
    }
}
