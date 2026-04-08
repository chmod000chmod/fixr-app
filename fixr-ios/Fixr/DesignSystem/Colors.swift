import SwiftUI

extension Color {
    // Primary palette (from Figma V2 dark theme)
    static let fixrPrimary    = Color(hex: "#2563EB") // Blue
    static let fixrOrange     = Color(hex: "#F9730B") // Action / Fixer accent
    static let fixrBackground = Color(hex: "#0D0F14") // Dark navy
    static let fixrCard       = Color.white.opacity(0.06)
    static let fixrText       = Color(hex: "#FFFFFF")
    static let fixrMuted      = Color(hex: "#6B7280")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
