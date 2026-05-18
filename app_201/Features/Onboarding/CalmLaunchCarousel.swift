import SwiftUI

struct CalmLaunchCarousel: View {
    @EnvironmentObject private var deps: AquaDependencies
    let initial: AquaPrefsSnapshot
    let onFinished: (AquaPrefsSnapshot) -> Void

    @State private var step: Int = 0
    @State private var selectedGenres: Set<String> = []
    @State private var selectedGoals: Set<String> = []

    private let goals = [
        ("more", "Read more consistently"),
        ("track", "Track reading progress"),
        ("shelf", "Build a personal library"),
        ("discover", "Discover books by mood"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $step) {
                welcomePage.tag(0)
                featuresPage.tag(1)
                genresPage.tag(2)
                goalsPage.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(PilotMotion.anim(.easeInOut), value: step)

            HStack(spacing: PilotBlue.Space.md) {
                if step > 0 {
                    Button("Back") { step -= 1 }
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(PilotBlue.Colors.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 13)
                        .background(
                            Capsule()
                                .fill(PilotBlue.Colors.surface)
                                .overlay(Capsule().stroke(PilotBlue.Colors.border, lineWidth: 1))
                        )
                        .buttonStyle(PilotScalePress())
                }
                Spacer(minLength: 0)
                if step < 3 {
                    Button("Next") { step += 1 }
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 26)
                        .padding(.vertical, 13)
                        .background(Capsule().fill(PilotBlue.Colors.primary))
                        .buttonStyle(PilotScalePress())
                } else {
                    Button("Start navigating") { finish() }
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 13)
                        .background(Capsule().fill(PilotBlue.Colors.primary))
                        .buttonStyle(PilotScalePress())
                }
            }
            .padding(.horizontal, PilotBlue.Space.xl)
            .padding(.vertical, PilotBlue.Space.lg)
            .padding(.bottom, 8)
        }
        .background(PilotBlue.Colors.background.ignoresSafeArea())
    }

    private var welcomePage: some View {
        VStack(spacing: PilotBlue.Space.lg) {
            Spacer()
            ZStack {
                Circle()
                    .fill(PilotBlue.Colors.primarySoft)
                    .frame(width: 120, height: 120)
                Image(systemName: "water.waves")
                    .font(.system(size: 52))
                    .foregroundStyle(PilotBlue.Colors.primary)
            }
            Text(AquaStrings.appName)
                .font(.system(size: 38, weight: .black))
                .foregroundStyle(PilotBlue.Colors.primary)
            Text("Manage your reading from\none calm space.")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(PilotBlue.Colors.textMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            Spacer()
        }
        .padding(.horizontal, PilotBlue.Space.xxl)
    }

    private var featuresPage: some View {
        VStack(alignment: .leading, spacing: PilotBlue.Space.md) {
            Text("What's inside")
                .font(.title2.weight(.heavy))
                .foregroundStyle(PilotBlue.Colors.text)
                .padding(.horizontal, PilotBlue.Space.xl)
                .padding(.top, PilotBlue.Space.xl)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    featureRow("Search millions of titles", "magnifyingglass")
                    featureRow("Track pages & progress", "bookmark.fill")
                    featureRow("Scan ISBN barcodes", "barcode.viewfinder")
                    featureRow("Ratings & personal notes", "star.fill")
                    featureRow("Mood-based discovery", "face.smiling")
                    featureRow("Weekly reading plan", "calendar")
                    featureRow("Reading insights & stats", "chart.bar.xaxis")
                }
                .padding(.horizontal, PilotBlue.Space.xl)
            }
        }
    }

    private func featureRow(_ text: String, _ symbol: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .frame(width: 26)
                .foregroundStyle(PilotBlue.Colors.primary)
            Text(text)
                .font(.headline)
                .foregroundStyle(PilotBlue.Colors.text)
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(PilotBlue.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(PilotBlue.Colors.border, lineWidth: 1)
                )
                .pilotSoftShadow()
        )
    }

    private var genresPage: some View {
        VStack(alignment: .leading, spacing: PilotBlue.Space.md) {
            Text("Favorite genres")
                .font(.title2.weight(.heavy))
                .foregroundStyle(PilotBlue.Colors.text)
                .padding(.horizontal, PilotBlue.Space.xl)
                .padding(.top, PilotBlue.Space.xl)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 10)], spacing: 10) {
                    ForEach(AquaGenreCatalog.onboardingGenres, id: \.slug) { g in
                        PilotChip(title: g.title, isSelected: selectedGenres.contains(g.slug)) {
                            if selectedGenres.contains(g.slug) { selectedGenres.remove(g.slug) }
                            else { selectedGenres.insert(g.slug) }
                        }
                    }
                }
                .padding(.horizontal, PilotBlue.Space.xl)
            }
        }
    }

    private var goalsPage: some View {
        VStack(alignment: .leading, spacing: PilotBlue.Space.md) {
            Text("What matters to you")
                .font(.title2.weight(.heavy))
                .foregroundStyle(PilotBlue.Colors.text)
                .padding(.horizontal, PilotBlue.Space.xl)
                .padding(.top, PilotBlue.Space.xl)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(goals, id: \.0) { g in
                        PilotChip(title: g.1, isSelected: selectedGoals.contains(g.0)) {
                            if selectedGoals.contains(g.0) { selectedGoals.remove(g.0) }
                            else { selectedGoals.insert(g.0) }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, PilotBlue.Space.xl)
            }
        }
    }

    private func finish() {
        var snap = initial
        snap.hasCompletedOnboarding = true
        snap.selectedGenres = Array(selectedGenres)
        snap.readingGoals = Array(selectedGoals)
        do { try deps.prefs.save(snap) } catch {}
        onFinished(snap)
    }
}
