import SwiftUI

// MARK: - Gradient Background

struct FixrGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color.fixrBackground, Color(hex: "#1a1f2e")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Logo Header

struct FixrLogoHeader: View {
    var subtitle: String?

    var body: some View {
        VStack(spacing: 6) {
            Text("FIXR")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(.fixrText)
                .tracking(4)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.fixrCaption)
                    .foregroundColor(.fixrMuted)
            }
        }
    }
}

// MARK: - Buttons

struct FixrPrimaryButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    init(_ title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                        .font(.fixrButton)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [Color.fixrPrimary, Color.fixrPrimary.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Color.fixrPrimary.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .disabled(isLoading)
        .buttonStyle(.plain)
    }
}

struct FixrSecondaryButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.fixrButton)
                .foregroundColor(.fixrPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .overlay(
                    Capsule()
                        .stroke(Color.fixrPrimary, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }
}

struct FixrOrangeButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    init(_ title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                        .font(.fixrButton)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [Color.fixrOrange, Color.fixrOrange.opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
            .shadow(color: Color.fixrOrange.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .disabled(isLoading)
        .buttonStyle(.plain)
    }
}

// MARK: - Card

struct FixrCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(Color.fixrCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

// MARK: - Bullet

struct FixrBullet: View {
    let text: String
    var color: Color = .fixrPrimary

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            Text(text)
                .font(.fixrBody)
                .foregroundColor(.fixrText)
        }
    }
}

// MARK: - Back Button

struct FixrBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                Text("Back")
                    .font(.fixrBody)
            }
            .foregroundColor(.fixrMuted)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Badge

enum FixrBadgeStyle {
    case junior
    case senior
    case master
    case verified
    case custom(Color)

    var color: Color {
        switch self {
        case .junior: return Color(hex: "#22C55E")
        case .senior: return Color.fixrPrimary
        case .master: return Color.fixrOrange
        case .verified: return Color(hex: "#10B981")
        case .custom(let color): return color
        }
    }

    var label: String {
        switch self {
        case .junior: return "Junior"
        case .senior: return "Senior"
        case .master: return "Master"
        case .verified: return "Verified"
        case .custom: return ""
        }
    }
}

struct FixrBadge: View {
    let style: FixrBadgeStyle
    var text: String?

    var body: some View {
        Text(text ?? style.label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(style.color.opacity(0.2))
            .overlay(
                Capsule().stroke(style.color, lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}

// MARK: - View Modifiers

struct FixrTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.fixrTitle)
            .foregroundColor(.fixrText)
            .multilineTextAlignment(.center)
    }
}

struct FixrSubtitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.fixrBody)
            .foregroundColor(.fixrMuted)
            .multilineTextAlignment(.center)
    }
}

extension View {
    func fixrTitleStyle() -> some View {
        modifier(FixrTitleModifier())
    }

    func fixrSubtitleStyle() -> some View {
        modifier(FixrSubtitleModifier())
    }
}

// MARK: - Text Field Style

struct FixrTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.fixrBody)
            .foregroundColor(.fixrText)
            .padding(14)
            .background(Color.fixrCard)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Step Progress Bar

struct FixrStepProgress: View {
    let current: Int
    let total: Int
    var color: Color = .fixrPrimary

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.fixrCard)
                    .frame(height: 4)

                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: geo.size.width * progress, height: 4)
                    .animation(.easeInOut(duration: 0.3), value: current)
            }
        }
        .frame(height: 4)
    }

    private var progress: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(current) / CGFloat(total)
    }
}
