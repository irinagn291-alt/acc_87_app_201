import Foundation

enum AquaViewState<T> {
    case idle
    case loading
    case success(T)
    case empty
    case failure(String)

    var isLoading: Bool {
        if case .loading = self { true } else { false }
    }
}
