import Alamofire
import SwiftUI

struct AquaPilotSettings: View {
    private static let contactUsURL = "https://sli-ceboo-ker.pro/contact-us"

    @EnvironmentObject private var deps: AquaDependencies
    @State private var prefs = AquaPrefsSnapshot(
        hasCompletedOnboarding: true,
        selectedGenres: [],
        preferredTheme: .system,
        shelfLayout: .largeCards,
        readingGoals: []
    )
    @State private var showClearConfirm = false
    @State private var showContactUs = false

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

                PilotSettingsRow(icon: "envelope", title: "Contact us") {
                    showContactUs = true
                }

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
        .sheet(isPresented: $showContactUs) {
            PilotContactUsSheet(url: Self.contactUsURL) {
                showContactUs = false
            }
        }
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

private struct PilotContactUsSheet: View {
    let url: String
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                WebContentView(url: url)
            }
            .preferredColorScheme(.dark)
            .navigationTitle("Contact us")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onClose)
                }
            }
        }
    }
}
