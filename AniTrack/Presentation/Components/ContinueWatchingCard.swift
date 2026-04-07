import SwiftUI

struct ContinueWatchingCard: View {
    let item: HomeTrackingItem
    let isUpdating: Bool
    let onOpen: () -> Void
    let onPrimaryAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onOpen) {
                HStack(alignment: .top, spacing: 12) {
                    RemoteImageView(urlString: item.media.coverImage, contentMode: .fill)
                        .frame(width: 52, height: 76)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .clipped()

                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.media.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        Text(item.progressLabel)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AniTrackTheme.accent)

                        Text(item.supportingText)
                            .font(.caption)
                            .foregroundStyle(AniTrackTheme.mutedText)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.45))
                        .padding(.top, 4)
                }
            }
            .buttonStyle(.plain)

            if let progress = item.progressFraction {
                ProgressView(value: progress)
                    .tint(AniTrackTheme.accent)
            }

            Button(action: onPrimaryAction) {
                HStack(spacing: 8) {
                    if isUpdating {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    }

                    Text(item.primaryActionLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(buttonBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isUpdating)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AniTrackTheme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.05), lineWidth: 1)
        )
    }

    private var buttonBackground: some ShapeStyle {
        switch item.primaryAction {
        case .incrementEpisode:
            return AnyShapeStyle(AniTrackTheme.accent)
        case .markComplete:
            return AnyShapeStyle(Color.green.opacity(0.75))
        case .viewDetails:
            return AnyShapeStyle(AniTrackTheme.surface)
        }
    }
}
