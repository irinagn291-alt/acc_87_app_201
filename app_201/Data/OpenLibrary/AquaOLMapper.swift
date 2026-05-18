import Foundation

enum AquaOLMapper {
    static func workId(fromWorkKey key: String?) -> String {
        guard let key else { return UUID().uuidString }
        return key.hasPrefix("/works/") ? String(key.dropFirst("/works/".count)) : key
    }

    static func workKey(fromDocKey key: String?) -> String? {
        guard let key, !key.isEmpty else { return nil }
        return key.hasPrefix("/works/") ? key : "/works/\(key)"
    }

    static func searchHits(from dto: AquaOLSearchResponse) -> [AquaSearchHit] {
        (dto.docs ?? []).compactMap { doc in
            guard let key = doc.key else { return nil }
            return AquaSearchHit(
                openLibraryId: workId(fromWorkKey: key),
                workKey: workKey(fromDocKey: doc.key),
                title: doc.title ?? AquaStrings.unknownTitle,
                authors: doc.authorName ?? [],
                coverId: doc.coverI,
                firstPublishYear: doc.firstPublishYear,
                subjects: Array((doc.subject ?? []).prefix(12)),
                numberOfPagesMedian: doc.numberOfPagesMedian
            )
        }
    }

    static func workDetail(from dto: AquaOLWork, fallbackAuthors: [String]) -> AquaWorkDetail? {
        guard let key = dto.key else { return nil }
        let fromKeys = (dto.authors ?? []).compactMap { $0.author?.key?.split(separator: "/").last.map(String.init) }
        let authors: [String] = {
            if !fallbackAuthors.isEmpty { return fallbackAuthors }
            if !fromKeys.isEmpty { return fromKeys }
            return [AquaStrings.unknownAuthor]
        }()
        let year = dto.firstPublishDate.flatMap { Int($0.prefix(4)) }
        return AquaWorkDetail(
            workKey: key.hasPrefix("/works/") ? key : "/works/\(key)",
            title: dto.title ?? AquaStrings.unknownTitle,
            authors: authors,
            description: dto.description?.plainText,
            subjects: dto.subjects ?? [],
            firstPublishYear: year,
            coverId: dto.covers?.first,
            numberOfPagesMedian: nil
        )
    }

    static func subjectBooks(from dto: AquaOLSubjectResponse) -> [AquaSubjectBook] {
        (dto.works ?? []).compactMap { w in
            guard let key = w.key else { return nil }
            let names = (w.authors ?? []).compactMap(\.name)
            return AquaSubjectBook(
                key: key,
                title: w.title ?? AquaStrings.unknownTitle,
                authors: names.isEmpty ? [AquaStrings.unknownAuthor] : names,
                coverId: w.coverId,
                firstPublishYear: w.firstPublishYear
            )
        }
    }
}
