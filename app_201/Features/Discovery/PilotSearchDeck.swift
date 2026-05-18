import SwiftUI

struct PilotSearchDeck: View {
    @EnvironmentObject private var deps: AquaDependencies

    var pickHitHandler: ((AquaSearchHit) -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    @State private var query: String = ""
    @State private var state: AquaViewState<[AquaSearchHit]> = .idle
    @State private var searchTask: Task<Void, Never>?
    @State private var epoch = 0
    @State private var path = NavigationPath()
    @State private var showScanner = false
    @State private var showSimulatorNotice = false

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    HStack(spacing: PilotBlue.Space.md) {
                        Image(systemName: "magnifyingglass").foregroundStyle(PilotBlue.Colors.textMuted)
                        TextField("Title or ISBN", text: $query)
                            .textInputAutocapitalization(.words)
                            .foregroundStyle(PilotBlue.Colors.text)
                            .onChange(of: query) { _, v in scheduleSearch(v) }
                    }
                    .padding(.horizontal, PilotBlue.Space.md)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: PilotBlue.Radius.lg, style: .continuous)
                            .fill(PilotBlue.Colors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: PilotBlue.Radius.lg, style: .continuous)
                                    .stroke(PilotBlue.Colors.border, lineWidth: 1)
                            )
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                if !deps.connectivity.isOnline {
                    Section {
                        Text("You're offline — search unavailable")
                            .foregroundStyle(PilotBlue.Colors.textMuted)
                            .listRowBackground(Color.clear)
                    }
                }

                switch state {
                case .idle: EmptyView()
                case .loading:
                    Section {
                        HStack(spacing: PilotBlue.Space.sm) {
                            ProgressView().tint(PilotBlue.Colors.primary)
                            Text("Searching…").foregroundStyle(PilotBlue.Colors.textMuted)
                        }
                        .listRowBackground(Color.clear)
                    }
                case .empty:
                    Section {
                        PilotEmptyState(title: "No results", message: "Try another title or keyword.", systemImage: "magnifyingglass")
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                case .failure(let msg):
                    Section {
                        PilotEmptyState(
                            title: "Search unavailable",
                            message: msg,
                            systemImage: "wifi.exclamationmark",
                            actionTitle: "Retry",
                            action: { scheduleSearch(query) }
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                case .success(let hits):
                    Section {
                        ForEach(hits) { h in
                            Button {
                                if let ph = pickHitHandler { ph(h); dismiss() }
                                else { path.append(AquaBookRoute.hit(h)) }
                            } label: {
                                AquaBookCard(
                                    title: h.title,
                                    authorsLine: h.authors.joined(separator: ", "),
                                    coverURL: AquaBookFactory.coverURLString(coverId: h.coverId).flatMap(URL.init(string:)),
                                    compact: true
                                )
                            }
                            .buttonStyle(PilotScalePress())
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    } header: {
                        Text("Results")
                            .font(.system(size: 19, weight: .heavy))
                            .foregroundStyle(PilotBlue.Colors.text)
                            .textCase(nil)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(PilotBlue.Colors.background)
            .navigationTitle(pickHitHandler == nil ? "Search" : "Add book")
            .toolbar {
                if pickHitHandler == nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            #if targetEnvironment(simulator)
                            showSimulatorNotice = true
                            #else
                            showScanner = true
                            #endif
                        } label: {
                            Label("Scan ISBN", systemImage: "barcode.viewfinder")
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showScanner) {
                AquaISBNScannerView(
                    onISBN: { code in showScanner = false; query = code },
                    onDismiss: { showScanner = false }
                )
                .ignoresSafeArea()
            }
            .alert("Camera unavailable on simulator", isPresented: $showSimulatorNotice) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("ISBN scanning requires a physical device with a camera.")
            }
            .navigationDestination(for: AquaBookRoute.self) { route in
                AquaBookDetailView(route: route)
            }
        }
    }

    private func scheduleSearch(_ text: String) {
        searchTask?.cancel()
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { epoch += 1; state = .idle; return }
        epoch += 1
        let e = epoch
        searchTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 380_000_000)
            guard !Task.isCancelled else { return }
            await runSearch(trimmed, epoch: e)
        }
    }

    @MainActor
    private func runSearch(_ text: String, epoch e: Int) async {
        guard e == epoch else { return }
        state = .loading
        do {
            if !deps.connectivity.isOnline { guard e == epoch else { return }; state = .failure("You're offline"); return }
            let hits: [AquaSearchHit]
            if AquaISBNNorm.looksLikeISBN(text) {
                hits = try await deps.searchRepo.searchByQuery(AquaISBNNorm.digitsOnly(text), limit: 30, offset: 0)
            } else {
                hits = try await deps.searchRepo.searchByTitle(text, limit: 30, offset: 0)
            }
            guard e == epoch else { return }
            state = hits.isEmpty ? .empty : .success(hits)
        } catch {
            guard e == epoch else { return }
            if let msg = AquaStrings.userFacingError(error) { state = .failure(msg) }
            else { state = .idle }
        }
    }
}
