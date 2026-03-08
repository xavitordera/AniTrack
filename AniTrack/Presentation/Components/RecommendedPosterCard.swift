import SwiftUI

struct RecommendedPosterCard: View {
    let anime: AnimeMedia

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RemoteImageView(urlString: anime.coverImage, contentMode: .fill)
                .aspectRatio(2.0 / 3.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .clipped()

            Text(anime.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(anime.genres.prefix(2).joined(separator: ", ").isEmpty ? "Anime" : anime.genres.prefix(2).joined(separator: ", "))
                .font(.caption2)
                .foregroundStyle(AniTrackTheme.mutedText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
