import Foundation
import SwiftData

enum JobStatus: String, Codable, CaseIterable {
    case open
    case inProgress = "in_progress"
    case completed
    case cancelled

    var displayName: String {
        switch self {
        case .open: return "Open"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}

enum SkillLevel: String, Codable, CaseIterable {
    case junior
    case senior
    case any

    var displayName: String {
        switch self {
        case .junior: return "Junior"
        case .senior: return "Senior"
        case .any: return "Any Level"
        }
    }
}

@Model
final class CachedJob {
    var jobId: UUID
    var title: String
    var jobDescription: String
    var category: String
    var photoURL: String?
    var locationCity: String
    var locationProvince: String
    var skillLevelRequired: String
    var status: String
    var clientId: UUID
    var postedAt: Date
    var estimatedBudget: Double?

    init(
        jobId: UUID = UUID(),
        title: String,
        jobDescription: String,
        category: String,
        photoURL: String? = nil,
        locationCity: String,
        locationProvince: String = "QC",
        skillLevelRequired: String = SkillLevel.any.rawValue,
        status: String = JobStatus.open.rawValue,
        clientId: UUID,
        postedAt: Date = Date(),
        estimatedBudget: Double? = nil
    ) {
        self.jobId = jobId
        self.title = title
        self.jobDescription = jobDescription
        self.category = category
        self.photoURL = photoURL
        self.locationCity = locationCity
        self.locationProvince = locationProvince
        self.skillLevelRequired = skillLevelRequired
        self.status = status
        self.clientId = clientId
        self.postedAt = postedAt
        self.estimatedBudget = estimatedBudget
    }

    var jobStatus: JobStatus {
        JobStatus(rawValue: status) ?? .open
    }

    var tradeCategory: TradeCategory? {
        TradeCategory(rawValue: category)
    }
}

/// Decodable struct for reading jobs from Supabase
struct JobRow: Decodable {
    let id: UUID
    let title: String
    let description: String
    let category: String
    let photoURL: String?
    let locationCity: String
    let locationProvince: String
    let skillLevelRequired: String
    let status: String
    let clientId: UUID
    let postedAt: Date
    let estimatedBudget: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case category
        case photoURL = "photo_url"
        case locationCity = "location_city"
        case locationProvince = "location_province"
        case skillLevelRequired = "skill_level_required"
        case status
        case clientId = "client_id"
        case postedAt = "posted_at"
        case estimatedBudget = "estimated_budget"
    }

    func toCachedJob() -> CachedJob {
        CachedJob(
            jobId: id,
            title: title,
            jobDescription: description,
            category: category,
            photoURL: photoURL,
            locationCity: locationCity,
            locationProvince: locationProvince,
            skillLevelRequired: skillLevelRequired,
            status: status,
            clientId: clientId,
            postedAt: postedAt,
            estimatedBudget: estimatedBudget
        )
    }
}
