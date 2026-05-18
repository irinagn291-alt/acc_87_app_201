import SwiftUI

struct AquaNoteEditorView: View {
    @EnvironmentObject private var deps: AquaDependencies
    @Environment(\.dismiss) private var dismiss
    let bookID: UUID

    @State private var book: AquaBookEntry?
    @State private var rating: Double = 4
    @State private var text: String = ""

    var body: some View {
        Form {
            if book != nil {
                Section("Rating") {
                    PilotRatingStars(rating: $rating)
                }
                Section("Personal note") {
                    TextEditor(text: $text)
                        .frame(minHeight: 150)
                }
                Section {
                    Button("Save") { save() }
                        .foregroundStyle(PilotBlue.Colors.primary)
                    if !(book?.noteText ?? "").isEmpty {
                        Button("Delete note", role: .destructive) { deleteNote() }
                    }
                }
            } else {
                ProgressView().tint(PilotBlue.Colors.secondary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(PilotBlue.Colors.background)
        .navigationTitle("Notes & rating")
        .task { await load() }
    }

    private func load() async {
        do {
            book = try deps.books.book(id: bookID)
            if let b = book {
                rating = b.rating ?? 4
                text = b.noteText ?? ""
            }
        } catch { book = nil }
    }

    private func save() {
        guard var b = book else { return }
        let now = Date.now
        if b.noteText == nil || (b.noteText ?? "").isEmpty { b.noteCreatedAt = now }
        b.noteUpdatedAt = now
        b.noteText = text
        b.rating = rating
        b.lastUpdated = now
        do { try deps.books.upsert(b); book = b; dismiss() } catch {}
    }

    private func deleteNote() {
        guard var b = book else { return }
        b.noteText = nil; b.noteCreatedAt = nil; b.noteUpdatedAt = nil; b.lastUpdated = .now
        do { try deps.books.upsert(b); text = ""; book = b } catch {}
    }
}
