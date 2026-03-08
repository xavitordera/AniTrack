import SwiftUI

struct CategoryChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? Color.black : Color.white)
                .padding(.vertical, 9)
                .padding(.horizontal, 14)
                .background(
                    Capsule()
                        .fill(isSelected ? AniTrackTheme.accent : AniTrackTheme.surface)
                )
        }
        .buttonStyle(.plain)
    }
}
