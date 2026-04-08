import SwiftUI
import Supabase

struct QuotesView: View {
    let job: CachedJob

    @Environment(\.supabaseClient) private var supabase
    @State private var bids: [Bid] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var loadTask: Task<Void, Never>?
    @State private var actionTask: Task<Void, Never>?
    @State private var selectedBidId: UUID?
    @State private var showAcceptConfirm = false
    @State private var showRejectConfirm = false
    @State private var pendingBid: Bid?

    var body: some View {
        ZStack {
            Color.fixrBackground.ignoresSafeArea()

            if isLoading {
                ProgressView().tint(.fixrPrimary)
            } else if bids.isEmpty {
                emptyView
            } else {
                ScrollView {
                    VStack(spacing: 14) {
                        jobSummaryHeader
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                        if let error = errorMessage {
                            Text(error)
                                .font(.fixrCaption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }

                        ForEach(bids) { bid in
                            bidCard(bid)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .refreshable { await loadBids() }
            }
        }
        .navigationTitle("Quotes (\(bids.count))")
        .navigationBarTitleDisplayMode(.large)
        .task { await loadBids() }
        .onDisappear {
            loadTask?.cancel()
            actionTask?.cancel()
        }
        .confirmationDialog(
            "Accept this quote?",
            isPresented: $showAcceptConfirm,
            titleVisibility: .visible
        ) {
            Button("Accept Quote") {
                if let bid = pendingBid { acceptBid(bid) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let bid = pendingBid {
                Text("Accept \(bid.fixerName)'s quote of \(bid.formattedPrice)?")
            }
        }
        .confirmationDialog(
            "Reject this quote?",
            isPresented: $showRejectConfirm,
            titleVisibility: .visible
        ) {
            Button("Reject", role: .destructive) {
                if let bid = pendingBid { rejectBid(bid) }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Subviews

    private var jobSummaryHeader: some View {
        FixrCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if let trade = job.tradeCategory {
                        Label(trade.displayName, systemImage: trade.iconName)
                            .font(.fixrCaption)
                            .foregroundColor(.fixrPrimary)
                    }
                    Spacer()
                    Text(job.jobStatus.displayName)
                        .font(.fixrCaption)
                        .foregroundColor(.fixrMuted)
                }
                Text(job.title)
                    .font(.fixrHeading)
                    .foregroundColor(.fixrText)
                Label("\(job.locationCity), \(job.locationProvince)", systemImage: "location.fill")
                    .font(.fixrCaption)
                    .foregroundColor(.fixrMuted)
            }
            .padding(16)
        }
    }

    private func bidCard(_ bid: Bid) -> some View {
        FixrCard {
            VStack(spacing: 14) {
                // Fixer info
                HStack(spacing: 12) {
                    // Avatar initials
                    Circle()
                        .fill(Color.fixrPrimary.opacity(0.2))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(initials(bid.fixerName))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.fixrPrimary)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(bid.fixerName)
                            .font(.fixrHeading)
                            .foregroundColor(.fixrText)

                        HStack(spacing: 8) {
                            // Rating
                            if let rating = bid.fixerRating {
                                HStack(spacing: 3) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color(hex: "#FBBF24"))
                                    Text(String(format: "%.1f", rating))
                                        .font(.fixrCaption)
                                        .foregroundColor(.fixrMuted)
                                }
                            }

                            // Level badge
                            FixrBadge(
                                style: levelBadgeStyle(bid.fixerLevel),
                                text: bid.fixerLevel.capitalized
                            )
                        }
                    }

                    Spacer()

                    // Status badge
                    bidStatusBadge(bid.bidStatus)
                }

                Divider().background(Color.white.opacity(0.06))

                // Price and hours
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Proposed Price")
                            .font(.fixrCaption)
                            .foregroundColor(.fixrMuted)
                        Text(bid.formattedPrice)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.fixrPrimary)
                    }

                    Spacer()

                    if let hours = bid.estimatedHours {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Est. Time")
                                .font(.fixrCaption)
                                .foregroundColor(.fixrMuted)
                            Text(String(format: "%.1f hrs", hours))
                                .font(.fixrBody)
                                .foregroundColor(.fixrText)
                        }
                    }
                }

                // Message
                if let message = bid.message, !message.isEmpty {
                    Text(message)
                        .font(.fixrBody)
                        .foregroundColor(.fixrMuted)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Action buttons (only for pending bids)
                if bid.bidStatus == .pending {
                    HStack(spacing: 12) {
                        Button {
                            pendingBid = bid
                            showRejectConfirm = true
                        } label: {
                            Text("Decline")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)

                        Button {
                            pendingBid = bid
                            showAcceptConfirm = true
                        } label: {
                            Text("Accept")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(Color.fixrPrimary)
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.fixrMuted)
            Text("No quotes yet")
                .font(.fixrHeading)
                .foregroundColor(.fixrText)
            Text("Fixers will submit quotes here once they see your job")
                .font(.fixrBody)
                .foregroundColor(.fixrMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Helpers

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return letters.map(String.init).joined().uppercased()
    }

    private func levelBadgeStyle(_ level: String) -> FixrBadgeStyle {
        switch level.lowercased() {
        case "junior": return .junior
        case "senior": return .senior
        case "master": return .master
        default: return .junior
        }
    }

    private func bidStatusBadge(_ status: BidStatus) -> some View {
        let (color, label): (Color, String) = {
            switch status {
            case .pending: return (.fixrMuted, "Pending")
            case .accepted: return (Color(hex: "#22C55E"), "Accepted")
            case .rejected: return (.red, "Declined")
            }
        }()

        return Text(label)
            .font(.fixrCaption)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.1))
            .cornerRadius(6)
    }

    // MARK: - Data

    private func loadBids() async {
        loadTask?.cancel()
        loadTask = Task { @MainActor in
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            do {
                let fetched: [Bid] = try await supabase
                    .from("bids")
                    .select()
                    .eq("job_id", value: job.jobId.uuidString)
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                bids = fetched
            } catch {
                errorMessage = UserFriendlyError.from(error, context: .bid).message
            }
        }
    }

    private func acceptBid(_ bid: Bid) {
        actionTask?.cancel()
        actionTask = Task { @MainActor in
            errorMessage = nil
            do {
                struct StatusUpdate: Encodable { let status: String }
                try await supabase
                    .from("bids")
                    .update(StatusUpdate(status: BidStatus.accepted.rawValue))
                    .eq("id", value: bid.id.uuidString)
                    .execute()

                // Reload to reflect the change
                await loadBids()
            } catch {
                errorMessage = UserFriendlyError.from(error, context: .bid).message
            }
        }
    }

    private func rejectBid(_ bid: Bid) {
        actionTask?.cancel()
        actionTask = Task { @MainActor in
            errorMessage = nil
            do {
                struct StatusUpdate: Encodable { let status: String }
                try await supabase
                    .from("bids")
                    .update(StatusUpdate(status: BidStatus.rejected.rawValue))
                    .eq("id", value: bid.id.uuidString)
                    .execute()
                await loadBids()
            } catch {
                errorMessage = UserFriendlyError.from(error, context: .bid).message
            }
        }
    }
}
