import SwiftUI

/// OB-0 — Role Selection (Client / Fixer)
/// Two states: client selected (blue) and fixer selected (orange)
struct RoleSelectionView: View {
    enum Role { case client, fixer }
    @State private var selectedRole: Role = .client
    var onContinue: (Role) -> Void

    var body: some View {
        ZStack {
            Color.fixrBackground.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("I am a...")
                    .font(.fixrTitle)
                    .foregroundColor(.fixrText)

                RoleCard(title: "Client", subtitle: "I need help at home", icon: "house.fill",
                         isSelected: selectedRole == .client, accentColor: .fixrPrimary) {
                    selectedRole = .client
                }

                RoleCard(title: "Fixer", subtitle: "I want to repair", icon: "wrench.and.screwdriver.fill",
                         isSelected: selectedRole == .fixer, accentColor: .fixrOrange) {
                    selectedRole = .fixer
                }

                Spacer()

                Button {
                    onContinue(selectedRole)
                } label: {
                    Text(selectedRole == .client ? "Continue as Client" : "Continue as Fixer")
                        .font(.fixrButton)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedRole == .client ? Color.fixrPrimary : Color.fixrOrange)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .padding(.top, 60)
        }
    }
}

private struct RoleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let accentColor: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? accentColor : .fixrMuted)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.fixrHeading).foregroundColor(.fixrText)
                    Text(subtitle).font(.fixrBody).foregroundColor(.fixrMuted)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(accentColor)
                }
            }
            .padding(20)
            .background(Color.fixrCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
    }
}
