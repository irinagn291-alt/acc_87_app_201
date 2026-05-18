import Foundation

enum AquaStrings {
    static let appName = "Slice Book"
    static let unknownTitle = "Untitled"
    static let unknownAuthor = "Unknown author"
    static let offlineFallback = "Couldn't reach Open Library. Check your connection."

    static func userFacingError(_ error: Error, fallback: String = offlineFallback) -> String? {
        if error is CancellationError { return nil }
        let ns = error as NSError
        if ns.domain == NSURLErrorDomain, ns.code == NSURLErrorCancelled { return nil }
        if let le = error as? LocalizedError {
            let d = le.errorDescription?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let d, !d.isEmpty { return d }
        }
        let raw = error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        if !raw.isEmpty { return raw }
        return fallback
    }
}

extension Notification.Name {
    static let aquaPilotPreferencesChanged = Notification.Name("AquaPilotPreferencesChanged")
}
