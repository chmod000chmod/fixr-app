import SwiftUI
import Supabase

struct HoursTrackerView: View {
    let profile: UserProfile

    @Environment(\.supabaseClient) private var supabase
    @State private var showLogHours = false
    @State private var recentLogs: [HoursLog] = []
    @State private var isLoading = false
    @State private var loadTask: Task<Void, Never>?

    // Level thresholds in hours
    private let apprenticeToJunior: Double = 500
    private let juniorToSenior: Double = 2000
    private let seniorToMaster: Double = 5000

    struct HoursLog: Identifiable {
        let id = UUID()
        let tradeCategory: String
        let hours: Double
        let date: Date
        let notes: String?
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fixrBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Overall progress header
                        certificationHeader
                            .padding(.horizontal, 24)
                            .padding(.top, 16)

                        // Current level card
                        currentLevelCard
                            .padding(.horizontal, 24)

                        // Per-trade progress
                        perTradeSection
                            .padding(.horizontal, 24)

                        // Recent logs
                        recentLogsSection
                            .padding(.horizontal, 24)

                        Spacer().frame(height: 20)
                    }
                }
            }
            .navigationTitle("Hours Tracker")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showLogHours = true
                    } label: {
                        Label("Log Hours", systemImage: "plus.circle.fill")
                            .foregroundColor(.fixrOrange)
                    }
                }
            }
        }
        .sheet(isPresented: $showLogHours) {
            LogHoursSheet(profile: profile, onSave: { _ in
                showLogHours = false
            })
        }
        .onDisappear { loadTask?.cancel() }
    }

    // MARK: - Subviews

    private var certificationHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Certified Hours")
                        .font(.fixrCaption)
                        .foregroundColor(.fixrMuted)
                    Text(String(format: "%.0f hrs", profile.certifiedHours))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.fixrText)
                }
                Spacer()
                if profile.certifiedHours > 0 {
                    FixrBadge(style: .verified, text: "Verified")
                }
            }

            Text(nextLevelDescription)
                .font(.fixrBody)
                .foregroundColor(.fixrMuted)
        }
    }

    private var currentLevelCard: some View {
        FixrCard {
            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Level")
                            .font(.fixrCaption)
                            .foregroundColor(.fixrMuted)
                        Text(currentLevelName)
                            .font(.fixrHeading)
                            .foregroundColor(.fixrText)
                    }
                    Spacer()
                    FixrBadge(style: currentBadgeStyle, text: currentLevelName)
                }

                // Progress to next level
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Progress to \(nextLevelName)")
                            .font(.fixrCaption)
                            .foregroundColor(.fixrMuted)
                        Spacer()
                        Text(String(format: "%.0f / %.0f hrs", profile.certifiedHours, nextLevelThreshold))
                            .font(.fixrCaption)
                            .foregroundColor(.fixrOrange)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.fixrCard).frame(height: 8)
                            Capsule().fill(Color.fixrOrange)
                                .frame(width: geo.size.width * progressToNextLevel, height: 8)
                                .animation(.easeInOut(duration: 0.5), value: profile.certifiedHours)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(16)
        }
    }

    private var perTradeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Trade")
                .font(.fixrHeading)
                .foregroundColor(.fixrText)

            if profile.tradeSpecialties.isEmpty {
                Text("No trade specialties added yet")
                    .font(.fixrBody)
                    .foregroundColor(.fixrMuted)
            } else {
                ForEach(profile.tradeSpecialties, id: \.self) { tradeRaw in
                    if let trade = TradeCategory(rawValue: tradeRaw) {
                        tradeProgressRow(trade)
                    }
                }
            }
        }
    }

    private func tradeProgressRow(_ trade: TradeCategory) -> some View {
        FixrCard {
            HStack(spacing: 14) {
                Image(systemName: trade.iconName)
                    .font(.system(size: 22))
                    .foregroundColor(.fixrOrange)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 6) {
                    Text(trade.displayName)
                        .font(.fixrBody)
                        .foregroundColor(.fixrText)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.fixrCard).frame(height: 4)
                            Capsule().fill(Color.fixrOrange)
                                .frame(width: geo.size.width * min(profile.certifiedHours / nextLevelThreshold, 1.0), height: 4)
                        }
                    }
                    .frame(height: 4)
                }

                Text(String(format: "%.0f hrs", profile.certifiedHours))
                    .font(.fixrCaption)
                    .foregroundColor(.fixrMuted)
                    .frame(width: 56, alignment: .trailing)
            }
            .padding(14)
        }
    }

    private var recentLogsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.fixrHeading)
                .foregroundColor(.fixrText)

            if recentLogs.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 32))
                        .foregroundColor(.fixrMuted)
                    Text("No hours logged yet")
                        .font(.fixrBody)
                        .foregroundColor(.fixrMuted)
                    Text("Tap + to log your first work session")
                        .font(.fixrCaption)
                        .foregroundColor(.fixrMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ForEach(recentLogs) { log in
                    logRow(log)
                }
            }
        }
    }

    private func logRow(_ log: HoursLog) -> some View {
        FixrCard {
            HStack(spacing: 12) {
                if let trade = TradeCategory(rawValue: log.tradeCategory) {
                    Image(systemName: trade.iconName)
                        .font(.system(size: 18))
                        .foregroundColor(.fixrOrange)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(TradeCategory(rawValue: log.tradeCategory)?.displayName ?? log.tradeCategory.capitalized)
                        .font(.fixrBody)
                        .foregroundColor(.fixrText)
                    if let notes = log.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.fixrCaption)
                            .foregroundColor(.fixrMuted)
                            .lineLimit(1)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1f hrs", log.hours))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.fixrText)
                    Text(log.date, style: .date)
                        .font(.fixrCaption)
                        .foregroundColor(.fixrMuted)
                }
            }
            .padding(14)
        }
    }

    // MARK: - Computed Properties

    private var currentLevelName: String {
        switch profile.certifiedHours {
        case ..<apprenticeToJunior: return "Apprentice"
        case ..<juniorToSenior: return "Junior"
        case ..<seniorToMaster: return "Senior"
        default: return "Master"
        }
    }

    private var nextLevelName: String {
        switch profile.certifiedHours {
        case ..<apprenticeToJunior: return "Junior"
        case ..<juniorToSenior: return "Senior"
        case ..<seniorToMaster: return "Master"
        default: return "Master"
        }
    }

    private var nextLevelThreshold: Double {
        switch profile.certifiedHours {
        case ..<apprenticeToJunior: return apprenticeToJunior
        case ..<juniorToSenior: return juniorToSenior
        case ..<seniorToMaster: return seniorToMaster
        default: return seniorToMaster
        }
    }

    private var progressToNextLevel: CGFloat {
        let lower: Double = {
            switch profile.certifiedHours {
            case ..<apprenticeToJunior: return 0
            case ..<juniorToSenior: return apprenticeToJunior
            case ..<seniorToMaster: return juniorToSenior
            default: return seniorToMaster
            }
        }()
        let range = nextLevelThreshold - lower
        guard range > 0 else { return 1.0 }
        return CGFloat(min((profile.certifiedHours - lower) / range, 1.0))
    }

    private var currentBadgeStyle: FixrBadgeStyle {
        switch currentLevelName {
        case "Junior": return .junior
        case "Senior": return .senior
        case "Master": return .master
        default: return .junior
        }
    }

    private var nextLevelDescription: String {
        let hoursNeeded = max(0, nextLevelThreshold - profile.certifiedHours)
        if hoursNeeded <= 0 { return "You've reached Master level!" }
        return String(format: "%.0f more hours to reach \(nextLevelName)", hoursNeeded)
    }
}

