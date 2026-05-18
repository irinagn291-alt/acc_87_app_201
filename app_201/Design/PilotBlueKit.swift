import SwiftUI
import UIKit

enum PilotBlue {
    enum Colors {
        static let background = Color(hex: "#F2FAFF")
        static let surface = Color.white
        static let card = Color(hex: "#EAF5FF")
        static let border = Color(hex: "#C2DFF5")

        static let primary = Color(hex: "#1E88E5")
        static let primarySoft = Color(hex: "#DAEEFF")
        static let secondary = Color(hex: "#81D4FA")
        static let secondarySoft = Color(hex: "#E3F5FD")
        static let accent = Color(hex: "#00B8D9")
        static let accentSoft = Color(hex: "#D6F5FA")

        static let text = Color(hex: "#0A2540")
        static let textMuted = Color(hex: "#4A6887")

        static let success = Color(hex: "#1B8A5A")
        static let successSoft = Color(hex: "#D4F0E4")
        static let warning = Color(hex: "#B07D1A")
        static let warningSoft = Color(hex: "#FFF0C8")
        static let danger = Color(hex: "#C0392B")
        static let dangerSoft = Color(hex: "#FDDEDE")
        static let rating = Color(hex: "#F0AA00")
    }

    enum Space {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum Radius {
        static let sm: CGFloat = 10
        static let md: CGFloat = 14
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
        static let cover: CGFloat = 12
    }

    static func coverAccent(for title: String) -> Color {
        let palette: [Color] = [
            Colors.primary, Colors.accent, Colors.secondary,
            Color(hex: "#0D6EFD"), Color(hex: "#0077B6"), Color(hex: "#023E8A"),
            Color(hex: "#1A6B5E"),
        ]
        let hash = title.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return palette[abs(hash) % palette.count]
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

enum PilotMotion {
    @MainActor static var reduced: Bool { UIAccessibility.isReduceMotionEnabled }
    @MainActor static func anim(_ a: Animation?) -> Animation? { reduced ? .linear(duration: 0.01) : a }
}

struct PilotPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(PilotBlue.Colors.primary))
            .foregroundStyle(Color.white)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(PilotMotion.anim(.easeOut(duration: 0.15)), value: configuration.isPressed)
    }
}

struct PilotSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(PilotBlue.Colors.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(PilotBlue.Colors.primarySoft))
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

struct PilotScalePress: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(PilotMotion.anim(.easeOut(duration: 0.18)), value: configuration.isPressed)
    }
}

extension View {
    func pilotCardShadow() -> some View {
        shadow(color: PilotBlue.Colors.primary.opacity(0.10), radius: 16, x: 0, y: 6)
    }

    func pilotSoftShadow() -> some View {
        shadow(color: PilotBlue.Colors.text.opacity(0.06), radius: 10, x: 0, y: 3)
    }
}

struct PilotCoverView: View {
    let url: URL?
    let title: String
    var author: String? = nil
    var size: PilotCoverSize = .medium

    var body: some View {
        ZStack(alignment: .leading) {
            Group {
                if let url {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        case .failure: placeholder
                        case .empty: ProgressView().tint(PilotBlue.Colors.secondary).frame(maxWidth: .infinity, maxHeight: .infinity)
                        @unknown default: placeholder
                        }
                    }
                } else {
                    placeholder
                }
            }
            LinearGradient(
                colors: [Color.black.opacity(0.22), Color.black.opacity(0.06), Color.clear],
                startPoint: .leading,
                endPoint: UnitPoint(x: 0.4, y: 0.5)
            )
            .frame(width: min(14, size.width * 0.12))
            .allowsHitTesting(false)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: PilotBlue.Radius.cover, style: .continuous))
        .shadow(color: PilotBlue.Colors.primary.opacity(0.14), radius: 8, x: 0, y: 4)
        .accessibilityLabel("Cover: \(title)")
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(
                colors: [PilotBlue.coverAccent(for: title), PilotBlue.Colors.text],
                startPoint: UnitPoint(x: 0.1, y: 0),
                endPoint: UnitPoint(x: 1, y: 1)
            )
            VStack(spacing: 8) {
                Capsule()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: size.width * 0.42, height: 2)
                Spacer(minLength: 0)
                Text(title)
                    .font(.system(size: size.titleFont, weight: .black))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .padding(.horizontal, size.pad)
                if let author, !author.isEmpty {
                    Text(author.uppercased())
                        .font(.system(size: size.authorFont, weight: .heavy))
                        .foregroundStyle(Color.white.opacity(0.65))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                Spacer(minLength: 0)
                Circle()
                    .strokeBorder(Color.white.opacity(0.45), lineWidth: 1.5)
                    .frame(width: 16, height: 16)
            }
            .padding(.vertical, size.pad)
        }
    }
}

