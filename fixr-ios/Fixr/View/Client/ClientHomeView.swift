import SwiftUI
import SwiftData

struct ClientHomeView: View {
    let profile: UserProfile

    @Environment(\.supabaseClient) private var supabase
    @Environment(\.modelContext) private var modelContext

    @State private var selectedCategory: TradeCategory?
    @State private var recentJobs: [CachedJob] = []
    @State private var isLoadingJobs = false
    @State private var loadTask: Task<Void, Never>?
    @State private var showPostJob = false
    @State private var errorMessage: String?

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fixrBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        clientHeader
                            .padding(.top, 16)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 20)

                        // Post a job CTA banner
                        postJobBanner
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)

                        // Trade categories
                        tradeCategoriesSection
                            .padding(.bottom, 24)

                        // Recent jobs
                        recentJobsSection
                            .padding(.horizontal, 24)
                    }
                }
                .refreshable { await refreshJobs() }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showPostJob) {
            PostJobView(profile: profile)
        }
        .task {
            await loadJobs()
        }
        .onDisappear {
            loadTask?.cancel()
        }
    }

    // MARK: - Subviews

    private var clientHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(greeting),")
                    .font(.fixrBody)
                    .foregroundColor(.fixrMuted)
                Text(profile.firstName.isEmpty ? "there" : profile.firstName)
                    .font(.fixrTitle)
                    .foregroundColor(.fixrText)
            }
            Spacer()
            Button {
                // Notifications - placeholder
            } label: {
                Image(systemName: "bell.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.fixrMuted)
            }
        }
    }

    private var postJobBanner: some View {
        Button { showPostJob = true } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Need something fixed?")
                        .font(.fixrHeading)
                        .foregroundColor(.fixrText)
                    Text("Post a job and get quotes from verified Fixers")
                        .font(.fixrCaption)
                        .foregroundColor(.fixrText.opacity(0.7))
                }
                Spacer()
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color.fixrPrimary, Color.fixrPrimary.opacity(0.75)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.fixrPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }

    private var tradeCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Browse by Trade")
                .font(.fixrHeading)
                .foregroundColor(.fixrText)
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TradeCategory.allCases) { category in
                        tradeCategoryChip(category)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private func tradeCategoryChip(_ category: TradeCategory) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isSelected {
                    selectedCategory = nil
                } else {
                    selectedCategory = category
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: category.iconName)
                    .font(.system(size: 14))
                Text(category.displayName)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .fixrMuted)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Color.fixrPrimary : Color.fixrCard)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }

    private var recentJobsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Jobs")
                    .font(.fixrHeading)
                    .foregroundColor(.fixrText)
                Spacer()
                if !recentJobs.isEmpty {
                    Text("\(recentJobs.count) total")
                        .font(.fixrCaption)
                        .foregroundColor(.fixrMuted)
                }
            }

            if isLoadingJobs {
                ProgressView()
                    .tint(.fixrPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else if filteredJobs.isEmpty {
                emptyJobsView
            } else {
                ForEach(filteredJobs, id: \.jobId) { job in
                    clientJobCard(job)
                }
            }
        }
        .padding(.bottom, 24)
    }

    private var filteredJobs: [CachedJob] {
        guard let category = selectedCategory else { return recentJobs }
        return recentJobs.filter { $0.category == category.rawValue }
    }

    private var emptyJobsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 40))
                .foregroundColor(.fixrMuted)
            Text("No jobs posted yet")
                .font(.fixrBody)
                .foregroundColor(.fixrMuted)
            FixrPrimaryButton("Post Your First Job") {
                showPostJob = true
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private func clientJobCard(_ job: CachedJob) -> some View {
        FixrCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    if let trade = job.tradeCategory {
                        Label(trade.displayName, systemImage: trade.iconName)
                            .font(.fixrCaption)
                            .foregroundColor(.fixrPrimary)
                    }
                    Spacer()
                    Text(job.jobStatus.displayName)
                        .font(.fixrCaption)
                        .foregroundColor(statusColor(job.jobStatus))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(statusColor(job.jobStatus).opacity(0.15))
                        .cornerRadius(6)
                }

                Text(job.title)
                    .font(.fixrHeading)
                    .foregroundColor(.fixrText)

                Text(job.jobDescription)
                    .font(.fixrBody)
                    .foregroundColor(.fixrMuted)
                    .lineLimit(2)

                HStack {
                    Label("\(job.locationCity), \(job.locationProvince)", systemImage: "location.fill")
                        .font(.fixrCaption)
                        .foregroundColor(.fixrMuted)
                    Spacer()
                    if let budget = job.estimatedBudget {
                        Text("~$\(Int(budget))")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.fixrPrimary)
                    }
                }
            }
            .padding(16)
        }
    }

    private func statusColor(_ status: JobStatus) -> Color {
        switch status {
        case .open: return .fixrPrimary
        case .inProgress: return .fixrOrange
        case .completed: return Color(hex: "#22C55E")
        case .cancelled: return .fixrMuted
        }
    }

    // MARK: - Data Loading

    private func loadJobs() async {
        guard let userId = profile.userId else { return }
        loadTask?.cancel()
        loadTask = Task { @MainActor in
            isLoadingJobs = true
            defer { isLoadingJobs = false }

            let descriptor = FetchDescriptor<CachedJob>(
                predicate: #Predicate { $0.clientId == userId },
                sortBy: [SortDescriptor(\.postedAt, order: .reverse)]
            )
            recentJobs = (try? modelContext.fetch(descriptor)) ?? []

            // Also try to sync from Supabase
            do {
                let rows: [JobRow] = try await supabase
                    .from("jobs")
                    .select()
                    .eq("client_id", value: userId.uuidString)
                    .order("posted_at", ascending: false)
                    .limit(20)
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
                recentJobs = (try? modelContext.fetch(descriptor)) ?? []
            } catch {
                // Network errors are non-fatal; show cached data
            }
        }
    }

    private func refreshJobs() async {
        await loadJobs()
    }
}