// MARK: - Log Hours Sheet

struct LogHoursSheet: View {
    let profile: UserProfile
    var onSave: (Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTrade: TradeCategory = .general
    @State private var hoursText = ""
    @State private var notes = ""
    @State private var date = Date()
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                FixrGradientBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Trade")
                                .font(.fixrCaption)
                                .foregroundColor(.fixrMuted)
                            Picker("Trade", selection: $selectedTrade) {
                                ForEach(TradeCategory.allCases) { t in
                                    Text(t.displayName).tag(t)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.fixrOrange)
                            .padding(14)
                            .background(Color.fixrCard)
                            .cornerRadius(12)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Hours Worked")
                                .font(.fixrCaption)
                                .foregroundColor(.fixrMuted)
                            TextField("e.g. 4.5", text: $hoursText)
                                .textFieldStyle(FixrTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Date")
                                .font(.fixrCaption)
                                .foregroundColor(.fixrMuted)
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(.fixrOrange)
                                .padding(14)
                                .background(Color.fixrCard)
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Notes (optional)")
                                .font(.fixrCaption)
                                .foregroundColor(.fixrMuted)
                            TextField("What did you work on?", text: $notes)
                                .textFieldStyle(FixrTextFieldStyle())
                        }

                        FixrOrangeButton("Save Hours", isLoading: isSaving) {
                            if let hours = Double(hoursText), hours > 0 {
                                onSave(hours)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Log Hours")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.fixrMuted)
                }
            }
        }
    }
}
