import SwiftUI

struct PopularRowCard: View {
    let rank: Int
    let anime: AnimeMedia

    var body: some View {
        HStack(spacing: 12) {
            Text(String(format: "%02d", rank))
                .font(.headline.monospacedDigit())
                .foregroundStyle(AniTrackTheme.mutedText)
                .frame(width: 28)

            RemoteImageView(urlString: anime.coverImage, contentMode: .fill)
                .frame(width: 48, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(anime.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(anime.genres.prefix(2).joined(separator: " • ").isEmpty ? "Anime" : anime.genres.prefix(2).joined(separator: " • "))
                    .font(.caption)
                    .foregroundStyle(AniTrackTheme.mutedText)
                    .lineLimit(1)
            }

            Spacer()

            if let score = anime.score {
                Label("\(score)", systemImage: "star.fill")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.yellow)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AniTrackTheme.card)
        )
    }
}
