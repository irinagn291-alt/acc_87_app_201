import SwiftData
import SwiftUI

struct PilotBootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var deps: AquaDependencies?

    var body: some View {
        Group {
            if let deps {
                PilotShell()
                    .environmentObject(deps)
            } else {
                ProgressView()
                    .tint(PilotBlue.Colors.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(PilotBlue.Colors.background)
                    .task(priority: .userInitiated) {
                        await Task.yield()
                        guard deps == nil else { return }
                        deps = AquaDependencies(modelContext: modelContext)
                    }
            }
        }
    }
}

struct PilotShell: View {
    @EnvironmentObject private var deps: AquaDependencies
    @State private var prefs: AquaPrefsSnapshot?

    var body: some View {
        Group {
            if let prefs {
                if prefs.hasCompletedOnboarding {
                    AquaRouteTabs()
                } else {
                    CalmLaunchCarousel(initial: prefs) { updated in
                        self.prefs = updated
                    }
                }
            } else {
                ProgressView()
                    .tint(PilotBlue.Colors.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(PilotBlue.Colors.background)
                    .task(priority: .userInitiated) {
                        await Task.yield()
                        guard prefs == nil else { return }
                        loadPrefs()
                    }
            }
        }
        .preferredColorScheme(.light)
        .onReceive(NotificationCenter.default.publisher(for: .aquaPilotPreferencesChanged)) { _ in
            loadPrefs()
        }
    }

    private func loadPrefs() {
        do {
            prefs = try deps.prefs.load()
        } catch {
            prefs = AquaPrefsSnapshot(
                hasCompletedOnboarding: false,
                selectedGenres: [],
                preferredTheme: .system,
                shelfLayout: .largeCards,
                readingGoals: []
            )
        }
    }
}
