import Foundation

struct AquaOLSearchResponse: Decodable {
    let numFound: Int?
    let docs: [AquaOLSearchDoc]?
}

struct AquaOLSearchDoc: Decodable {
    let key: String?
    let title: String?
    let authorName: [String]?
    let firstPublishYear: Int?
    let coverI: Int?
    let subject: [String]?
    let numberOfPagesMedian: Int?

    enum CodingKeys: String, CodingKey {
        case key, title
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
        case coverI = "cover_i"
        case subject
        case numberOfPagesMedian = "number_of_pages_median"
    }
}

struct AquaOLWork: Decodable {
    let key: String?
    let title: String?
    let authors: [AquaOLWorkAuthorRef]?
    let description: AquaOLDescription?
    let subjects: [String]?
    let firstPublishDate: String?
    let covers: [Int]?

    enum CodingKeys: String, CodingKey {
        case key, title, authors, description, subjects, covers
        case firstPublishDate = "first_publish_date"
    }
}

struct AquaOLWorkAuthorRef: Decodable {
    let author: AquaOLAuthorKey?
}

struct AquaOLAuthorKey: Decodable {
    let key: String?
}

enum AquaOLDescription: Decodable {
    case text(String)
    case object(String)

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let s = try? c.decode(String.self) { self = .text(s); return }
        struct V: Decodable { let value: String? }
        if let o = try? c.decode(V.self), let v = o.value { self = .object(v); return }
        throw DecodingError.dataCorruptedError(in: c, debugDescription: "description")
    }

    var plainText: String? {
        switch self { case .text(let s): s; case .object(let v): v }
    }
}

struct AquaOLSubjectResponse: Decodable {
    let name: String?
    let works: [AquaOLSubjectWork]?
}

struct AquaOLSubjectWork: Decodable {
    let key: String?
    let title: String?
    let authors: [AquaOLSubjectAuthor]?
    let coverId: Int?
    let firstPublishYear: Int?

    enum CodingKeys: String, CodingKey {
        case key, title, authors
        case coverId = "cover_id"
        case firstPublishYear = "first_publish_year"
    }
}

struct AquaOLSubjectAuthor: Decodable {
    let name: String?
    let key: String?
}
