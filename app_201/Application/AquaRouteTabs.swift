import SwiftUI

struct AquaRouteTabs: View {
    @EnvironmentObject private var deps: AquaDependencies

    var body: some View {
        TabView {
            NavigationStack { AquaDiscoveryHome() }
                .tabItem { Label("Explore", systemImage: "water.waves") }

            NavigationStack { PilotSearchDeck() }
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            NavigationStack { AquaShelfView() }
                .tabItem { Label("Library", systemImage: "books.vertical.fill") }

            NavigationStack { AquaInsightsView() }
                .tabItem { Label("Insights", systemImage: "chart.bar.xaxis") }

            NavigationStack { AquaPilotSettings() }
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(PilotBlue.Colors.primary)
    }
}
