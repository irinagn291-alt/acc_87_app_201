import SwiftUI

struct AquaDiscoveryHome: View {
    @EnvironmentObject private var deps: AquaDependencies
    @State private var prefs: AquaPrefsSnapshot?
    @State private var reading: [AquaBookEntry] = []
    @State private var shelf: [AquaBookEntry] = []
    @State private var sections: [(title: String, slug: String, books: [AquaSubjectBook])] = []
    @State private var loadError: String?

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    var body: some View {
        List {
            Section {
                headerContent
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: PilotBlue.Space.xl, bottom: 4, trailing: PilotBlue.Space.xl))

            Section {
                NavigationLink {
                    PilotSearchDeck()
                } label: {
                    AquaSearchBarLabel(placeholder: "Search books, authors, ISBN…")
                }
                .buttonStyle(.plain)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: PilotBlue.Space.xl, bottom: 8, trailing: PilotBlue.Space.xl))

            if let top = reading.first {
                Section {
                    NavigationLink(value: AquaBookRoute.library(top.id)) {
                        AquaContinueCard(
                            title: top.title,
                            author: top.authors.joined(separator: ", ").nilIfEmpty,
                            coverURL: top.coverURL.flatMap(URL.init(string:)),
                            progress: progressRatio(top)
                        )
                    }
                    .buttonStyle(PilotScalePress())
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: PilotBlue.Space.xl, bottom: 8, trailing: PilotBlue.Space.xl))
            }

            Section {
                genresStrip
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: PilotBlue.Space.xl, bottom: 8, trailing: PilotBlue.Space.xl))

            if !shelf.isEmpty {
                Section {
                    VStack(alignment: .leading, spacing: PilotBlue.Space.md) {
                        Text("My shelf")
                            .font(.system(size: 19, weight: .heavy))
                            .foregroundStyle(PilotBlue.Colors.text)
                        PilotShelfStrip(books: shelf.prefix(12).map {
                            (id: $0.id.uuidString, title: $0.title, coverURL: $0.coverURL.flatMap(URL.init(string:)))
                        })
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: PilotBlue.Space.xl, bottom: 8, trailing: PilotBlue.Space.xl))
            }

            Section {
                NavigationLink {
                    AquaMoodDeckView()
                } label: {
                    HStack {
                        Text("Mood collections")
                            .font(.system(size: 19, weight: .heavy))
                            .foregroundStyle(PilotBlue.Colors.text)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(PilotBlue.Colors.textMuted)
                    }
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: PilotBlue.Space.xl, bottom: 8, trailing: PilotBlue.Space.xl))

            Section {
                NavigationLink {
                    WeekFlightPlanView()
                } label: {
                    HStack {
                        Text("Week flight plan")
                            .font(.system(size: 19, weight: .heavy))
                            .foregroundStyle(PilotBlue.Colors.text)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(PilotBlue.Colors.textMuted)
                    }
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: PilotBlue.Space.xl, bottom: 8, trailing: PilotBlue.Space.xl))

            if let loadError {
                Section {
                    PilotEmptyState(
                        title: "Could not refresh",
                        message: loadError,
                        systemImage: "wifi.exclamationmark",
                        actionTitle: "Retry",
                        action: { Task { await load() } }
                    )
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: PilotBlue.Space.xl, bottom: 8, trailing: PilotBlue.Space.xl))
            }

            ForEach(sections, id: \.slug) { sec in
                Section {
                    VStack(alignment: .leading, spacing: PilotBlue.Space.md) {
                        Text(sec.title)
                            .font(.system(size: 19, weight: .heavy))
                            .foregroundStyle(PilotBlue.Colors.text)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: PilotBlue.Space.md) {
                                ForEach(sec.books) { book in
                                    NavigationLink(value: AquaBookRoute.work(workKey: book.key, fallbackAuthors: book.authors)) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            PilotCoverView(
                                                url: AquaBookFactory.coverURLString(coverId: book.coverId).flatMap(URL.init(string:)),
                                                title: book.title,
                                                author: book.authors.first,
                                                size: .medium
                                            )
                                            Text(book.title)
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(PilotBlue.Colors.text)
                                                .lineLimit(2)
                                                .frame(width: 104, alignment: .leading)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: PilotBlue.Space.xl, bottom: 16, trailing: PilotBlue.Space.xl))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(PilotBlue.Colors.background)
        .environment(\.defaultMinListRowHeight, 1)
        .navigationTitle(AquaStrings.appName)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: AquaBookRoute.self) { AquaBookDetailView(route: $0) }
        .navigationDestination(for: AquaGenreRoute.self) { route in
            switch route {
            case .subject(let slug, let title): AquaSubjectBrowse(slug: slug, title: title)
            }
        }
        .refreshable { await load() }
        .task { await load() }
    }

    private var headerContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(AquaStrings.appName)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(PilotBlue.Colors.primary)
                .tracking(0.6)
            Text("\(greeting),")
                .font(.system(size: 30, weight: .black))
                .foregroundStyle(PilotBlue.Colors.text)
            Text("What are you reading today?")
                .font(.system(size: 30, weight: .black))
                .foregroundStyle(PilotBlue.Colors.text)
            Text("Manage your reading from one calm space.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(PilotBlue.Colors.textMuted)
                .lineSpacing(3)
                .padding(.top, 3)
        }
        .padding(.top, PilotBlue.Space.md)
    }

    private var genresStrip: some View {
        VStack(alignment: .leading, spacing: PilotBlue.Space.md) {
            Text("Genres")
                .font(.system(size: 19, weight: .heavy))
                .foregroundStyle(PilotBlue.Colors.text)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PilotBlue.Space.sm) {
                    ForEach(AquaGenreCatalog.popularSubjects, id: \.slug) { item in
                        NavigationLink(value: AquaGenreRoute.subject(slug: item.slug, title: item.title)) {
                            Text(item.title)
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(PilotBlue.Colors.text)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(
                                    Capsule()
                                        .fill(PilotBlue.Colors.surface)
                                        .overlay(Capsule().stroke(PilotBlue.Colors.border, lineWidth: 1))
                                )
                                .contentShape(Capsule())
                        }
                        .buttonStyle(PilotScalePress())
                    }
                }
            }
            .scrollClipDisabled()
        }
    }

    private func progressRatio(_ book: AquaBookEntry) -> Double {
        guard let t = book.totalPages, t > 0 else { return 0 }
        return AquaPageCalc.progressRatio(current: book.currentPage, total: t) ?? 0
    }

    private func load() async {
        loadError = nil
        do {
            prefs = try deps.prefs.load()
            let all = try deps.books.allBooks()
            reading = all.filter { $0.status == .reading }.sorted { $0.lastUpdated > $1.lastUpdated }
            shelf = all.sorted { $0.dateAdded > $1.dateAdded }

            let slugs: [String] = {
                let g = prefs?.selectedGenres ?? []
                if g.isEmpty { return AquaGenreCatalog.popularSubjects.map(\.slug) }
                return Array(g.prefix(5))
            }()

            var built: [(title: String, slug: String, books: [AquaSubjectBook])] = []
            if deps.connectivity.isOnline {
                for slug in slugs {
                    let title = AquaGenreCatalog.popularSubjects.first(where: { $0.slug == slug })?.title
                        ?? AquaGenreCatalog.onboardingGenres.first(where: { $0.slug == slug })?.title
                        ?? slug
                    do {
                        let books = try await deps.searchRepo.subjectBooks(slug: slug, limit: 16, offset: 0)
                        if !books.isEmpty { built.append((title: title, slug: slug, books: books)) }
                    } catch { continue }
                }
            } else {
                loadError = "You're offline — recommendations unavailable."
            }
            sections = built
        } catch {
            loadError = "Could not load your library."
        }
    }
}

private enum AquaGenreRoute: Hashable {
    case subject(slug: String, title: String)
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
