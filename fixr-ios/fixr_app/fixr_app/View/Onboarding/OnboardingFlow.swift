import SwiftUI

// MARK: - Onboarding Steps

enum ClientOnboardingStep: Int, CaseIterable {
    case roleSelect
    case accountSetup
    case personalInfo
    case idUpload
    case review
    case pending

    var title: String {
        switch self {
        case .roleSelect: return "Choose Your Role"
        case .accountSetup: return "Create Account"
        case .personalInfo: return "Personal Info"
        case .idUpload: return "ID Verification"
        case .review: return "Review"
        case .pending: return "Under Review"
        }
    }
}

enum FixerOnboardingStep: Int, CaseIterable {
    case roleSelect
    case accountSetup
    case tradeSelection
    case experience
    case idUpload
    case licenceEntry
    case review
    case pending

    var title: String {
        switch self {
        case .roleSelect: return "Choose Your Role"
        case .accountSetup: return "Create Account"
        case .tradeSelection: return "Trade Specialties"
        case .experience: return "Experience"
        case .idUpload: return "ID Verification"
        case .licenceEntry: return "RBQ Licence"
        case .review: return "Review"
        case .pending: return "Under Review"
        }
    }
}

// MARK: - Onboarding State (UserDefaults)

final class OnboardingState {
    private static let completedKey = "fixr_onboarding_completed"
    private static let stepKey = "fixr_onboarding_step"
    private static let roleKey = "fixr_onboarding_role"

    static func isCompleted(for userId: UUID) -> Bool {
        UserDefaults.standard.bool(forKey: "\(completedKey)_\(userId.uuidString)")
    }

    static func markCompleted(for userId: UUID) {
        UserDefaults.standard.set(true, forKey: "\(completedKey)_\(userId.uuidString)")
    }

    static func savedStep(for userId: UUID) -> Int {
        UserDefaults.standard.integer(forKey: "\(stepKey)_\(userId.uuidString)")
    }

    static func saveStep(_ step: Int, for userId: UUID) {
        UserDefaults.standard.set(step, forKey: "\(stepKey)_\(userId.uuidString)")
    }

    static func savedRole(for userId: UUID) -> UserRole? {
        guard let raw = UserDefaults.standard.string(forKey: "\(roleKey)_\(userId.uuidString)") else {
            return nil
        }
        return UserRole(rawValue: raw)
    }

    static func saveRole(_ role: UserRole, for userId: UUID) {
        UserDefaults.standard.set(role.rawValue, forKey: "\(roleKey)_\(userId.uuidString)")
    }
}

// MARK: - Onboarding Flow Container

struct OnboardingFlow: View {
    let role: UserRole
    var onFinish: () -> Void
    var onSignIn: () -> Void

    @Environment(\.supabaseClient) private var supabase
    @Environment(\.modelContext) private var modelContext

    @State private var clientStep: ClientOnboardingStep = .roleSelect
    @State private var fixerStep: FixerOnboardingStep = .roleSelect

    // Shared state passed down to steps
    @State private var onboardingData = OnboardingData()

    var body: some View {
        ZStack {
            FixrGradientBackground()

            switch role {
            case .client:
                clientFlow
            case .fixer:
                fixerFlow
            }
        }
        .animation(.easeInOut(duration: 0.3), value: clientStep)
        .animation(.easeInOut(duration: 0.3), value: fixerStep)
    }

    // MARK: - Client Flow

    @ViewBuilder
    private var clientFlow: some View {
        VStack(spacing: 0) {
            if clientStep != .roleSelect && clientStep != .pending {
                progressHeader(
                    current: clientStep.rawValue,
                    total: ClientOnboardingStep.allCases.count - 2,
                    title: clientStep.title,
                    color: .fixrPrimary
                )
            }

            switch clientStep {
            case .roleSelect:
                RoleSelectionView(onContinue: { _ in
                    advance(clientStep: .accountSetup)
                })
            case .accountSetup:
                ClientAccountSetupStep(
                    data: $onboardingData,
                    onBack: { advance(clientStep: .roleSelect) },
                    onNext: { advance(clientStep: .personalInfo) }
                )
            case .personalInfo:
                ClientPersonalInfoStep(
                    data: $onboardingData,
                    onBack: { advance(clientStep: .accountSetup) },
                    onNext: { advance(clientStep: .idUpload) }
                )
            case .idUpload:
                ClientIDUploadStep(
                    data: $onboardingData,
                    onBack: { advance(clientStep: .personalInfo) },
                    onNext: { advance(clientStep: .review) }
                )
            case .review:
                ClientReviewStep(
                    data: $onboardingData,
                    onEdit: { advance(clientStep: .accountSetup) },
                    onSubmit: { advance(clientStep: .pending) }
                )
            case .pending:
                ClientPendingStep(onFinish: onFinish)
            }
        }
    }

