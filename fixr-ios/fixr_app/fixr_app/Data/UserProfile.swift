import Foundation
import SwiftData

@Model
final class UserProfile {
    // MARK: - Shared fields
    var userId: UUID?
    var email: String
    var firstName: String
    var lastName: String
    var role: String
    var phone: String
    var city: String
    var province: String
    var postalCode: String

    // MARK: - Client-only fields
    var jobsPosted: Int
    var isIdVerified: Bool

    // MARK: - Fixer-only fields
    var rbqLicence: String?
    var isRbqVerified: Bool
    var tradeSpecialties: [String]
    var hourlyRate: Double?
    var serviceRadiusKm: Int
    var certifiedHours: Double
    var experienceLevel: String?
    var isAvailable: Bool

    // MARK: - Onboarding tracking
    var onboardingCompletedAt: Date?

    init(
        userId: UUID? = nil,
        email: String = "",
        firstName: String = "",
        lastName: String = "",
        role: String = UserRole.client.rawValue,
        phone: String = "",
        city: String = "",
        province: String = "QC",
        postalCode: String = ""
    ) {
        self.userId = userId
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.phone = phone
        self.city = city
        self.province = province
        self.postalCode = postalCode
        self.jobsPosted = 0
        self.isIdVerified = false
        self.isRbqVerified = false
        self.tradeSpecialties = []
        self.serviceRadiusKm = 25
        self.certifiedHours = 0
        self.isAvailable = true
    }

    var userRole: UserRole {
        UserRole(rawValue: role) ?? .client
    }

    var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    var hasCompletedOnboarding: Bool {
        onboardingCompletedAt != nil
    }

    /// Applies data fetched from the Supabase `profiles` table.
    func applySupabase(
        userId: UUID?,
        email: String,
        firstName: String,
        lastName: String,
        phone: String,
        city: String,
        province: String,
        postalCode: String,
        jobsPosted: Int?,
        isIdVerified: Bool?,
        rbqLicence: String?,
        isRbqVerified: Bool?,
        tradeSpecialties: [String]?,
        hourlyRate: Double?,
        serviceRadiusKm: Int?,
        certifiedHours: Double?,
        experienceLevel: String?,
        isAvailable: Bool?
    ) {
        self.userId = userId
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.city = city
        self.province = province
        self.postalCode = postalCode
        self.jobsPosted = jobsPosted ?? 0
        self.isIdVerified = isIdVerified ?? false
        self.rbqLicence = rbqLicence
        self.isRbqVerified = isRbqVerified ?? false
        self.tradeSpecialties = tradeSpecialties ?? []
        self.hourlyRate = hourlyRate
        self.serviceRadiusKm = serviceRadiusKm ?? 25
        self.certifiedHours = certifiedHours ?? 0
        self.experienceLevel = experienceLevel
        self.isAvailable = isAvailable ?? true
    }
}
