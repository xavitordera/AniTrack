import SwiftUI

struct RecommendedPosterCard: View {
    let anime: AnimeMedia

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RemoteImageView(urlString: anime.coverImage, contentMode: .fill)
                .aspectRatio(2.0 / 3.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .clipped()
                .overlay(alignment: .topLeading) {
                    if let score = anime.score {
                        Label("\(score)", systemImage: "star.fill")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.yellow, .yellow)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                            .padding(8)
                    }
                }

            Text(anime.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(anime.genres.prefix(2).joined(separator: ", ").isEmpty ? "Anime" : anime.genres.prefix(2).joined(separator: ", "))
                .font(.caption2)
                .foregroundStyle(AniTrackTheme.mutedText)
                .lineLimit(1)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
