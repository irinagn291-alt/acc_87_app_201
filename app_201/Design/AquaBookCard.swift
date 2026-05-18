import SwiftUI

struct AquaBookCard: View {
    let title: String
    let authorsLine: String
    let coverURL: URL?
    var rating: Double? = nil
    var status: AquaReadStatus? = nil
    var year: Int? = nil
    var compact: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: compact ? PilotBlue.Space.md : PilotBlue.Space.lg) {
            PilotCoverView(
                url: coverURL,
                title: title,
                author: authorsLine.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces),
                size: compact ? .small : .medium
            )

            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: compact ? 15 : 17, weight: .black))
                    .foregroundStyle(PilotBlue.Colors.text)
                    .lineLimit(2)

                if !authorsLine.isEmpty {
                    Text(authorsLine)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(PilotBlue.Colors.textMuted)
                        .lineLimit(1)
                        .padding(.top, 5)
                }

                if let year {
                    Text(String(year))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(PilotBlue.Colors.textMuted)
                        .padding(.top, 3)
                }

                Spacer(minLength: 6)

                HStack(spacing: 7) {
                    if let rating { PilotRatingBadge(rating: rating) }
                    if let status { PilotStatusBadge(status: status) }
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, compact ? 2 : 4)
        }
        .padding(compact ? PilotBlue.Space.sm : PilotBlue.Space.md)
        .background(PilotBlue.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous)
                .stroke(PilotBlue.Colors.border, lineWidth: 1)
        )
        .pilotCardShadow()
    }
}

struct AquaSearchBarLabel: View {
    let placeholder: String

    var body: some View {
        HStack(spacing: PilotBlue.Space.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20))
                .foregroundStyle(PilotBlue.Colors.textMuted)
            Text(placeholder)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(PilotBlue.Colors.textMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "water.waves")
                .font(.system(size: 18))
                .foregroundStyle(PilotBlue.Colors.secondary)
        }
        .padding(.horizontal, PilotBlue.Space.lg)
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous)
                .fill(PilotBlue.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: PilotBlue.Radius.xl, style: .continuous)
                        .stroke(PilotBlue.Colors.border, lineWidth: 1)
                )
                .pilotSoftShadow()
        )
    }
}

struct AquaContinueCard: View {
    let title: String
    let author: String?
    let coverURL: URL?
    let progress: Double

    var body: some View {
        HStack(alignment: .top, spacing: PilotBlue.Space.lg) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Continue reading")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(PilotBlue.Colors.secondary)
                    .textCase(.uppercase)
                    .tracking(0.6)

                Text(title)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                    .padding(.top, 8)

                if let author, !author.isEmpty {
                    Text(author)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.70))
                        .lineLimit(1)
                        .padding(.top, 4)
                }

                Spacer(minLength: 8)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Progress").font(.system(size: 11, weight: .heavy)).foregroundStyle(Color.white.opacity(0.70))
                        Spacer()
                        Text("\(Int(progress * 100))%").font(.system(size: 11, weight: .black)).foregroundStyle(Color.white)
                    }
                    PilotProgressBar(value: progress)
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            PilotCoverView(url: coverURL, title: title, author: author, size: .large)
        }
        .padding(PilotBlue.Space.lg)
        .background(
            LinearGradient(
                colors: [PilotBlue.Colors.primary, PilotBlue.Colors.accent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .pilotCardShadow()
    }
}
