import Combine
import Foundation
import SwiftData

@MainActor
final class AquaDependencies: ObservableObject {
    let prefs: AquaPrefsRepository
    let books: AquaBookRepository
    let moodLists: AquaMoodListRepository
    let progress: AquaProgressRepository
    let searchRepo: AquaSearchRepository
    let connectivity: AquaConnectivity
    let weekStore: AquaWeekStore

    init(modelContext: ModelContext) {
        let client = AquaURLSessionOLClient()
        self.prefs = AquaPrefsStore(context: modelContext)
        self.books = AquaBookStore(context: modelContext)
        self.moodLists = AquaMoodStore(context: modelContext)
        self.progress = AquaProgressStore(context: modelContext)
        self.searchRepo = AquaOLRepositoryImpl(client: client)
        self.connectivity = AquaConnectivity()
        self.weekStore = AquaWeekStore(context: modelContext)
        Task { @MainActor in
            self.connectivity.start()
            let mem = 50 * 1024 * 1024
            let disk = 200 * 1024 * 1024
            URLCache.shared = URLCache(memoryCapacity: mem, diskCapacity: disk)
        }
    }
}
