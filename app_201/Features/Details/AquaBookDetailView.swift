import SwiftUI

enum AquaBookRoute: Hashable {
    case hit(AquaSearchHit)
    case work(workKey: String, fallbackAuthors: [String])
    case library(UUID)
}

struct AquaBookDetailView: View {
    @EnvironmentObject private var deps: AquaDependencies
    let route: AquaBookRoute

    @State private var state: AquaViewState<AquaWorkDetail> = .idle
    @State private var book: AquaBookEntry?
    @State private var showAddSheet = false
    @State private var pendingStatus: AquaReadStatus = .wantToRead

    private var canAdd: Bool {
        switch route { case .hit, .work: true; case .library: false }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: PilotBlue.Space.lg) {
                headerSection
                contentSection
            }
            .padding(.horizontal, PilotBlue.Space.xl)
            .padding(.bottom, 48)
        }
        .background(PilotBlue.Colors.background.ignoresSafeArea())
        .navigationTitle("Book")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if canAdd {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add to library") { showAddSheet = true }
                        .fontWeight(.heavy)
                        .foregroundStyle(PilotBlue.Colors.primary)
                }
            }
        }
        .task { await load() }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                VStack(spacing: PilotBlue.Space.lg) {
                    Text("Add to \(AquaStrings.appName)")
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(PilotBlue.Colors.text)
                    PilotStatusPicker(status: $pendingStatus)
                    Button("Save") { addToLibrary() }
                        .buttonStyle(PilotPrimaryButtonStyle())
                }
                .padding(PilotBlue.Space.xl)
                .background(PilotBlue.Colors.background.ignoresSafeArea())
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { showAddSheet = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    @ViewBuilder
    private var headerSection: some View {
        switch route {
        case .library:
            if let b = book { libraryHero(b) }
            else { ProgressView().tint(PilotBlue.Colors.secondary).frame(maxWidth: .infinity) }
        case .hit(let h):
            if case .success(let d) = state { remoteHero(d) }
            else { hitHero(h) }
        case .work(_, let authors):
            if case .success(let d) = state { remoteHero(d) }
            else {
                VStack(spacing: 10) {
                    ProgressView().tint(PilotBlue.Colors.secondary)
                    Text(authors.joined(separator: ", ")).font(.caption).foregroundStyle(PilotBlue.Colors.textMuted)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private var contentSection: some View {
        switch route {
        case .library: EmptyView()
        case .hit, .work:
            switch state {
            case .idle, .loading:
                ProgressView().tint(PilotBlue.Colors.secondary).padding().frame(maxWidth: .infinity)
            case .empty:
                PilotEmptyState(title: "No description", message: "Open Library returned incomplete data.", systemImage: "book.closed")
            case .failure(let msg):
                PilotEmptyState(
                    title: "Couldn't load",
                    message: msg,
                    systemImage: "wifi.exclamationmark",
                    actionTitle: "Retry",
                    action: { Task { await loadRemote() } }
                )
            case .success(let d):
                remoteSections(d)
            }
        }
    }

    private func hitHero(_ h: AquaSearchHit) -> some View {
        let u = AquaBookFactory.coverURLString(coverId: h.coverId).flatMap(URL.init(string:))
        return VStack(spacing: PilotBlue.Space.md) {
            PilotCoverView(url: u, title: h.title, author: h.authors.first, size: .custom(width: 140, height: 210))
            Text(h.title).font(.system(size: 22, weight: .black)).foregroundStyle(PilotBlue.Colors.text).multilineTextAlignment(.center)
            Text(h.authors.isEmpty ? AquaStrings.unknownAuthor : h.authors.joined(separator: ", "))
                .foregroundStyle(PilotBlue.Colors.textMuted)
            if let y = h.firstPublishYear { Text(String(y)).font(.caption.weight(.semibold)).foregroundStyle(PilotBlue.Colors.textMuted) }
        }
        .frame(maxWidth: .infinity)
        .padding(PilotBlue.Space.xl)
        .background(
            RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous)
                .fill(PilotBlue.Colors.surface)
                .overlay(RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous).stroke(PilotBlue.Colors.border, lineWidth: 1))
                .pilotCardShadow()
        )
    }

    private func remoteHero(_ d: AquaWorkDetail) -> some View {
        let u = AquaBookFactory.coverURLString(coverId: d.coverId).flatMap(URL.init(string:))
        return VStack(spacing: PilotBlue.Space.md) {
            PilotCoverView(url: u, title: d.title, author: d.authors.first, size: .custom(width: 140, height: 210))
            Text(d.title).font(.system(size: 22, weight: .black)).foregroundStyle(PilotBlue.Colors.text).multilineTextAlignment(.center)
            Text(d.authors.joined(separator: ", ")).foregroundStyle(PilotBlue.Colors.textMuted)
            if let y = d.firstPublishYear { Text(String(y)).font(.caption.weight(.semibold)).foregroundStyle(PilotBlue.Colors.textMuted) }
            if !d.subjects.isEmpty { PilotTagsStrip(tags: Array(d.subjects.prefix(8))) }
        }
        .frame(maxWidth: .infinity)
        .padding(PilotBlue.Space.xl)
        .background(
            RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous)
                .fill(PilotBlue.Colors.surface)
                .overlay(RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous).stroke(PilotBlue.Colors.border, lineWidth: 1))
                .pilotCardShadow()
        )
    }

    private func libraryHero(_ b: AquaBookEntry) -> some View {
        let u = b.coverURL.flatMap(URL.init(string:))
        return VStack(spacing: PilotBlue.Space.md) {
            PilotCoverView(url: u, title: b.title, author: b.authors.first, size: .custom(width: 140, height: 210))
            Text(b.title).font(.system(size: 26, weight: .black)).foregroundStyle(PilotBlue.Colors.text).multilineTextAlignment(.center)
            Text(b.authors.isEmpty ? AquaStrings.unknownAuthor : b.authors.joined(separator: ", "))
                .foregroundStyle(PilotBlue.Colors.textMuted)
            HStack(spacing: 8) {
                if let r = b.rating { PilotRatingBadge(rating: r) }
                PilotStatusBadge(status: b.status)
            }
            if !b.subjects.isEmpty { PilotTagsStrip(tags: Array(b.subjects.prefix(8))) }
            PilotStatusPicker(status: Binding(
                get: { book?.status ?? .wantToRead },
                set: { v in
                    guard var m = book else { return }
                    m.status = v
                    m.lastUpdated = .now
                    persist(m)
                }
            ))
            .padding(.top, 4)

            if let total = b.totalPages, total > 0 {
                AquaProgressBlock(book: b, totalPages: total)
            }

            VStack(alignment: .leading, spacing: PilotBlue.Space.md) {
                NavigationLink(destination: AquaNoteEditorView(bookID: b.id)) {
                    PilotLinkRow(
                        icon: "star.fill",
                        title: "Notes & rating",
                        subtitle: b.rating != nil ? String(format: "%.1f stars", b.rating!) : "No rating yet"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(destination: AquaProgressDeckView(bookID: b.id)) {
                    PilotLinkRow(
                        icon: "bookmark.fill",
                        title: "Reading progress",
                        subtitle: progressSub(b)
                    )
                }
                .buttonStyle(.plain)
            }

            bookPassport(b)

            if let note = b.noteText, !note.isEmpty {
                VStack(alignment: .leading, spacing: PilotBlue.Space.sm) {
                    Text("My note")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(PilotBlue.Colors.text)
                    Text("\u{201C}\(note)\u{201D}")
                        .font(.system(size: 15, weight: .semibold))
                        .italic()
                        .foregroundStyle(PilotBlue.Colors.text)
                        .lineSpacing(4)
                        .padding(PilotBlue.Space.lg)
                        .background(
                            RoundedRectangle(cornerRadius: PilotBlue.Radius.lg, style: .continuous)
                                .fill(PilotBlue.Colors.primarySoft)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(PilotBlue.Space.xl)
        .background(
            RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous)
                .fill(PilotBlue.Colors.surface)
                .overlay(RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous).stroke(PilotBlue.Colors.border, lineWidth: 1))
                .pilotCardShadow()
        )
    }

    private func remoteSections(_ d: AquaWorkDetail) -> some View {
        VStack(alignment: .leading, spacing: PilotBlue.Space.lg) {
            if let desc = d.description, !desc.isEmpty {
                VStack(alignment: .leading, spacing: PilotBlue.Space.md) {
                    Text("About")
                        .font(.system(size: 19, weight: .heavy))
                        .foregroundStyle(PilotBlue.Colors.text)
                    Text(desc)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(PilotBlue.Colors.text)
                        .lineSpacing(5)
                }
                .padding(PilotBlue.Space.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous)
                        .fill(PilotBlue.Colors.surface)
                        .overlay(RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous).stroke(PilotBlue.Colors.border, lineWidth: 1))
                )
            }
            passportGrid([
                ("Author", d.authors.joined(separator: ", ")),
                ("Year", d.firstPublishYear.map(String.init) ?? ""),
                ("Est. pages", d.numberOfPagesMedian.map(String.init) ?? ""),
            ])
        }
    }

    private func bookPassport(_ b: AquaBookEntry) -> some View {
        passportGrid([
            ("Author", b.authors.joined(separator: ", ")),
            ("Year", b.firstPublishYear.map(String.init) ?? ""),
            ("Pages", b.totalPages.map(String.init) ?? ""),
            ("Added", b.dateAdded.formatted(date: .abbreviated, time: .omitted)),
        ])
    }

    private func passportGrid(_ items: [(String, String)]) -> some View {
        let visible = items.filter { !$0.1.isEmpty }
        return VStack(alignment: .leading, spacing: 0) {
            Text("Details")
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(PilotBlue.Colors.text)
                .padding(.bottom, PilotBlue.Space.sm)
            ForEach(Array(visible.enumerated()), id: \.offset) { idx, row in
                HStack(alignment: .top, spacing: PilotBlue.Space.md) {
                    Text(row.0)
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(PilotBlue.Colors.textMuted)
                        .frame(width: 90, alignment: .leading)
                    Text(row.1)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(PilotBlue.Colors.text)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.vertical, 11)
                if idx < visible.count - 1 {
                    Divider().overlay(PilotBlue.Colors.border)
                }
            }
        }
        .padding(PilotBlue.Space.lg)
        .background(
            RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous)
                .fill(PilotBlue.Colors.surface)
                .overlay(RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous).stroke(PilotBlue.Colors.border, lineWidth: 1))
        )
    }

    private func progressSub(_ b: AquaBookEntry) -> String {
        guard let t = b.totalPages, t > 0 else { return "Tap to add pages" }
        let p = AquaPageCalc.progressRatio(current: b.currentPage, total: t) ?? 0
        return "Page \(b.currentPage) of \(t) · \(Int(p * 100))%"
    }

    private func load() async {
        switch route {
        case .library(let id):
            do { book = try deps.books.book(id: id) } catch { book = nil }
            await loadRemoteForLibrary()
        case .hit(let h): await loadRemote(hit: h)
        case .work(let wk, let authors): await loadRemote(workKey: wk, authors: authors)
        }
    }

    private func loadRemote() async {
        switch route {
        case .hit(let h): await loadRemote(hit: h)
        case .work(let wk, let authors): await loadRemote(workKey: wk, authors: authors)
        case .library: break
        }
    }

    private func loadRemote(hit: AquaSearchHit) async {
        guard let wk = hit.workKey else { state = .empty; return }
        state = .loading
        do {
            if !deps.connectivity.isOnline { state = .failure("You're offline"); return }
            state = .success(try await deps.searchRepo.workDetail(workKey: wk, fallbackAuthors: hit.authors))
        } catch {
            if let msg = AquaStrings.userFacingError(error) { state = .failure(msg) } else { state = .idle }
        }
    }

    private func loadRemote(workKey: String, authors: [String]) async {
        state = .loading
        do {
            if !deps.connectivity.isOnline { state = .failure("You're offline"); return }
            state = .success(try await deps.searchRepo.workDetail(workKey: workKey, fallbackAuthors: authors))
        } catch {
            if let msg = AquaStrings.userFacingError(error) { state = .failure(msg) } else { state = .idle }
        }
    }

    private func loadRemoteForLibrary() async {
        guard let b = book, let wk = b.workKey, deps.connectivity.isOnline else { return }
        do {
            let d = try await deps.searchRepo.workDetail(workKey: wk, fallbackAuthors: b.authors)
            let merged = AquaBookFactory.mergedWithDetail(book: b, detail: d)
            try deps.books.upsert(merged)
            book = merged
        } catch {}
    }

    private func addToLibrary() {
        do {
            switch route {
            case .hit(let h): try deps.books.upsert(AquaBookFactory.fromSearchHit(h, status: pendingStatus))
            case .work:
                if case .success(let d) = state { try deps.books.upsert(AquaBookFactory.fromWorkDetail(d, status: pendingStatus)) }
            case .library: break
            }
            showAddSheet = false
        } catch { showAddSheet = false }
    }

    private func persist(_ b: AquaBookEntry) {
        do { try deps.books.upsert(b); book = b } catch {}
    }
}

private struct AquaProgressBlock: View {
    let book: AquaBookEntry
    let totalPages: Int

    private var progress: Double {
        AquaPageCalc.progressRatio(current: book.currentPage, total: totalPages) ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: PilotBlue.Space.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Progress").font(.system(size: 16, weight: .heavy)).foregroundStyle(Color.white)
                    Text("Page \(book.currentPage) of \(totalPages)").font(.system(size: 12, weight: .medium)).foregroundStyle(Color.white.opacity(0.72))
                }
                Spacer()
                Text("\(Int(progress * 100))%").font(.system(size: 24, weight: .heavy)).foregroundStyle(PilotBlue.Colors.secondary)
            }
            PilotProgressBar(value: progress)
            NavigationLink("Update progress", destination: AquaProgressDeckView(bookID: book.id))
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(PilotBlue.Colors.secondary)
        }
        .padding(PilotBlue.Space.lg)
        .background(
            LinearGradient(
                colors: [PilotBlue.Colors.primary, PilotBlue.Colors.accent],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: PilotBlue.Radius.lg, style: .continuous))
    }
}
