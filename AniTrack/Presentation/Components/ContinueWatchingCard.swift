import SwiftUI

struct ContinueWatchingCard: View {
    let item: ContinueWatchingItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                RemoteImageView(urlString: item.anime.coverImage, contentMode: .fill)
                    .frame(width: 40, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .clipped()

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.anime.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    Text("Episode \(max(1, Int(Double(item.anime.episodes ?? 12) * item.progress)))")
                        .font(.caption2)
                        .foregroundStyle(AniTrackTheme.mutedText)
                }
            }

            ProgressView(value: item.progress)
                .tint(AniTrackTheme.accent)

            Button("Resume") { }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(AniTrackTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AniTrackTheme.card)
        )
    }
}
