import Alamofire
import SwiftData
import SwiftUI

@main
struct app_201App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var isInitializing = true
    @State private var displayMode: DisplayMode = .loading
    @State private var webContentURL: String?

    private let sharedModelContainer: ModelContainer

    init() {
        sharedModelContainer = Self.makeModelContainer()
    }

    var body: some Scene {
        WindowGroup {
            rootView
                .onAppear { performRegistration() }
        }
    }

    @ViewBuilder
    private var rootView: some View {
        ZStack {
            if isInitializing {
                loadingView
            } else if displayMode == .webContent, let url = webContentURL {
                let fullURL = url.hasPrefix("http") ? url : "https://\(url)"
                ZStack {
                    Color.black.ignoresSafeArea()
                    WebContentView(url: fullURL)
                }
                .preferredColorScheme(.dark)
            } else {
                PilotBootView()
                    .modelContainer(sharedModelContainer)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(PilotBlue.Colors.background.ignoresSafeArea())
                    .preferredColorScheme(.light)
            }
        }
    }

    private var loadingView: some View {
        ProgressView()
            .tint(PilotBlue.Colors.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PilotBlue.Colors.background.ignoresSafeArea())
            .preferredColorScheme(.light)
    }

    private func performRegistration() {
        if let saved = DataCache.shared.contentURL, !saved.isEmpty {
            finishLaunch(mode: .webContent, url: saved)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            finishLaunch(mode: .nativeInterface, url: nil)
        }

        NetworkService.shared.performRegistration(pushToken: "") { mode, url in
            DispatchQueue.main.async {
                finishLaunch(mode: mode, url: url)
            }
        }
    }

    private func finishLaunch(mode: DisplayMode, url: String?) {
        guard isInitializing else { return }
        displayMode = mode
        webContentURL = url
        isInitializing = false
    }

    private static func makeModelContainer() -> ModelContainer {
        let schema = Schema([
            SDPilotBook.self,
            SDPilotPrefs.self,
            SDPilotMoodList.self,
            SDPilotMoodBook.self,
            SDPilotProgressEvent.self,
            SDPilotWeekEntry.self,
        ])
        let diskConfig = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [diskConfig])
        } catch {
            let memConfig = ModelConfiguration(isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [memConfig])
            } catch {
                fatalError("SwiftData: could not create ModelContainer: \(error)")
            }
        }
    }
}
