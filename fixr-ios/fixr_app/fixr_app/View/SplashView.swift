import SwiftUI

struct SplashView: View {
    @State private var glowOpacity: Double = 0.3
    @State private var glowScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.fixrBackground, Color(hex: "#1a1f2e")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Animated ring glow
            Circle()
                .stroke(Color.fixrPrimary.opacity(glowOpacity), lineWidth: 1.5)
                .frame(width: 200, height: 200)
                .scaleEffect(glowScale)
                .blur(radius: 8)
                .animation(
                    .easeInOut(duration: 2).repeatForever(autoreverses: true),
                    value: glowScale
                )

            Circle()
                .stroke(Color.fixrPrimary.opacity(glowOpacity * 0.5), lineWidth: 1)
                .frame(width: 280, height: 280)
                .scaleEffect(glowScale * 0.95)
                .blur(radius: 12)
                .animation(
                    .easeInOut(duration: 2.3).repeatForever(autoreverses: true),
                    value: glowScale
                )

            VStack(spacing: 12) {
                Text("FIXR")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundColor(.fixrText)
                    .tracking(8)
                    .opacity(logoOpacity)

                Text("Find help. Build skills.")
                    .font(.fixrBody)
                    .foregroundColor(.fixrMuted)
                    .opacity(logoOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.8)) {
                logoOpacity = 1
            }
            glowScale = 1.1
            glowOpacity = 0.6
        }
    }
}
