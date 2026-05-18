import SwiftUI

struct WeekFlightPlanView: View {
    @EnvironmentObject private var deps: AquaDependencies
    @State private var items: [AquaWeekItem] = []
    @State private var selectedDay: Int = 0
    @State private var showAddSheet = false
    @State private var moveTarget: AquaWeekItem? = nil
    @State private var moveToDay: Int = 0

    private let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    private func itemsForDay(_ day: Int) -> [AquaWeekItem] {
        items.filter { $0.dayIndex == day }
    }

    var body: some View {
        List {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: PilotBlue.Space.sm) {
                        ForEach(0..<7, id: \.self) { i in
                            Button(dayNames[i]) { selectedDay = i }
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundStyle(selectedDay == i ? Color.white : PilotBlue.Colors.text)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(
                                    Capsule()
                                        .fill(selectedDay == i ? PilotBlue.Colors.primary : PilotBlue.Colors.surface)
                                        .overlay(Capsule().stroke(PilotBlue.Colors.border, lineWidth: 1))
                                )
                                .buttonStyle(.plain)
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            Section {
                Button {
                    showAddSheet = true
                } label: {
                    Label("Add book to \(dayNames[selectedDay])", systemImage: "plus.circle.fill")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(PilotBlue.Colors.primary)
                }
                .listRowBackground(Color.clear)
            }

            let dayItems = itemsForDay(selectedDay)
            if dayItems.isEmpty {
                Section {
                    PilotEmptyState(
                        title: "Nothing planned",
                        message: "Tap 'Add book' to schedule a read for \(dayNames[selectedDay]).",
                        systemImage: "calendar"
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            } else {
                Section(dayNames[selectedDay]) {
                    ForEach(dayItems) { item in
                        HStack(spacing: PilotBlue.Space.md) {
                            PilotCoverView(
                                url: AquaBookFactory.coverURLString(coverId: item.coverId).flatMap(URL.init(string:)),
                                title: item.title,
                                size: .small
                            )
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundStyle(PilotBlue.Colors.text)
                                    .lineLimit(2)
                                if !item.authors.isEmpty {
                                    Text(item.authors.joined(separator: ", "))
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(PilotBlue.Colors.textMuted)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            Menu {
                                ForEach(0..<7, id: \.self) { d in
                                    if d != selectedDay {
                                        Button("Move to \(dayNames[d])") {
                                            try? deps.weekStore.move(id: item.id, toDayIndex: d)
                                            Task { loadItems() }
                                        }
                                    }
                                }
                                Button("Remove", role: .destructive) {
                                    try? deps.weekStore.delete(id: item.id)
                                    Task { loadItems() }
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .foregroundStyle(PilotBlue.Colors.textMuted)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(PilotBlue.Colors.background)
        .navigationTitle("Week Plan")
        .onAppear { loadItems() }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                PilotSearchDeck(pickHitHandler: { hit in
                    try? deps.weekStore.add(hit: hit, dayIndex: selectedDay)
                    showAddSheet = false
                    loadItems()
                })
                .environmentObject(deps)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { showAddSheet = false }
                    }
                }
            }
        }
    }

    private func loadItems() {
        items = (try? deps.weekStore.allItems()) ?? []
    }
}
