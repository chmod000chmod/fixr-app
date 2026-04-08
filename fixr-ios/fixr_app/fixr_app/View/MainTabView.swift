import SwiftUI

enum ClientTab: Int, CaseIterable {
    case home
    case postJob
    case myJobs
    case messages
    case profile

    var title: String {
        switch self {
        case .home: return "Home"
        case .postJob: return "Post Job"
        case .myJobs: return "My Jobs"
        case .messages: return "Messages"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .postJob: return "plus.circle.fill"
        case .myJobs: return "doc.text.fill"
        case .messages: return "bubble.left.and.bubble.right.fill"
        case .profile: return "person.fill"
        }
    }
}

enum FixerTab: Int, CaseIterable {
    case jobs
    case myBids
    case hours
    case messages
    case profile

    var title: String {
        switch self {
        case .jobs: return "Jobs"
        case .myBids: return "My Bids"
        case .hours: return "Hours"
        case .messages: return "Messages"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .jobs: return "briefcase.fill"
        case .myBids: return "list.bullet.rectangle.fill"
        case .hours: return "clock.fill"
        case .messages: return "bubble.left.and.bubble.right.fill"
        case .profile: return "person.fill"
        }
    }
}

struct MainTabView: View {
    let profile: UserProfile

    @State private var selectedClientTab: ClientTab = .home
    @State private var selectedFixerTab: FixerTab = .jobs

    var body: some View {
        switch profile.userRole {
        case .client:
            clientTabView
        case .fixer:
            fixerTabView
        }
    }

    private var clientTabView: some View {
        TabView(selection: $selectedClientTab) {
            ClientHomeView(profile: profile)
                .tabItem {
                    Label(ClientTab.home.title, systemImage: ClientTab.home.icon)
                }
                .tag(ClientTab.home)

            PostJobView(profile: profile)
                .tabItem {
                    Label(ClientTab.postJob.title, systemImage: ClientTab.postJob.icon)
                }
                .tag(ClientTab.postJob)

            MyJobsView(profile: profile)
                .tabItem {
                    Label(ClientTab.myJobs.title, systemImage: ClientTab.myJobs.icon)
                }
                .tag(ClientTab.myJobs)

            MessagesView()
                .tabItem {
                    Label(ClientTab.messages.title, systemImage: ClientTab.messages.icon)
                }
                .tag(ClientTab.messages)

            SettingsView(profile: profile)
                .tabItem {
                    Label(ClientTab.profile.title, systemImage: ClientTab.profile.icon)
                }
                .tag(ClientTab.profile)
        }
        .tint(.fixrPrimary)
    }

    private var fixerTabView: some View {
        TabView(selection: $selectedFixerTab) {
            FixerHomeView(profile: profile)
                .tabItem {
                    Label(FixerTab.jobs.title, systemImage: FixerTab.jobs.icon)
                }
                .tag(FixerTab.jobs)

            MyBidsView(profile: profile)
                .tabItem {
                    Label(FixerTab.myBids.title, systemImage: FixerTab.myBids.icon)
                }
                .tag(FixerTab.myBids)

            HoursTrackerView(profile: profile)
                .tabItem {
                    Label(FixerTab.hours.title, systemImage: FixerTab.hours.icon)
                }
                .tag(FixerTab.hours)

            MessagesView()
                .tabItem {
                    Label(FixerTab.messages.title, systemImage: FixerTab.messages.icon)
                }
                .tag(FixerTab.messages)

            SettingsView(profile: profile)
                .tabItem {
                    Label(FixerTab.profile.title, systemImage: FixerTab.profile.icon)
                }
                .tag(FixerTab.profile)
        }
        .tint(.fixrOrange)
    }
}

// MARK: - Placeholder: My Jobs for Client

private struct MyJobsView: View {
    let profile: UserProfile
    @Environment(\.modelContext) private var modelContext
    @State private var jobs: [CachedJob] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fixrBackground.ignoresSafeArea()

                if jobs.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(.fixrMuted)
                        Text("No jobs posted yet")
                            .font(.fixrHeading)
                            .foregroundColor(.fixrMuted)
                    }
                } else {
                    List(jobs, id: \.jobId) { job in
                        JobRowView(job: job)
                            .listRowBackground(Color.fixrCard)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("My Jobs")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear { loadJobs() }
    }

    private func loadJobs() {
        guard let userId = profile.userId else { return }
        let descriptor = FetchDescriptor<CachedJob>(
            predicate: #Predicate { $0.clientId == userId },
            sortBy: [SortDescriptor(\.postedAt, order: .reverse)]
        )
        jobs = (try? modelContext.fetch(descriptor)) ?? []
    }
}

// MARK: - Placeholder: My Bids for Fixer

private struct MyBidsView: View {
    let profile: UserProfile

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fixrBackground.ignoresSafeArea()

                VStack(spacing: 16) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 48))
                        .foregroundColor(.fixrMuted)
                    Text("No active bids")
                        .font(.fixrHeading)
                        .foregroundColor(.fixrMuted)
                    Text("Jobs you bid on will appear here")
                        .font(.fixrBody)
                        .foregroundColor(.fixrMuted)
                }
            }
            .navigationTitle("My Bids")
        }
    }
}

// MARK: - Job Row

struct JobRowView: View {
    let job: CachedJob

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(job.title)
                    .font(.fixrHeading)
                    .foregroundColor(.fixrText)
                Spacer()
                Text(job.jobStatus.displayName)
                    .font(.fixrCaption)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.15))
                    .cornerRadius(6)
            }

            Text(job.locationCity + ", " + job.locationProvince)
                .font(.fixrCaption)
                .foregroundColor(.fixrMuted)

            if let budget = job.estimatedBudget {
                Text("Budget: $\(Int(budget))")
                    .font(.fixrCaption)
                    .foregroundColor(.fixrPrimary)
            }
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch job.jobStatus {
        case .open: return .fixrPrimary
        case .inProgress: return .fixrOrange
        case .completed: return Color(hex: "#22C55E")
        case .cancelled: return .fixrMuted
        }
    }
}
