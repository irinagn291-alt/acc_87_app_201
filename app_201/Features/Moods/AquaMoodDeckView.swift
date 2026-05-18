import SwiftUI

struct AquaMoodDeckView: View {
    @EnvironmentObject private var deps: AquaDependencies
    @State private var selected: AquaMoodDefinition = AquaGenreCatalog.allMoods[0]
    @State private var picksByMood: [String: [AquaSearchHit]] = [:]
    @State private var saved: [AquaMoodListRow] = []
    @State private var path = NavigationPath()
    @State private var showAddSheet = false
    @State private var showSaveAlert = false
    @State private var listTitle = ""

    private var workingPicks: [AquaSearchHit] { picksByMood[selected.moodKey] ?? [] }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("Mood") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(AquaGenreCatalog.allMoods) { m in
                                PilotChip(title: m.displayTitle, isSelected: m.id == selected.id) {
                                    selected = m
                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }

                Section("Your picks") {
                    if workingPicks.isEmpty {
                        PilotEmptyState(
                            title: "Build your list",
                            message: "Choose a mood, tap Add book, and curate titles from Open Library. Saved locally.",
                            systemImage: "heart.text.square"
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                    } else {
                        ForEach(workingPicks) { h in
                            NavigationLink(value: AquaBookRoute.hit(h)) {
                                AquaBookCard(
                                    title: h.title,
                                    authorsLine: h.authors.joined(separator: ", "),
                                    coverURL: AquaBookFactory.coverURLString(coverId: h.coverId).flatMap(URL.init(string:)),
                                    compact: true
                                )
                            }
                            .buttonStyle(PilotScalePress())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        .onDelete(perform: removePicks)
                    }
                }

                Section {
                    Button {
                        showAddSheet = true
                    } label: {
                        Label("Add book", systemImage: "plus.circle.fill")
                            .font(.system(size: 16, weight: .heavy))
                    }
                    Button("Save this list") {
                        listTitle = "\(selected.displayTitle) — \(Date.now.formatted(date: .abbreviated, time: .omitted))"
                        showSaveAlert = true
                    }
                    .disabled(workingPicks.isEmpty)
                }

                if !saved.isEmpty {
                    Section("Saved collections") {
                        ForEach(saved) { row in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(row.title).font(.headline).foregroundStyle(PilotBlue.Colors.text)
                                Text("\(row.books.count) books · \(row.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption)
                                    .foregroundStyle(PilotBlue.Colors.textMuted)
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    try? deps.moodLists.deleteList(id: row.id)
                                    Task { await loadSaved() }
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(PilotBlue.Colors.background)
            .navigationTitle("Mood collections")
            .navigationDestination(for: AquaBookRoute.self) { AquaBookDetailView(route: $0) }
            .task { await loadSaved() }
            .sheet(isPresented: $showAddSheet) {
                NavigationStack {
                    PilotSearchDeck(pickHitHandler: { hit in
                        appendPick(hit)
                        showAddSheet = false
                    })
                    .environmentObject(deps)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showAddSheet = false }
                        }
                    }
                }
            }
            .alert("Save collection", isPresented: $showSaveAlert) {
                TextField("Title", text: $listTitle)
                Button("Save") { saveList() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Saved locally on this device.")
            }
        }
    }

    private func appendPick(_ hit: AquaSearchHit) {
        var next = picksByMood
        var arr = next[selected.moodKey] ?? []
        if !arr.contains(where: { $0.openLibraryId == hit.openLibraryId }) {
            arr.append(hit); next[selected.moodKey] = arr; picksByMood = next
        }
    }

    private func removePicks(at offsets: IndexSet) {
        var arr = picksByMood[selected.moodKey] ?? []
        for i in offsets.sorted(by: >) { if i < arr.count { arr.remove(at: i) } }
        var next = picksByMood; next[selected.moodKey] = arr; picksByMood = next
    }

    private func loadSaved() async {
        do { saved = try deps.moodLists.allLists() } catch { saved = [] }
    }

    private func saveList() {
        guard !workingPicks.isEmpty else { return }
        do {
            try deps.moodLists.saveList(title: listTitle, moodKey: selected.moodKey, books: workingPicks)
            Task { await loadSaved() }
        } catch {}
    }
}
