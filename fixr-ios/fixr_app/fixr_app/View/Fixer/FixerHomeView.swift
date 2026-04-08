import SwiftUI
import SwiftData
import Supabase

struct FixerHomeView: View {
    let profile: UserProfile

    @Environment(\.supabaseClient) private var supabase
    @Environment(\.modelContext) private var modelContext

    @State private var nearbyJobs: [CachedJob] = []
    @State private var isLoadingJobs = false
    @State private var totalEarned: Double = 0
    @State private var jobsCompleted: Int = 0
    @State private var isAvailable: Bool
    @State private var isUpdatingAvailability = false
    @State private var loadTask: Task<Void, Never>?
    @State private var availabilityTask: Task<Void, Never>?
    @State private var errorMessage: String?

    init(profile: UserProfile) {
        self.profile = profile
        _isAvailable = State(initialValue: profile.isAvailable)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fixrBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        fixerHeader
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .padding(.bottom, 20)

                        // Earnings card
                        earningsSummaryCard
                            .padding(.horizontal, 24)
                            .padding(.bottom, 16)

                        // Availability toggle
                        availabilityToggleCard
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)

                        // Nearby jobs
                        nearbyJobsSection
                            .padding(.horizontal, 24)
                    }
                }
                .refreshable { await loadData() }
            }
            .navigationBarHidden(true)
        }
        .task { await loadData() }
        .onDisappear {
            loadTask?.cancel()
            availabilityTask?.cancel()
        }
    }

    // MARK: - Subviews

    private var fixerHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hey,")
                    .font(.fixrBody)
                    .foregroundColor(.fixrMuted)
                HStack(spacing: 8) {
                    Text(profile.firstName.isEmpty ? "Fixer" : profile.firstName)
                        .font(.fixrTitle)
                        .foregroundColor(.fixrText)
                    if profile.isRbqVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.fixrOrange)
                    }
                }
            }
            Spacer()
            Button {
                // Notifications placeholder
            } label: {
                Image(systemName: "bell.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.fixrMuted)
            }
        }
    }

    private var earningsSummaryCard: some View {
        FixrCard {
            HStack(spacing: 0) {
                earningsMetric(
                    title: "Total Earned",
                    value: String(format: "$%.0f", totalEarned),
                    icon: "dollarsign.circle.fill",
                    color: Color(hex: "#22C55E")
                )

                Divider()
                    .background(Color.white.opacity(0.08))
                    .frame(height: 40)

                earningsMetric(
                    title: "Jobs Done",
                    value: "\(jobsCompleted)",
                    icon: "checkmark.circle.fill",
                    color: .fixrOrange
                )

                Divider()
                    .background(Color.white.opacity(0.08))
                    .frame(height: 40)

                earningsMetric(
                    title: "Hours Logged",
                    value: String(format: "%.0f", profile.certifiedHours),
                    icon: "clock.fill",
                    color: .fixrPrimary
                )
            }
            .padding(.vertical, 16)
        }
    }

    private func earningsMetric(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.fixrText)
            Text(title)
                .font(.fixrCaption)
                .foregroundColor(.fixrMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private var availabilityToggleCard: some View {
        FixrCard {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isAvailable ? Color(hex: "#22C55E").opacity(0.2) : Color.fixrCard)
                        .frame(width: 44, height: 44)
                    Circle()
                        .fill(isAvailable ? Color(hex: "#22C55E") : Color.fixrMuted)
                        .frame(width: 10, height: 10)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(isAvailable ? "Available for Jobs" : "Currently Unavailable")
                        .font(.fixrHeading)
                        .foregroundColor(.fixrText)
                    Text(isAvailable ? "You're visible to clients posting jobs" : "You won't appear in job searches")
                        .font(.fixrCaption)
                        .foregroundColor(.fixrMuted)
                }

                Spacer()

                Toggle("", isOn: $isAvailable)
                    .labelsHidden()
                    .tint(.fixrOrange)
                    .disabled(isUpdatingAvailability)
            }
            .padding(16)
        }
        .onChange(of: isAvailable) {
            updateAvailability(isAvailable)
        }
    }

    private var nearbyJobsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nearby Jobs")
                    .font(.fixrHeading)
                    .foregroundColor(.fixrText)
                Spacer()
                if isLoadingJobs {
                    ProgressView().tint(.fixrOrange).scaleEffect(0.7)
                }
            }

            if let error = errorMessage {
                Text(error)
                    .font(.fixrCaption)
                    .foregroundColor(.red)
            }

            if nearbyJobs.isEmpty && !isLoadingJobs {
                VStack(spacing: 12) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.fixrMuted)
                    Text("No jobs in your area right now")
                        .font(.fixrBody)
                        .foregroundColor(.fixrMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ForEach(nearbyJobs, id: \.jobId) { job in
                    fixerJobCard(job)
                }
            }
        }
        .padding(.bottom, 24)
    }

    private func fixerJobCard(_ job: CachedJob) -> some View {
        let isLocked = job.skillLevelRequired == SkillLevel.senior.rawValue
            && profile.experienceLevel == "junior"

        return FixrCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    if let trade = job.tradeCategory {
                        Label(trade.displayName, systemImage: trade.iconName)
                            .font(.fixrCaption)
                            .foregroundColor(isLocked ? .fixrMuted : .fixrOrange)
                    }
                    Spacer()

                    if isLocked {
                        Label("Senior Only", systemImage: "lock.fill")
                            .font(.fixrCaption)
                            .foregroundColor(.fixrMuted)
                    } else if let budget = job.estimatedBudget {
                        Text("~$\(Int(budget))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.fixrOrange)
                    }
                }

                Text(job.title)
                    .font(.fixrHeading)
                    .foregroundColor(isLocked ? .fixrMuted : .fixrText)

                Text(job.jobDescription)
                    .font(.fixrBody)
                    .foregroundColor(.fixrMuted)
                    .lineLimit(2)

                HStack {
                    Label("\(job.locationCity)", systemImage: "location.fill")
                        .font(.fixrCaption)
                        .foregroundColor(.fixrMuted)

                    Spacer()

                    FixrBadge(
                        style: job.skillLevelRequired == "senior" ? .senior : .junior,
                        text: job.skillLevelRequired == "any" ? "Any Level" : job.skillLevelRequired.capitalized
                    )
                }

                if !isLocked {
                    FixrOrangeButton("Submit Quote", action: {
                        // Navigate to bid submission — placeholder
                    })
                    .frame(height: 38)
                }
            }
            .padding(16)
            .opacity(isLocked ? 0.5 : 1.0)
        }
    }

    // MARK: - Data

    private func loadData() async {
        loadTask?.cancel()
        loadTask = Task { @MainActor in
            isLoadingJobs = true
            errorMessage = nil
            defer { isLoadingJobs = false }

            // Load from SwiftData first
            let descriptor = FetchDescriptor<CachedJob>(
                predicate: #Predicate { $0.status == "open" },
                sortBy: [SortDescriptor(\.postedAt, order: .reverse)]
            )
            nearbyJobs = (try? modelContext.fetch(descriptor)) ?? []

            // Sync from Supabase
            do {
                let rows: [JobRow] = try await supabase
                    .from("jobs")
                    .select()
                    .eq("status", value: JobStatus.open.rawValue)
                    .order("posted_at", ascending: false)
                    .limit(30)
                    .execute()
                    .value

                for row in rows {
                    let job = row.toCachedJob()
                    let existing = try? modelContext.fetch(
                        FetchDescriptor<CachedJob>(predicate: #Predicate { $0.jobId == job.jobId })
                    )
                    if existing?.first == nil {
                        modelContext.insert(job)
                    }
                }
                try? modelContext.save()
                nearbyJobs = (try? modelContext.fetch(descriptor)) ?? []
            } catch {
                errorMessage = nil // Non-fatal; show cached data
            }
        }
    }

    private func updateAvailability(_ available: Bool) {
        availabilityTask?.cancel()
        availabilityTask = Task { @MainActor in
            guard let userId = profile.userId else { return }
            isUpdatingAvailability = true
            defer { isUpdatingAvailability = false }

            struct AvailabilityUpdate: Encodable {
                let isAvailable: Bool
                enum CodingKeys: String, CodingKey {
                    case isAvailable = "is_available"
                }
            }

            do {
                try await supabase
                    .from("profiles")
                    .update(AvailabilityUpdate(isAvailable: available))
                    .eq("id", value: userId.uuidString)
                    .execute()

                profile.isAvailable = available
                try? modelContext.save()
            } catch {
                // Revert toggle on failure
                isAvailable = !available
                errorMessage = "Could not update availability."
            }
        }
    }
}
