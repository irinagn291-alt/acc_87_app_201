import SwiftUI

struct AquaProgressDeckView: View {
    @EnvironmentObject private var deps: AquaDependencies
    let bookID: UUID

    @State private var book: AquaBookEntry?
    @State private var current: String = ""
    @State private var total: String = ""
    @State private var showCompleteAlert = false
    @State private var debounce: Task<Void, Never>?

    var body: some View {
        Form {
            if book != nil {
                Section("Pages") {
                    TextField("Current page", text: $current).keyboardType(.numberPad)
                    TextField("Total pages", text: $total).keyboardType(.numberPad)
                }

                if let t = Int(total), t > 0, let c = Int(current) {
                    Section("Progress") {
                        VStack(alignment: .leading, spacing: 8) {
                            PilotProgressBar(value: AquaPageCalc.progressRatio(current: c, total: t) ?? 0)
                            Text("\(AquaPageCalc.clamped(c, total: t)) of \(t) (\(Int((AquaPageCalc.progressRatio(current: c, total: t) ?? 0) * 100))%)")
                                .foregroundStyle(PilotBlue.Colors.textMuted)
                        }
                    }

                    Section("Quick add") {
                        HStack(spacing: PilotBlue.Space.lg) {
                            quickBtn("+1", 1, t)
                            quickBtn("+5", 5, t)
                            quickBtn("+10", 10, t)
                            quickBtn("+25", 25, t)
                        }
                    }

                    Section {
                        Button("Mark as finished") { markFinished(total: t) }
                            .foregroundStyle(PilotBlue.Colors.primary)
                    }
                }
            } else {
                ProgressView().tint(PilotBlue.Colors.secondary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(PilotBlue.Colors.background)
        .navigationTitle("Progress")
        .task { await load() }
        .onChange(of: current) { _, _ in saveDebounced() }
        .onChange(of: total) { _, _ in saveDebounced() }
        .alert("Well done!", isPresented: $showCompleteAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You reached the last page. Consider leaving a note or rating.")
        }
    }

    private func quickBtn(_ label: String, _ delta: Int, _ total: Int) -> some View {
        Button(label) { bump(delta, total: total) }
            .font(.system(size: 15, weight: .heavy))
            .foregroundStyle(PilotBlue.Colors.primary)
    }

    private func load() async {
        do {
            book = try deps.books.book(id: bookID)
            if let b = book {
                current = String(b.currentPage)
                total = b.totalPages.map(String.init) ?? ""
            }
        } catch { book = nil }
    }

    private func bump(_ delta: Int, total: Int) {
        let base = Int(current) ?? 0
        let next = min(total, max(0, base + delta))
        current = String(next)
        saveNow()
        if next >= total { showCompleteAlert = true }
    }

    private func markFinished(total: Int) {
        current = String(total)
        saveNow(status: .finished)
        showCompleteAlert = true
    }

    private func saveDebounced() {
        debounce?.cancel()
        debounce = Task {
            try? await Task.sleep(nanoseconds: 440_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { saveNow() }
        }
    }

    private func saveNow(status: AquaReadStatus? = nil) {
        guard var b = book else { return }
        let oldPage = b.currentPage
        let newTotal = Int(total).flatMap { $0 > 0 ? $0 : nil }
        let rawCurrent = Int(current) ?? b.currentPage
        let newCurrent = AquaPageCalc.clamped(rawCurrent, total: newTotal)
        b.currentPage = newCurrent
        b.totalPages = newTotal
        if let status { b.status = status }
        if b.status == .reading, b.dateStarted == nil { b.dateStarted = .now }
        if b.status == .finished, b.dateFinished == nil { b.dateFinished = .now }
        b.lastUpdated = .now
        do {
            try deps.books.upsert(b)
            let delta = newCurrent - oldPage
            if delta > 0 { try deps.progress.logDelta(bookId: b.id, delta: delta) }
            book = b
        } catch {}
    }
}
