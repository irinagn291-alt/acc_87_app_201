import Foundation

enum AquaBookFactory {
    static func coverURLString(coverId: Int?, size: String = "M") -> String? {
        guard let coverId else { return nil }
        return "https://covers.openlibrary.org/b/id/\(coverId)-\(size).jpg"
    }

    static func fromSearchHit(_ hit: AquaSearchHit, status: AquaReadStatus) -> AquaBookEntry {
        let now = Date.now
        return AquaBookEntry(
            id: UUID(),
            openLibraryId: hit.openLibraryId,
            workKey: hit.workKey,
            title: hit.title,
            authors: hit.authors,
            coverId: hit.coverId,
            coverURL: coverURLString(coverId: hit.coverId),
            firstPublishYear: hit.firstPublishYear,
            subjects: hit.subjects,
            status: status,
            currentPage: 0,
            totalPages: hit.numberOfPagesMedian,
            rating: nil,
            noteText: nil,
            noteCreatedAt: nil,
            noteUpdatedAt: nil,
            dateAdded: now,
            dateStarted: status == .reading ? now : nil,
            dateFinished: nil,
            lastUpdated: now
        )
    }

    static func fromWorkDetail(_ detail: AquaWorkDetail, status: AquaReadStatus) -> AquaBookEntry {
        let now = Date.now
        let wid = AquaOLMapper.workId(fromWorkKey: detail.workKey)
        return AquaBookEntry(
            id: UUID(),
            openLibraryId: wid,
            workKey: detail.workKey,
            title: detail.title,
            authors: detail.authors,
            coverId: detail.coverId,
            coverURL: coverURLString(coverId: detail.coverId),
            firstPublishYear: detail.firstPublishYear,
            subjects: detail.subjects,
            status: status,
            currentPage: 0,
            totalPages: detail.numberOfPagesMedian,
            rating: nil,
            noteText: nil,
            noteCreatedAt: nil,
            noteUpdatedAt: nil,
            dateAdded: now,
            dateStarted: status == .reading ? now : nil,
            dateFinished: nil,
            lastUpdated: now
        )
    }

    static func mergedWithDetail(book: AquaBookEntry, detail: AquaWorkDetail) -> AquaBookEntry {
        var b = book
        b.title = detail.title
        if !detail.authors.isEmpty { b.authors = detail.authors }
        if let c = detail.coverId { b.coverId = c; b.coverURL = coverURLString(coverId: c) }
        if let y = detail.firstPublishYear { b.firstPublishYear = y }
        if !detail.subjects.isEmpty { b.subjects = detail.subjects }
        if b.totalPages == nil, let p = detail.numberOfPagesMedian { b.totalPages = p }
        b.lastUpdated = .now
        return b
    }
}

extension AquaSubjectBook {
    func asSearchHit() -> AquaSearchHit {
        let wid = AquaOLMapper.workId(fromWorkKey: key)
        let wk = AquaOLMapper.workKey(fromDocKey: key)
        return AquaSearchHit(
            openLibraryId: wid,
            workKey: wk,
            title: title,
            authors: authors,
            coverId: coverId,
            firstPublishYear: firstPublishYear,
            subjects: [],
            numberOfPagesMedian: nil
        )
    }
}