enum PilotCoverSize: Sendable {
    case small, medium, large
    case custom(width: CGFloat, height: CGFloat)

    var width: CGFloat {
        switch self { case .small: 74; case .medium: 104; case .large: 140; case .custom(let w, _): w }
    }
    var height: CGFloat {
        switch self { case .small: 110; case .medium: 156; case .large: 210; case .custom(_, let h): h }
    }
    fileprivate var titleFont: CGFloat {
        switch self { case .small: 9; case .medium: 11; case .large: 14; case .custom: 10 }
    }
    fileprivate var authorFont: CGFloat {
        switch self { case .small: 7; case .medium: 8; case .large: 10; case .custom: 8 }
    }
    fileprivate var pad: CGFloat {
        switch self { case .small: 8; case .medium: 10; case .large: 14; case .custom: 9 }
    }
}

struct PilotStatusBadge: View {
    let status: AquaReadStatus

    private var colors: (Color, Color) {
        switch status {
        case .wantToRead: (PilotBlue.Colors.secondarySoft, PilotBlue.Colors.secondary)
        case .reading: (PilotBlue.Colors.primarySoft, PilotBlue.Colors.primary)
        case .finished: (PilotBlue.Colors.successSoft, PilotBlue.Colors.success)
        case .paused: (PilotBlue.Colors.warningSoft, PilotBlue.Colors.warning)
        case .dropped: (PilotBlue.Colors.dangerSoft, PilotBlue.Colors.danger)
        }
    }

    var body: some View {
        Text(status.label)
            .font(.system(size: 11, weight: .black))
            .foregroundStyle(colors.1)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(Capsule().fill(colors.0))
    }
}

struct PilotRatingBadge: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 12))
                .foregroundStyle(PilotBlue.Colors.rating)
            Text(String(format: "%.1f", rating))
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(PilotBlue.Colors.text)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(Capsule().fill(PilotBlue.Colors.accentSoft))
    }
}

struct PilotEmptyState: View {
    let title: String
    let message: String
    var systemImage: String = "books.vertical"
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: PilotBlue.Space.lg) {
            ZStack {
                Circle()
                    .fill(PilotBlue.Colors.primarySoft)
                    .frame(width: 88, height: 88)
                Image(systemName: systemImage)
                    .font(.system(size: 40))
                    .foregroundStyle(PilotBlue.Colors.primary)
            }
            Text(title)
                .font(.system(size: 21, weight: .black))
                .foregroundStyle(PilotBlue.Colors.text)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(PilotBlue.Colors.textMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(PilotBlue.Colors.primary))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(PilotBlue.Space.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous)
                .fill(PilotBlue.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous)
                        .stroke(PilotBlue.Colors.border, lineWidth: 1)
                )
                .pilotCardShadow()
        )
    }
}

struct PilotProgressBar: View {
    let value: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(PilotBlue.Colors.primarySoft)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [PilotBlue.Colors.primary, PilotBlue.Colors.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(6, geo.size.width * min(1, max(0, value))))
                    .animation(PilotMotion.anim(.easeInOut(duration: 0.32)), value: value)
            }
        }
        .frame(height: 10)
        .accessibilityLabel("Progress \(Int(min(1, max(0, value)) * 100)) percent")
    }
}

