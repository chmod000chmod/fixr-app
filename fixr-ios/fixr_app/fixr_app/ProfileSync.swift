import Foundation
import SwiftData
import Supabase

/// Syncs the authenticated user's profile from Supabase into the local SwiftData store.
struct ProfileSync {

    @MainActor
    static func sync(
        context: ModelContext,
        supabase: SupabaseClient,
        userId: UUID,
        role: UserRole
    ) async throws {
        switch role {
        case .client:
            try await syncClientProfile(context: context, supabase: supabase, userId: userId)
        case .fixer:
            try await syncFixerProfile(context: context, supabase: supabase, userId: userId)
        }
    }

    @MainActor
    private static func syncClientProfile(
        context: ModelContext,
        supabase: SupabaseClient,
        userId: UUID
    ) async throws {
        struct ClientProfileRow: Decodable {
            let id: UUID
            let email: String
            let firstName: String
            let lastName: String
            let phone: String?
            let city: String?
            let province: String?
            let postalCode: String?
            let jobsPosted: Int?
            let isIdVerified: Bool?

            enum CodingKeys: String, CodingKey {
                case id
                case email
                case firstName = "first_name"
                case lastName = "last_name"
                case phone
                case city
                case province
                case postalCode = "postal_code"
                case jobsPosted = "jobs_posted"
                case isIdVerified = "is_id_verified"
            }
        }

        let row: ClientProfileRow = try await supabase
            .from("profiles")
            .select("id, email, first_name, last_name, phone, city, province, postal_code, jobs_posted, is_id_verified")
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

        upsertProfile(
            context: context,
            userId: userId,
            email: row.email,
            firstName: row.firstName,
            lastName: row.lastName,
            role: .client,
            phone: row.phone ?? "",
            city: row.city ?? "",
            province: row.province ?? "QC",
            postalCode: row.postalCode ?? "",
            jobsPosted: row.jobsPosted,
            isIdVerified: row.isIdVerified,
            rbqLicence: nil,
            isRbqVerified: nil,
            tradeSpecialties: nil,
            hourlyRate: nil,
            serviceRadiusKm: nil,
            certifiedHours: nil,
            experienceLevel: nil,
            isAvailable: nil
        )
    }

    @MainActor
    private static func syncFixerProfile(
        context: ModelContext,
        supabase: SupabaseClient,
        userId: UUID
    ) async throws {
        struct FixerProfileRow: Decodable {
            let id: UUID
            let email: String
            let firstName: String
            let lastName: String
            let phone: String?
            let city: String?
            let province: String?
            let postalCode: String?
            let isIdVerified: Bool?
            let rbqLicence: String?
            let tradeSpecialties: [String]?
            let isRbqVerified: Bool?
            let hourlyRate: Double?
            let serviceRadiusKm: Int?
            let certifiedHours: Double?
            let experienceLevel: String?
            let isAvailable: Bool?

            enum CodingKeys: String, CodingKey {
                case id
                case email
                case firstName = "first_name"
                case lastName = "last_name"
                case phone
                case city
                case province
                case postalCode = "postal_code"
                case isIdVerified = "is_id_verified"
                case rbqLicence = "rbq_licence"
                case tradeSpecialties = "trade_specialties"
                case isRbqVerified = "is_rbq_verified"
                case hourlyRate = "hourly_rate"
                case serviceRadiusKm = "service_radius_km"
                case certifiedHours = "certified_hours"
                case experienceLevel = "experience_level"
                case isAvailable = "is_available"
            }
        }

        let selectColumns = """
        id, email, first_name, last_name, phone, city, province, postal_code,
        is_id_verified, rbq_licence, trade_specialties, is_rbq_verified,
        hourly_rate, service_radius_km, certified_hours, experience_level, is_available
        """

        let row: FixerProfileRow = try await supabase
            .from("profiles")
            .select(selectColumns)
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

        upsertProfile(
            context: context,
            userId: userId,
            email: row.email,
            firstName: row.firstName,
            lastName: row.lastName,
            role: .fixer,
            phone: row.phone ?? "",
            city: row.city ?? "",
            province: row.province ?? "QC",
            postalCode: row.postalCode ?? "",
            jobsPosted: nil,
            isIdVerified: row.isIdVerified,
            rbqLicence: row.rbqLicence,
            isRbqVerified: row.isRbqVerified,
            tradeSpecialties: row.tradeSpecialties,
            hourlyRate: row.hourlyRate,
            serviceRadiusKm: row.serviceRadiusKm,
            certifiedHours: row.certifiedHours,
            experienceLevel: row.experienceLevel,
            isAvailable: row.isAvailable
        )
    }

    @MainActor
    private static func upsertProfile(
        context: ModelContext,
        userId: UUID,
        email: String,
        firstName: String,
        lastName: String,
        role: UserRole,
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
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate { $0.userId == userId }
        )
        let existing = try? context.fetch(descriptor)
        let profile = existing?.first ?? UserProfile(userId: userId, email: email, role: role.rawValue)

        if existing?.first == nil {
            context.insert(profile)
        }

        profile.applySupabase(
            userId: userId,
            email: email,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            city: city,
            province: province,
            postalCode: postalCode,
            jobsPosted: jobsPosted,
            isIdVerified: isIdVerified,
            rbqLicence: rbqLicence,
            isRbqVerified: isRbqVerified,
            tradeSpecialties: tradeSpecialties,
            hourlyRate: hourlyRate,
            serviceRadiusKm: serviceRadiusKm,
            certifiedHours: certifiedHours,
            experienceLevel: experienceLevel,
            isAvailable: isAvailable
        )

        try? context.save()
    }
}
