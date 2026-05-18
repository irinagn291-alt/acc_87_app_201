import SwiftUI

struct AquaSubjectBrowse: View {
    @EnvironmentObject private var deps: AquaDependencies
    let slug: String
    let title: String

    @State private var books: [AquaSubjectBook] = []
    @State private var isLoading = true
    @State private var loadError: String?

    var body: some View {
        Group {
            if let loadError {
                PilotEmptyState(
                    title: "Could not load",
                    message: loadError,
                    systemImage: "wifi.exclamationmark",
                    actionTitle: "Retry",
                    action: { Task { await load() } }
                )
                .padding(.horizontal, PilotBlue.Space.xl)
            } else if isLoading {
                ProgressView().tint(PilotBlue.Colors.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if books.isEmpty {
                PilotEmptyState(title: "Nothing here", message: "Try again later.", systemImage: "books.vertical", actionTitle: "Retry", action: { Task { await load() } })
                    .padding(.horizontal, PilotBlue.Space.xl)
            } else {
                List {
                    Section {
                        ForEach(books) { book in
                            NavigationLink(value: AquaBookRoute.work(workKey: book.key, fallbackAuthors: book.authors)) {
                                AquaBookCard(
                                    title: book.title,
                                    authorsLine: book.authors.joined(separator: ", "),
                                    coverURL: AquaBookFactory.coverURLString(coverId: book.coverId).flatMap(URL.init(string:)),
                                    compact: true
                                )
                            }
                            .buttonStyle(PilotScalePress())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(PilotBlue.Colors.background)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        loadError = nil
        guard deps.connectivity.isOnline else { loadError = "You're offline"; isLoading = false; return }
        isLoading = true
        do {
            books = try await deps.searchRepo.subjectBooks(slug: slug, limit: 48, offset: 0)
            loadError = nil
        } catch {
            books = []; loadError = AquaStrings.userFacingError(error)
        }
        isLoading = false
    }
}