struct PilotRatingStars: View {
    @Binding var rating: Double
    var maxStars: Int = 5

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...maxStars, id: \.self) { i in
                Image(systemName: symbol(for: i))
                    .font(.title3)
                    .foregroundStyle(amount(for: i) > 0 ? PilotBlue.Colors.rating : PilotBlue.Colors.border)
                    .onTapGesture {
                        withAnimation(PilotMotion.anim(.spring(duration: 0.22))) { rating = Double(i) }
                    }
            }
            Button("½") {
                let i = max(1, Int(ceil(rating)))
                rating = min(Double(maxStars), Double(i) - 0.5)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(PilotBlue.Colors.textMuted)
        }
    }

    private func amount(for index: Int) -> Double { min(1, max(0, rating - Double(index - 1))) }
    private func symbol(for index: Int) -> String {
        let a = amount(for: index)
        if a >= 1 { return "star.fill" }
        if a >= 0.5 { return "star.leadinghalf.filled" }
        return "star"
    }
}

struct PilotStatusPicker: View {
    @Binding var status: AquaReadStatus

    var body: some View {
        Picker("Status", selection: $status) {
            ForEach(AquaReadStatus.allCases, id: \.self) { s in
                Text(s.label).tag(s)
            }
        }
        .pickerStyle(.menu)
    }
}

struct PilotChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(isSelected ? Color.white : PilotBlue.Colors.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(isSelected ? PilotBlue.Colors.primary : PilotBlue.Colors.surface)
                        .overlay(Capsule().stroke(PilotBlue.Colors.border, lineWidth: 1))
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct PilotSettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var danger: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PilotBlue.Space.md) {
                ZStack {
                    Circle()
                        .fill(danger ? PilotBlue.Colors.dangerSoft : PilotBlue.Colors.primarySoft)
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(danger ? PilotBlue.Colors.danger : PilotBlue.Colors.primary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(danger ? PilotBlue.Colors.danger : PilotBlue.Colors.text)
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(PilotBlue.Colors.textMuted)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(PilotBlue.Colors.textMuted)
            }
            .padding(PilotBlue.Space.md)
            .background(
                RoundedRectangle(cornerRadius: PilotBlue.Radius.lg, style: .continuous)
                    .fill(PilotBlue.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: PilotBlue.Radius.lg, style: .continuous)
                            .stroke(PilotBlue.Colors.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PilotScalePress())
    }
}

struct PilotLinkRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: PilotBlue.Space.md) {
            ZStack {
                Circle()
                    .fill(PilotBlue.Colors.primarySoft)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(PilotBlue.Colors.primary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(PilotBlue.Colors.text)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(PilotBlue.Colors.textMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(PilotBlue.Colors.textMuted)
        }
        .padding(PilotBlue.Space.md)
        .background(
            RoundedRectangle(cornerRadius: PilotBlue.Radius.lg, style: .continuous)
                .fill(PilotBlue.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: PilotBlue.Radius.lg, style: .continuous)
                        .stroke(PilotBlue.Colors.border, lineWidth: 1)
                )
        )
    }
}

struct PilotStatTile: View {
    let title: String
    let value: String
    var systemImage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(PilotBlue.Colors.textMuted)
                Spacer()
                if let systemImage {
                    Image(systemName: systemImage)
                        .foregroundStyle(PilotBlue.Colors.textMuted)
                }
            }
            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(PilotBlue.Colors.text)
        }
        .padding(PilotBlue.Space.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: PilotBlue.Radius.md, style: .continuous)
                .fill(PilotBlue.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: PilotBlue.Radius.md, style: .continuous)
                        .stroke(PilotBlue.Colors.border, lineWidth: 1)
                )
                .pilotSoftShadow()
        )
    }
}

struct PilotTagsStrip: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(tags, id: \.self) { t in
                    Text(t)
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(PilotBlue.Colors.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(PilotBlue.Colors.primarySoft)
                                .overlay(Capsule().stroke(PilotBlue.Colors.border, lineWidth: 1))
                        )
                }
            }
        }
    }
}

struct PilotShelfStrip: View {
    let books: [(id: String, title: String, coverURL: URL?)]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: PilotBlue.Space.sm) {
                    ForEach(books, id: \.id) { b in
                        PilotCoverView(url: b.coverURL, title: b.title, size: .medium)
                    }
                }
                .padding(.trailing, PilotBlue.Space.xl)
            }
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(PilotBlue.Colors.primary)
                .frame(height: 9)
                .padding(.top, 6)
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(PilotBlue.Colors.text.opacity(0.10))
                .frame(height: 7)
                .padding(.horizontal, 10)
                .padding(.top, -1)
        }
        .padding(.bottom, 8)
    }
}
