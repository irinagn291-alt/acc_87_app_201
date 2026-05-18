import Foundation

enum AquaStatsEngine {
    struct TagCount: Hashable, Sendable {
        var name: String
        var count: Int
    }

    struct MonthCount: Hashable, Sendable {
        var month: String
        var count: Int
    }

    struct Summary: Equatable, Sendable {
        var totalBooks: Int
        var finished: Int
        var reading: Int
        var wantToRead: Int
        var paused: Int
        var dropped: Int
        var pagesEstimate: Int
        var averageRating: Double?
        var topAuthors: [TagCount]
        var topSubjects: [TagCount]
        var finishedByMonth: [MonthCount]
        var avgProgressActive: Double?
    }

    static func compute(books: [AquaBookEntry], events: [AquaProgressEvent]) -> Summary {
        var finished = 0, reading = 0, wantToRead = 0, paused = 0, dropped = 0
        var ratingSum = 0.0, ratingCount = 0
        var authorMap: [String: Int] = [:]
        var subjectMap: [String: Int] = [:]
        var monthMap: [String: Int] = [:]
        var progressSum = 0.0, progressCount = 0
        let cal = Calendar.current

        for b in books {
            switch b.status {
            case .finished: finished += 1
            case .reading: reading += 1
            case .wantToRead: wantToRead += 1
            case .paused: paused += 1
            case .dropped: dropped += 1
            }
            if let r = b.rating { ratingSum += r; ratingCount += 1 }
            for a in b.authors { authorMap[a, default: 0] += 1 }
            for s in b.subjects.prefix(8) { subjectMap[s, default: 0] += 1 }
            if b.status == .finished, let df = b.dateFinished {
                let c = cal.dateComponents([.year, .month], from: df)
                let key = "\(c.year ?? 0)-\(String(format: "%02d", c.month ?? 0))"
                monthMap[key, default: 0] += 1
            }
            if b.status == .reading, let p = AquaPageCalc.progressRatio(current: b.currentPage, total: b.totalPages) {
                progressSum += p; progressCount += 1
            }
        }

        let pagesFromBooks = books.reduce(0) { acc, b in
            if b.status == .finished, let t = b.totalPages { return acc + t }
            return acc + max(0, b.currentPage)
        }
        let pagesFromEvents = events.reduce(0) { $0 + max(0, $1.pagesDelta) }

        return Summary(
            totalBooks: books.count,
            finished: finished,
            reading: reading,
            wantToRead: wantToRead,
            paused: paused,
            dropped: dropped,
            pagesEstimate: max(pagesFromBooks, pagesFromEvents),
            averageRating: ratingCount > 0 ? ratingSum / Double(ratingCount) : nil,
            topAuthors: authorMap.map { TagCount(name: $0.key, count: $0.value) }.sorted { $0.count > $1.count }.prefix(8).map { $0 },
            topSubjects: subjectMap.map { TagCount(name: $0.key, count: $0.value) }.sorted { $0.count > $1.count }.prefix(8).map { $0 },
            finishedByMonth: monthMap.keys.sorted().map { MonthCount(month: $0, count: monthMap[$0] ?? 0) },
            avgProgressActive: progressCount > 0 ? progressSum / Double(progressCount) : nil
        )
    }
}
