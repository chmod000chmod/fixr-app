import Foundation

enum BidStatus: String, Codable {
    case pending
    case accepted
    case rejected

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .rejected: return "Rejected"
        }
    }
}

struct Bid: Codable, Identifiable {
    let id: UUID
    let jobId: UUID
    let fixerId: UUID
    let fixerName: String
    let fixerRating: Double?
    let fixerLevel: String
    let proposedPrice: Double
    let estimatedHours: Double?
    let message: String?
    let createdAt: Date
    let status: String

    var bidStatus: BidStatus {
        BidStatus(rawValue: status) ?? .pending
    }

    var formattedPrice: String {
        String(format: "$%.2f", proposedPrice)
    }

    var formattedRating: String {
        guard let rating = fixerRating else { return "No rating" }
        return String(format: "%.1f", rating)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case jobId = "job_id"
        case fixerId = "fixer_id"
        case fixerName = "fixer_name"
        case fixerRating = "fixer_rating"
        case fixerLevel = "fixer_level"
        case proposedPrice = "proposed_price"
        case estimatedHours = "estimated_hours"
        case message
        case createdAt = "created_at"
        case status
    }
}
