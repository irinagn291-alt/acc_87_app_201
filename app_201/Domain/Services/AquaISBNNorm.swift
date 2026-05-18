import Foundation

enum AquaISBNNorm {
    static func digitsOnly(_ raw: String) -> String {
        raw.filter { $0.isNumber }
    }

    static func looksLikeISBN(_ text: String) -> Bool {
        let d = digitsOnly(text)
        return d.count == 13 || d.count == 10
    }

    static func normalize(fromScanned raw: String) -> String? {
        let d = digitsOnly(raw)
        if d.count == 13 || d.count == 10 { return d }
        return nil
    }
}
