import Foundation

enum TradeCategory: String, CaseIterable, Identifiable {
    case plumbing
    case electrical
    case carpentry
    case hvac
    case painting
    case windows
    case general

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .plumbing: return "Plumbing"
        case .electrical: return "Electrical"
        case .carpentry: return "Carpentry"
        case .hvac: return "HVAC"
        case .painting: return "Painting"
        case .windows: return "Windows"
        case .general: return "General Repairs"
        }
    }

    var iconName: String {
        switch self {
        case .plumbing: return "drop.fill"
        case .electrical: return "bolt.fill"
        case .carpentry: return "hammer.fill"
        case .hvac: return "wind"
        case .painting: return "paintbrush.fill"
        case .windows: return "square.grid.2x2.fill"
        case .general: return "wrench.and.screwdriver.fill"
        }
    }

    var description: String {
        switch self {
        case .plumbing:
            return "Pipes, drains, water heaters, and bathroom fixtures"
        case .electrical:
            return "Wiring, panels, outlets, and lighting installation"
        case .carpentry:
            return "Framing, trim, doors, cabinets, and custom woodwork"
        case .hvac:
            return "Heating, ventilation, air conditioning, and ductwork"
        case .painting:
            return "Interior and exterior painting, staining, and finishing"
        case .windows:
            return "Window installation, replacement, and repair"
        case .general:
            return "Handyman tasks, minor repairs, and home maintenance"
        }
    }
}
