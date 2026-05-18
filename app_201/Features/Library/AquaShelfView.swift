import SwiftUI

struct AquaShelfView: View {
    @EnvironmentObject private var deps: AquaDependencies
    @State private var books: [AquaBookEntry] = []
    @State private var filter: AquaReadStatus? = nil
    @State private var query: String = ""
    @State private var prefs: AquaPrefsSnapshot?
    @State private var path = NavigationPath()

    private var filtered: [AquaBookEntry] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return books.filter { b in
            let statusOK = filter == nil || b.status == filter
            let textOK = q.isEmpty || b.title.lowercased().contains(q) || b.authors.joined(separator: " ").lowercased().contains(q)
            return statusOK && textOK
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    HStack(spacing: PilotBlue.Space.md) {
                        Image(systemName: "magnifyingglass").foregroundStyle(PilotBlue.Colors.textMuted)
                        TextField("Search your shelf", text: $query)
                            .foregroundStyle(PilotBlue.Colors.text)
                    }
                    .padding(.horizontal, PilotBlue.Space.md)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: PilotBlue.Radius.lg, style: .continuous)
                            .fill(PilotBlue.Colors.surface)
                            .overlay(RoundedRectangle(cornerRadius: PilotBlue.Radius.lg, style: .continuous).stroke(PilotBlue.Colors.border, lineWidth: 1))
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: PilotBlue.Space.sm) {
                            chip("All", filter == nil) { filter = nil }
                            ForEach(AquaReadStatus.allCases, id: \.self) { s in
                                chip(s.label, filter == s) { filter = s }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 10, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                if filtered.isEmpty {
                    Section {
                        PilotEmptyState(
                            title: "Your shelf is empty",
                            message: "Add books from Explore or Search to get started.",
                            systemImage: "books.vertical"
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                    }
                } else {
                    Section {
                        ForEach(filtered) { b in
                            NavigationLink(value: AquaBookRoute.library(b.id)) {
                                AquaBookCard(
                                    title: b.title,
                                    authorsLine: b.authors.joined(separator: ", "),
                                    coverURL: b.coverURL.flatMap(URL.init(string:)),
                                    rating: b.rating,
                                    status: b.status,
                                    year: b.firstPublishYear,
                                    compact: prefs?.shelfLayout == .compact
                                )
                            }
                            .buttonStyle(PilotScalePress())
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(PilotBlue.Colors.background)
            .contentMargins(.bottom, 88, for: .scrollContent)
            .navigationTitle("Library")
            .navigationDestination(for: AquaBookRoute.self) { AquaBookDetailView(route: $0) }
            .toolbar {
                Menu("Sort") {
                    Button("Recently updated") { books.sort { $0.lastUpdated > $1.lastUpdated } }
                    Button("Title A–Z") { books.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending } }
                    Button("Date added") { books.sort { $0.dateAdded > $1.dateAdded } }
                }
            }
            .onAppear { Task { await refresh() } }
            .onReceive(NotificationCenter.default.publisher(for: .aquaPilotPreferencesChanged)) { _ in Task { await refresh() } }
            .refreshable { await refresh() }
        }
    }

    private func chip(_ title: String, _ sel: Bool, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.heavy))
                .foregroundStyle(sel ? Color.white : PilotBlue.Colors.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(sel ? PilotBlue.Colors.primary : PilotBlue.Colors.surface)
                        .overlay(Capsule().stroke(PilotBlue.Colors.border, lineWidth: 1))
                )
        }
        .buttonStyle(.plain)
    }

    private func refresh() async {
        do {
            prefs = try deps.prefs.load()
            books = try deps.books.allBooks()
        } catch { books = [] }
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets { try? deps.books.delete(id: filtered[i].id) }
        Task { await refresh() }
    }
}
