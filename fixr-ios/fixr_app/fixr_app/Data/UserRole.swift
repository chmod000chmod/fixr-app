import SwiftUI

enum UserRole: String, Codable, CaseIterable {
    case client
    case fixer

    var displayName: String {
        switch self {
        case .client: return "Client"
        case .fixer: return "Fixer"
        }
    }

    var accentColor: Color {
        switch self {
        case .client: return .fixrPrimary
        case .fixer: return .fixrOrange
        }
    }

    var tabHomeIcon: String {
        switch self {
        case .client: return "house.fill"
        case .fixer: return "briefcase.fill"
        }
    }

    var tabJobsIcon: String {
        switch self {
        case .client: return "doc.text.fill"
        case .fixer: return "list.bullet.rectangle.fill"
        }
    }

    var tabMessagesIcon: String {
        return "bubble.left.and.bubble.right.fill"
    }

    var tabProfileIcon: String {
        return "person.fill"
    }
}
