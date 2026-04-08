import SwiftUI

/// Quebec RBQ licence entry and verification block
/// Used in Fixer onboarding (OB-F5) and Fixer Profile (S14)
struct RBQLicenceView: View {
    @Binding var licenceNumber: String
    var verified: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RBQ Licence")
                .font(.fixrHeading)
                .foregroundColor(.fixrText)

            Text("Régie du bâtiment du Québec")
                .font(.fixrCaption)
                .foregroundColor(.fixrMuted)

            HStack {
                TextField("XXXX-XXXX-XX", text: $licenceNumber)
                    .font(.fixrBody)
                    .foregroundColor(.fixrText)
                    .keyboardType(.numbersAndPunctuation)

                if verified {
                    Label("Vérifié", systemImage: "checkmark.seal.fill")
                        .font(.fixrCaption)
                        .foregroundColor(.green)
                }
            }
            .padding(14)
            .background(Color.fixrCard)
            .cornerRadius(12)

            Text("Format: 1234-5678-01 · Category 3.1 — Plomberie-chauffage")
                .font(.fixrCaption)
                .foregroundColor(.fixrMuted)
        }
    }
}
