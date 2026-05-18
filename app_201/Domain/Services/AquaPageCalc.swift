import Foundation

enum AquaPageCalc {
    static func clamped(_ current: Int, total: Int?) -> Int {
        guard let total, total > 0 else { return max(0, current) }
        return min(max(0, current), total)
    }

    static func progressRatio(current: Int, total: Int?) -> Double? {
        guard let total, total > 0 else { return nil }
        return min(1, max(0, Double(current) / Double(total)))
    }
}
