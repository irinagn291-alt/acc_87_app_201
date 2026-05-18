import Foundation
import SwiftData

@MainActor
final class AquaPrefsStore: AquaPrefsRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func load() throws -> AquaPrefsSnapshot {
        let fd = FetchDescriptor<SDPilotPrefs>()
        if let e = try context.fetch(fd).first { return map(e) }
        let fresh = SDPilotPrefs()
        context.insert(fresh)
        try context.save()
        return map(fresh)
    }

    func save(_ snapshot: AquaPrefsSnapshot) throws {
        let fd = FetchDescriptor<SDPilotPrefs>()
        let e = try context.fetch(fd).first ?? {
            let n = SDPilotPrefs(); context.insert(n); return n
        }()
        e.hasCompletedOnboarding = snapshot.hasCompletedOnboarding
        e.selectedGenresJSON = AquaDataMapper.encodeStrings(snapshot.selectedGenres)
        e.themeRaw = snapshot.preferredTheme.rawValue
        e.shelfLayoutRaw = snapshot.shelfLayout.rawValue
        e.readingGoalsJSON = AquaDataMapper.encodeStrings(snapshot.readingGoals)
        try context.save()
    }

    private func map(_ e: SDPilotPrefs) -> AquaPrefsSnapshot {
        AquaPrefsSnapshot(
            hasCompletedOnboarding: e.hasCompletedOnboarding,
            selectedGenres: AquaDataMapper.decodeStrings(e.selectedGenresJSON),
            preferredTheme: AquaDisplayTheme(rawValue: e.themeRaw) ?? .system,
            shelfLayout: AquaShelfLayout(rawValue: e.shelfLayoutRaw) ?? .largeCards,
            readingGoals: AquaDataMapper.decodeStrings(e.readingGoalsJSON)
        )
    }
}
