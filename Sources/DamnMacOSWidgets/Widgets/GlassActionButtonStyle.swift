import SwiftUI

struct GlassActionButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 12
    var horizontalPadding: CGFloat = 10
    var verticalPadding: CGFloat = 6

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.white.opacity(configuration.isPressed ? 0.14 : 0.06))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.white.opacity(configuration.isPressed ? 0.16 : 0.08), lineWidth: 0.8)
                    }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }
}