    // MARK: - Fixer Flow

    @ViewBuilder
    private var fixerFlow: some View {
        VStack(spacing: 0) {
            if fixerStep != .roleSelect && fixerStep != .pending {
                progressHeader(
                    current: fixerStep.rawValue,
                    total: FixerOnboardingStep.allCases.count - 2,
                    title: fixerStep.title,
                    color: .fixrOrange
                )
            }

            switch fixerStep {
            case .roleSelect:
                RoleSelectionView(onContinue: { _ in
                    advance(fixerStep: .accountSetup)
                })
            case .accountSetup:
                FixerAccountSetupStep(
                    data: $onboardingData,
                    onBack: { advance(fixerStep: .roleSelect) },
                    onNext: { advance(fixerStep: .tradeSelection) }
                )
            case .tradeSelection:
                FixerTradeSelectionStep(
                    data: $onboardingData,
                    onBack: { advance(fixerStep: .accountSetup) },
                    onNext: { advance(fixerStep: .experience) }
                )
            case .experience:
                FixerExperienceStep(
                    data: $onboardingData,
                    onBack: { advance(fixerStep: .tradeSelection) },
                    onNext: { advance(fixerStep: .idUpload) }
                )
            case .idUpload:
                ClientIDUploadStep(
                    data: $onboardingData,
                    onBack: { advance(fixerStep: .experience) },
                    onNext: { advance(fixerStep: .licenceEntry) }
                )
            case .licenceEntry:
                FixerLicenceStep(
                    data: $onboardingData,
                    onBack: { advance(fixerStep: .idUpload) },
                    onNext: { advance(fixerStep: .review) }
                )
            case .review:
                FixerReviewStep(
                    data: $onboardingData,
                    onEdit: { advance(fixerStep: .accountSetup) },
                    onSubmit: { advance(fixerStep: .pending) }
                )
            case .pending:
                FixerPendingStep(onFinish: onFinish)
            }
        }
    }

    private func progressHeader(current: Int, total: Int, title: String, color: Color) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("Step \(current) of \(total)")
                    .font(.fixrCaption)
                    .foregroundColor(.fixrMuted)
                Spacer()
                Text(title)
                    .font(.fixrCaption)
                    .foregroundColor(color)
            }
            .padding(.horizontal, 24)

            FixrStepProgress(current: current, total: total, color: color)
                .padding(.horizontal, 24)
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private func advance(clientStep: ClientOnboardingStep) {
        self.clientStep = clientStep
    }

    private func advance(fixerStep: FixerOnboardingStep) {
        self.fixerStep = fixerStep
    }
}

// MARK: - Shared Onboarding Data

final class OnboardingData: ObservableObject {
    // Account
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var phone = ""

    // Personal
    @Published var dateOfBirth: Date = Calendar.current.date(
        byAdding: .year, value: -25, to: Date()) ?? Date()
    @Published var address = ""
    @Published var city = ""
    @Published var province = "QC"
    @Published var postalCode = ""

    // ID
    @Published var idFrontImageData: Data?
    @Published var idBackImageData: Data?

    // Fixer
    @Published var selectedTrades: Set<TradeCategory> = []
    @Published var experienceLevel = "junior"
    @Published var certifications = ""
    @Published var rbqLicence = ""
    @Published var hasNoRbqLicence = false
    @Published var serviceRadiusKm = 25
    @Published var hasInsurance = false

    var isOf18: Bool {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return (ageComponents.year ?? 0) >= 18
    }
}
