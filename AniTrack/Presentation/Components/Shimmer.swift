import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -0.8
    let active: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                if active {
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.22),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(width: width * 0.7)
                        .rotationEffect(.degrees(18))
                        .offset(x: phase * width * 1.8)
                        .blendMode(.screen)
                    }
                    .allowsHitTesting(false)
                }
            }
            .mask(content)
            .onAppear {
                guard active else { return }
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.2
                }
            }
    }
}

extension View {
    func shimmering(active: Bool = true) -> some View {
        modifier(ShimmerModifier(active: active))
    }
}
