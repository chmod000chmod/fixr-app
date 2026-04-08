import SwiftUI

enum NotificationType {
    case newBid
    case bidAccepted
    case jobUpdate
    case paymentReceived
    case verificationUpdate

    var icon: String {
        switch self {
        case .newBid: return "doc.badge.plus"
        case .bidAccepted: return "checkmark.seal.fill"
        case .jobUpdate: return "briefcase.fill"
        case .paymentReceived: return "dollarsign.circle.fill"
        case .verificationUpdate: return "person.badge.shield.checkmark.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .newBid: return .fixrPrimary
        case .bidAccepted: return Color(hex: "#22C55E")
        case .jobUpdate: return .fixrOrange
        case .paymentReceived: return Color(hex: "#22C55E")
        case .verificationUpdate: return .fixrPrimary
        }
    }
}

struct AppNotification: Identifiable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let body: String
    let timestamp: Date
    var isRead: Bool
}

struct NotificationsView: View {
    @State private var notifications: [AppNotification] = AppNotification.sampleData
    @State private var showClearConfirm = false

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fixrBackground.ignoresSafeArea()

                if notifications.isEmpty {
                    emptyView
                } else {
                    List {
                        ForEach($notifications) { $notification in
                            notificationRow($notification)
                                .listRowBackground(
                                    notification.isRead
                                        ? Color.fixrBackground
                                        : Color.fixrPrimary.opacity(0.05)
                                )
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                                .onTapGesture {
                                    notification.isRead = true
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            notifications.removeAll { $0.id == notification.id }
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle(unreadCount > 0 ? "Notifications (\(unreadCount))" : "Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !notifications.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button {
                                markAllRead()
                            } label: {
                                Label("Mark All Read", systemImage: "checkmark.circle")
                            }
                            Button(role: .destructive) {
                                showClearConfirm = true
                            } label: {
                                Label("Clear All", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.fixrMuted)
                        }
                    }
                }
            }
        }
        .confirmationDialog("Clear all notifications?", isPresented: $showClearConfirm) {
            Button("Clear All", role: .destructive) {
                withAnimation { notifications.removeAll() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Subviews

    private func notificationRow(_ notification: Binding<AppNotification>) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(notification.wrappedValue.type.iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: notification.wrappedValue.type.icon)
                    .font(.system(size: 18))
                    .foregroundColor(notification.wrappedValue.type.iconColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.wrappedValue.title)
                        .font(.system(size: 14, weight: notification.wrappedValue.isRead ? .regular : .semibold))
                        .foregroundColor(.fixrText)
                    Spacer()
                    Text(relativeTime(notification.wrappedValue.timestamp))
                        .font(.system(size: 11))
                        .foregroundColor(.fixrMuted)
                }

                Text(notification.wrappedValue.body)
                    .font(.fixrCaption)
                    .foregroundColor(.fixrMuted)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Unread dot
            if !notification.wrappedValue.isRead {
                Circle()
                    .fill(Color.fixrPrimary)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color.fixrCard)
        .cornerRadius(14)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash.fill")
                .font(.system(size: 52))
                .foregroundColor(.fixrMuted)
            Text("No notifications")
                .font(.fixrHeading)
                .foregroundColor(.fixrText)
            Text("You're all caught up! We'll notify you about\njob updates, bids, and payments.")
                .font(.fixrBody)
                .foregroundColor(.fixrMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
        }
    }

    // MARK: - Actions

    private func markAllRead() {
        withAnimation {
            for i in notifications.indices {
                notifications[i].isRead = true
            }
        }
    }

    private func relativeTime(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "Just now" }
        if seconds < 3600 { return "\(seconds / 60)m ago" }
        if seconds < 86400 { return "\(seconds / 3600)h ago" }
        return "\(seconds / 86400)d ago"
    }
}

// MARK: - Sample Data

extension AppNotification {
    static let sampleData: [AppNotification] = [
        AppNotification(
            type: .newBid,
            title: "New Quote Received",
            body: "Marc Dupont submitted a quote of $285 for your plumbing job",
            timestamp: Date().addingTimeInterval(-1800),
            isRead: false
        ),
        AppNotification(
            type: .bidAccepted,
            title: "Quote Accepted",
            body: "Your quote for the electrical panel job has been accepted",
            timestamp: Date().addingTimeInterval(-7200),
            isRead: false
        ),
        AppNotification(
            type: .verificationUpdate,
            title: "RBQ Verification Complete",
            body: "Your RBQ licence has been verified. You now have full Fixer access.",
            timestamp: Date().addingTimeInterval(-86400),
            isRead: true
        ),
        AppNotification(
            type: .paymentReceived,
            title: "Payment Processed",
            body: "$450 has been deposited to your account for job #1247",
            timestamp: Date().addingTimeInterval(-172800),
            isRead: true
        ),
        AppNotification(
            type: .jobUpdate,
            title: "Job Status Updated",
            body: "Your kitchen renovation job has been marked as completed",
            timestamp: Date().addingTimeInterval(-259200),
            isRead: true
        )
    ]
}
