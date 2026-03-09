import SwiftUI

struct FeaturedBannerCard: View {
    let anime: AnimeMedia
    let isTracked: Bool
    let isUpdatingTrackedState: Bool
    let onWatch: () -> Void
    let onToggleList: () -> Void
    var height: CGFloat = 205

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RemoteImageView(urlString: anime.bannerImage ?? anime.coverImage, contentMode: .fit)
            }
            .frame(maxWidth: .infinity)
            .background(AniTrackTheme.surface)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 18,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 18,
                    style: .continuous
                )
            )

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    if let score = anime.score {
                        Label("\(score)", systemImage: "star.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.yellow)
                    }
                    if let episodes = anime.episodes {
                        Text("\(episodes) eps")
                            .font(.caption)
                            .foregroundStyle(Color.white.opacity(0.85))
                    }
                }

                Text(anime.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                Text(anime.description)
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.8))
                    .lineLimit(10)
                    .fixedSize(horizontal: false, vertical: true)

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 10) {
                        Button("Watch", action: onWatch)
                            .font(.caption.weight(.bold))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(AniTrackTheme.accent)
                            .foregroundStyle(.black)
                            .clipShape(Capsule())

                        Button(action: onToggleList) {
                            HStack(spacing: 6) {
                                if isUpdatingTrackedState {
                                    ProgressView()
                                        .tint(isTracked ? .black : .white)
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: isTracked ? "checkmark.circle.fill" : "plus.circle")
                                }
                                Text(isTracked ? "In List" : "Add To List")
                            }
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity)
                        }
                            .padding(.vertical, 8)
                            .background(isTracked ? AniTrackTheme.accent : Color.white.opacity(0.15))
                            .foregroundStyle(isTracked ? .black : .white)
                            .clipShape(Capsule())
                            .disabled(isUpdatingTrackedState)
                    }

                    VStack(spacing: 8) {
                        Button("Watch", action: onWatch)
                            .font(.caption.weight(.bold))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(AniTrackTheme.accent)
                            .foregroundStyle(.black)
                            .clipShape(Capsule())

                        Button(action: onToggleList) {
                            HStack(spacing: 6) {
                                if isUpdatingTrackedState {
                                    ProgressView()
                                        .tint(isTracked ? .black : .white)
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: isTracked ? "checkmark.circle.fill" : "plus.circle")
                                }
                                Text(isTracked ? "In List" : "Add To List")
                            }
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity)
                        }
                            .padding(.vertical, 8)
                            .background(isTracked ? AniTrackTheme.accent : Color.white.opacity(0.15))
                            .foregroundStyle(isTracked ? .black : .white)
                            .clipShape(Capsule())
                            .disabled(isUpdatingTrackedState)
                    }
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AniTrackTheme.card)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}
