import SwiftData
import SwiftUI

@main
struct app_201App: App {
    private let sharedModelContainer: ModelContainer

    init() {
        sharedModelContainer = Self.makeModelContainer()
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

    var body: some Scene {
        WindowGroup {
            PilotBootView()
                .modelContainer(sharedModelContainer)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(PilotBlue.Colors.background.ignoresSafeArea())
                .preferredColorScheme(.light)
        }
    }
}
