import SwiftUI

struct Conversation: Identifiable {
    let id = UUID()
    let participantName: String
    let lastMessage: String
    let timestamp: Date
    let unreadCount: Int
    let isOnline: Bool
}

struct MessagesView: View {
    @State private var conversations: [Conversation] = Conversation.sampleData
    @State private var selectedConversation: Conversation?
    @State private var searchText = ""

    var filteredConversations: [Conversation] {
        if searchText.isEmpty { return conversations }
        return conversations.filter {
            $0.participantName.localizedCaseInsensitiveContains(searchText) ||
            $0.lastMessage.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fixrBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.fixrMuted)
                        TextField("Search conversations", text: $searchText)
                            .font(.fixrBody)
                            .foregroundColor(.fixrText)
                    }
                    .padding(12)
                    .background(Color.fixrCard)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                    if filteredConversations.isEmpty {
                        emptyView
                    } else {
                        List(filteredConversations) { convo in
                            Button {
                                selectedConversation = convo
                            } label: {
                                conversationRow(convo)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.fixrBackground)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedConversation) { convo in
                ConversationDetailView(conversation: convo)
            }
        }
    }

    // MARK: - Subviews

    private func conversationRow(_ convo: Conversation) -> some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.fixrPrimary.opacity(0.2))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Text(initials(convo.participantName))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.fixrPrimary)
                    )

                if convo.isOnline {
                    Circle()
                        .fill(Color(hex: "#22C55E"))
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(Color.fixrBackground, lineWidth: 2))
                }
            }

            // Message preview
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(convo.participantName)
                        .font(.system(size: 15, weight: convo.unreadCount > 0 ? .semibold : .regular))
                        .foregroundColor(.fixrText)
                    Spacer()
                    Text(formattedDate(convo.timestamp))
                        .font(.fixrCaption)
                        .foregroundColor(.fixrMuted)
                }

                HStack {
                    Text(convo.lastMessage)
                        .font(.fixrCaption)
                        .foregroundColor(convo.unreadCount > 0 ? .fixrText : .fixrMuted)
                        .lineLimit(1)
                    Spacer()
                    if convo.unreadCount > 0 {
                        Text("\(convo.unreadCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.fixrPrimary)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.fixrCard)
        .cornerRadius(14)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(.fixrMuted)
            Text("No messages yet")
                .font(.fixrHeading)
                .foregroundColor(.fixrText)
            Text("When clients or fixers reach out, conversations will appear here.")
                .font(.fixrBody)
                .foregroundColor(.fixrMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
            Spacer()
        }
    }

    // MARK: - Helpers

    private func initials(_ name: String) -> String {
        name.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
    }

    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return date.formatted(.dateTime.hour().minute())
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(.dateTime.month(.abbreviated).day())
        }
    }
}

// MARK: - Conversation Detail (Placeholder)

struct ConversationDetailView: View {
    let conversation: Conversation
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = ChatMessage.sampleData(for: "Them")

    struct ChatMessage: Identifiable {
        let id = UUID()
        let text: String
        let isFromMe: Bool
        let timestamp: Date

        static func sampleData(for name: String) -> [ChatMessage] {
            [
                ChatMessage(text: "Hi, I saw your job posting for plumbing repair.", isFromMe: false, timestamp: Date().addingTimeInterval(-3600)),
                ChatMessage(text: "Yes! Are you available this week?", isFromMe: true, timestamp: Date().addingTimeInterval(-3500)),
                ChatMessage(text: "I can come by Thursday afternoon.", isFromMe: false, timestamp: Date().addingTimeInterval(-3400)),
            ]
        }
    }

    var body: some View {
        ZStack {
            Color.fixrBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Messages list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            chatBubble(message)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }

                // Input bar
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $messageText)
                        .font(.fixrBody)
                        .foregroundColor(.fixrText)
                        .padding(12)
                        .background(Color.fixrCard)
                        .cornerRadius(20)

                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(messageText.isEmpty ? .fixrMuted : .fixrPrimary)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.fixrBackground)
            }
        }
        .navigationTitle(conversation.participantName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func chatBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.isFromMe { Spacer() }

            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.fixrBody)
                    .foregroundColor(.fixrText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(message.isFromMe ? Color.fixrPrimary : Color.fixrCard)
                    .cornerRadius(18)
                    .cornerRadius(message.isFromMe ? 4 : 18, corners: message.isFromMe ? .bottomRight : .bottomLeft)

                Text(message.timestamp, style: .time)
                    .font(Font.system(size: 10))
                    .foregroundColor(.fixrMuted)
            }
            .frame(maxWidth: 280, alignment: message.isFromMe ? .trailing : .leading)

            if !message.isFromMe { Spacer() }
        }
    }

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        messages.append(ChatMessage(text: text, isFromMe: true, timestamp: Date()))
        messageText = ""
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Sample Data

extension Conversation {
    static let sampleData: [Conversation] = [
        Conversation(
            participantName: "Marc Dupont",
            lastMessage: "I can come by Thursday afternoon.",
            timestamp: Date().addingTimeInterval(-1800),
            unreadCount: 2,
            isOnline: true
        ),
        Conversation(
            participantName: "Sophie Tremblay",
            lastMessage: "Quote accepted! See you Monday.",
            timestamp: Date().addingTimeInterval(-86400),
            unreadCount: 0,
            isOnline: false
        ),
        Conversation(
            participantName: "Jean-François Roy",
            lastMessage: "Is the issue still ongoing?",
            timestamp: Date().addingTimeInterval(-172800),
            unreadCount: 1,
            isOnline: true
        )
    ]
}
