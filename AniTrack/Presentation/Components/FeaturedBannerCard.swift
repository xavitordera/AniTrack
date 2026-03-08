import SwiftUI

struct FeaturedBannerCard: View {
    let anime: AnimeMedia
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
                        Button("Watch") { }
                            .font(.caption.weight(.bold))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(AniTrackTheme.accent)
                            .foregroundStyle(.black)
                            .clipShape(Capsule())

                        Button("+ List") { }
                            .font(.caption.weight(.semibold))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.15))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }

                    VStack(spacing: 8) {
                        Button("Watch") { }
                            .font(.caption.weight(.bold))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(AniTrackTheme.accent)
                            .foregroundStyle(.black)
                            .clipShape(Capsule())

                        Button("+ List") { }
                            .font(.caption.weight(.semibold))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.15))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
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
