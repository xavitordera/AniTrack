import SwiftUI

struct RemoteImageView: View {
    let urlString: String?
    var contentMode: ContentMode = .fit

    var body: some View {
        AsyncImage(url: URL(string: urlString ?? "")) { phase in
            switch phase {
            case .empty:
                ZStack {
                    AniTrackTheme.surface
                    ProgressView()
                }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .failure:
                ZStack {
                    AniTrackTheme.surface
                    Image(systemName: "photo")
                        .foregroundStyle(AniTrackTheme.mutedText)
                }
            @unknown default:
                Color.clear
            }
        }
    }
}
