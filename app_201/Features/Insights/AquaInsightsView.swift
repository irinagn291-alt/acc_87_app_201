import Charts
import SwiftUI

struct AquaInsightsView: View {
    @EnvironmentObject private var deps: AquaDependencies
    @State private var books: [AquaBookEntry] = []
    @State private var events: [AquaProgressEvent] = []

    private var summary: AquaStatsEngine.Summary {
        AquaStatsEngine.compute(books: books, events: events)
    }

    var body: some View {
        List {
            Section("Overview") {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: PilotBlue.Space.md) {
                    PilotStatTile(title: "Total books", value: "\(summary.totalBooks)", systemImage: "books.vertical")
                    PilotStatTile(title: "Reading", value: "\(summary.reading)", systemImage: "bookmark")
                    PilotStatTile(title: "Finished", value: "\(summary.finished)", systemImage: "checkmark.circle")
                    PilotStatTile(title: "Want to read", value: "\(summary.wantToRead)", systemImage: "text.book.closed")
                }
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 4)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            if let avg = summary.averageRating {
                Section {
                    LabeledContent("Average rating", value: String(format: "%.2f ★", avg))
                }
            }
            if let ap = summary.avgProgressActive {
                Section {
                    LabeledContent("Avg. progress (reading)", value: String(format: "%.0f%%", ap * 100))
                }
            }

            Section("By status") {
                Chart {
                    BarMark(x: .value("Status", AquaReadStatus.wantToRead.label), y: .value("Count", summary.wantToRead))
                        .foregroundStyle(PilotBlue.Colors.secondary)
                    BarMark(x: .value("Status", AquaReadStatus.reading.label), y: .value("Count", summary.reading))
                        .foregroundStyle(PilotBlue.Colors.primary)
                    BarMark(x: .value("Status", AquaReadStatus.finished.label), y: .value("Count", summary.finished))
                        .foregroundStyle(PilotBlue.Colors.success)
                    BarMark(x: .value("Status", AquaReadStatus.paused.label), y: .value("Count", summary.paused))
                        .foregroundStyle(PilotBlue.Colors.warning)
                }
                .frame(height: 200)
            }

            if !summary.finishedByMonth.isEmpty {
                Section("Finished by month") {
                    Chart(summary.finishedByMonth, id: \.month) { row in
                        BarMark(x: .value("Month", row.month), y: .value("Books", row.count))
                            .foregroundStyle(PilotBlue.Colors.primary)
                    }
                    .frame(height: 200)
                }
            }

            if !summary.topAuthors.isEmpty {
                Section("Top authors") {
                    Chart(summary.topAuthors, id: \.name) { row in
                        BarMark(x: .value("Books", row.count), y: .value("Author", row.name))
                            .foregroundStyle(PilotBlue.Colors.accent)
                    }
                    .frame(height: min(480, CGFloat(summary.topAuthors.count) * 28))
                }
            }

            if !summary.topSubjects.isEmpty {
                Section("Top subjects") {
                    Chart(summary.topSubjects, id: \.name) { row in
                        BarMark(x: .value("Books", row.count), y: .value("Subject", row.name))
                            .foregroundStyle(PilotBlue.Colors.secondary)
                    }
                    .frame(height: min(480, CGFloat(summary.topSubjects.count) * 28))
                }
            }

            Section("Navigation") {
                NavigationLink("Week Plan") { WeekFlightPlanView() }
                NavigationLink("Mood collections") { AquaMoodDeckView() }
                NavigationLink("Search") { PilotSearchDeck() }
            }
        }
        .scrollContentBackground(.hidden)
        .background(PilotBlue.Colors.background)
        .navigationTitle("Insights")
        .navigationDestination(for: AquaBookRoute.self) { AquaBookDetailView(route: $0) }
        .task { await load() }
        .refreshable { await load() }
    }

    private func load() async {
        do {
            books = try deps.books.allBooks()
            events = try deps.progress.allEvents()
        } catch { books = []; events = [] }
    }
}
