import SwiftUI

extension View {
    @ViewBuilder
    func liquidGlassBackground(
        cornerRadius: CGFloat
    ) -> some View {
        if #available(macOS 26.0, *) {
            glassEffect(.clear, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.white.opacity(0.03))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.8)
                    }
            }
        }
    }
}
