import SwiftUI

struct AquaPilotSettings: View {
    @EnvironmentObject private var deps: AquaDependencies
    @State private var prefs = AquaPrefsSnapshot(
        hasCompletedOnboarding: true,
        selectedGenres: [],
        preferredTheme: .system,
        shelfLayout: .largeCards,
        readingGoals: []
    )
    @State private var showClearConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: PilotBlue.Space.md) {
                sectionHeader("Library")

                Menu {
                    Picker("Layout", selection: Binding(
                        get: { prefs.shelfLayout },
                        set: { v in update { $0.shelfLayout = v } }
                    )) {
                        ForEach(AquaShelfLayout.allCases, id: \.self) { m in
                            Text(m.label).tag(m)
                        }
                    }
                } label: {
                    PilotLinkRow(icon: "rectangle.grid.2x2", title: "Shelf layout", subtitle: prefs.shelfLayout.label)
                }

                PilotSettingsRow(icon: "trash", title: "Clear library", subtitle: "Remove all saved books", danger: true) {
                    showClearConfirm = true
                }

                sectionHeader("About")

                Link(destination: URL(string: "https://openlibrary.org")!) {
                    PilotLinkRow(icon: "link", title: "Open Library", subtitle: "openlibrary.org")
                }

                Link(destination: URL(string: "https://openlibrary.org/privacy")!) {
                    PilotLinkRow(icon: "hand.raised", title: "Privacy policy")
                }

                Link(destination: URL(string: "https://openlibrary.org/developers/licensing")!) {
                    PilotLinkRow(icon: "doc.text", title: "Data licensing")
                }

                sectionHeader("Version")
                Text("\(AquaStrings.appName) 1.0")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(PilotBlue.Colors.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, PilotBlue.Space.xl)
            .padding(.bottom, 40)
        }
        .background(PilotBlue.Colors.background.ignoresSafeArea())
        .navigationTitle("Settings")
        .task { await load() }
        .alert("Delete all books?", isPresented: $showClearConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { try? deps.books.clearAll() }
        } message: {
            Text("This cannot be undone.")
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .heavy))
            .foregroundStyle(PilotBlue.Colors.textMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, PilotBlue.Space.sm)
    }

    private func load() async {
        do { prefs = try deps.prefs.load() } catch {}
    }

    private func update(_ change: (inout AquaPrefsSnapshot) -> Void) {
        change(&prefs)
        do {
            try deps.prefs.save(prefs)
            NotificationCenter.default.post(name: .aquaPilotPreferencesChanged, object: nil)
        } catch {}
    }
}
