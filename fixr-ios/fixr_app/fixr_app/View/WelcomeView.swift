import SwiftUI

struct WelcomeView: View {
    var onGetStarted: () -> Void
    var onSignIn: () -> Void

    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20

    var body: some View {
        ZStack {
            FixrGradientBackground()

            VStack(spacing: 0) {
                // Top spacer
                Spacer()
                    .frame(height: 60)

                // Logo
                FixrLogoHeader(subtitle: "Quebec Home Services")
                    .padding(.bottom, 48)

                // Hero illustration placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.fixrCard)
                        .frame(height: 220)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "house.and.flag.fill")
                                    .font(.system(size: 64))
                                    .foregroundColor(.fixrPrimary.opacity(0.7))
                                Text("Trusted trades in your area")
                                    .font(.fixrCaption)
                                    .foregroundColor(.fixrMuted)
                            }
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)

                // Hero text
                VStack(spacing: 10) {
                    Text("Home repairs,\ndone right.")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.fixrText)
                        .multilineTextAlignment(.center)

                    Text("Connect with verified Quebec tradespeople\nor find your next job as a Fixer.")
                        .font(.fixrBody)
                        .foregroundColor(.fixrMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 48)

                Spacer()

                // CTA buttons
                VStack(spacing: 14) {
                    FixrPrimaryButton("Get Started", action: onGetStarted)
                    FixrSecondaryButton("Sign In", action: onSignIn)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
            .opacity(contentOpacity)
            .offset(y: contentOffset)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                contentOpacity = 1
                contentOffset = 0
            }
        }
    }
}
