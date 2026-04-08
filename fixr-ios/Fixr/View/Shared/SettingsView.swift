import SwiftUI
import SwiftData
import Supabase

struct SettingsView: View {
    let profile: UserProfile

    @Environment(\.supabaseClient) private var supabase
    @Environment(\.modelContext) private var modelContext

    @State private var showEditProfile = false
    @State private var showChangePassword = false
    @State private var showSignOutConfirm = false
    @State private var isSigningOut = false
    @State private var signOutError: String?
    @State private var signOutTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fixrBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        profileBanner
                            .padding(.top, 16)

                        // Account section
                        settingsSection("Account") {
                            settingsRow(icon: "person.fill", label: "Edit Profile", color: .fixrPrimary) {
                                showEditProfile = true
                            }
                            Divider().background(Color.white.opacity(0.06))
                            settingsRow(icon: "key.fill", label: "Change Password", color: .fixrPrimary) {
                                showChangePassword = true
                            }
                        }

                        // Verification section
                        settingsSection("Verification") {
                            verificationRow
                        }

                        // Payment section
                        settingsSection("Payment") {
                            settingsRow(icon: "creditcard.fill", label: "Payment Methods", color: Color(hex: "#22C55E")) {}
                            Divider().background(Color.white.opacity(0.06))
                            settingsRow(icon: "arrow.down.circle.fill", label: "Payout Settings", color: Color(hex: "#22C55E")) {}
                        }

                        // Support section
                        settingsSection("Support") {
                            settingsRow(icon: "questionmark.circle.fill", label: "Help Center", color: .fixrMuted) {}
                            Divider().background(Color.white.opacity(0.06))
                            settingsRow(icon: "envelope.fill", label: "Contact Us", color: .fixrMuted) {}
                            Divider().background(Color.white.opacity(0.06))
                            settingsRow(icon: "doc.text.fill", label: "Privacy Policy", color: .fixrMuted) {}
                            Divider().background(Color.white.opacity(0.06))
                            settingsRow(icon: "doc.plaintext.fill", label: "Terms of Service", color: .fixrMuted) {}
                        }

                        // Sign out
                        if let error = signOutError {
                            Text(error)
                                .font(.fixrCaption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 24)
                        }

                        Button {
                            showSignOutConfirm = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 16))
                                Text("Sign Out")
                                    .font(.fixrButton)
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(14)
                        }
                        .padding(.horizontal, 24)
                        .disabled(isSigningOut)

                        appVersionFooter
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(profile: profile)
        }
        .sheet(isPresented: $showChangePassword) {
            ChangePasswordView()
        }
        .confirmationDialog("Sign out of Fixr?", isPresented: $showSignOutConfirm) {
            Button("Sign Out", role: .destructive) {
                performSignOut()
            }
            Button("Cancel", role: .cancel) {}
        }
        .onDisappear {
            signOutTask?.cancel()
        }
    }

    // MARK: - Subviews

    private var profileBanner: some View {
        VStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(profile.userRole.accentColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                Text(avatarInitials)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(profile.userRole.accentColor)
            }

            VStack(spacing: 6) {
                Text(profile.fullName.isEmpty ? "Your Name" : profile.fullName)
                    .font(.fixrTitle)
                    .foregroundColor(.fixrText)

                HStack(spacing: 8) {
                    Text(profile.email)
                        .font(.fixrCaption)
                        .foregroundColor(.fixrMuted)

                    FixrBadge(
                        style: .custom(profile.userRole.accentColor),
                        text: profile.userRole.displayName
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
    }

    private var verificationRow: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(profile.isIdVerified ? Color(hex: "#22C55E").opacity(0.15) : Color.fixrMuted.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: profile.isIdVerified ? "checkmark.shield.fill" : "shield.fill")
                    .font(.system(size: 16))
                    .foregroundColor(profile.isIdVerified ? Color(hex: "#22C55E") : .fixrMuted)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Identity Verification")
                    .font(.fixrBody)
                    .foregroundColor(.fixrText)
                Text(profile.isIdVerified ? "Verified" : "Pending Review")
                    .font(.fixrCaption)
                    .foregroundColor(profile.isIdVerified ? Color(hex: "#22C55E") : .fixrMuted)
            }

            Spacer()

            if profile.userRole == .fixer {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("RBQ Licence")
                        .font(.fixrCaption)
                        .foregroundColor(.fixrMuted)
                    Text(profile.isRbqVerified ? "Verified" : "Unverified")
                        .font(.fixrCaption)
                        .foregroundColor(profile.isRbqVerified ? Color(hex: "#22C55E") : .fixrMuted)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.fixrCaption)
                .foregroundColor(.fixrMuted)
                .padding(.horizontal, 24)

            FixrCard { content() }
                .padding(.horizontal, 24)
        }
    }

    private func settingsRow(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.15))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundColor(color)
                }
                Text(label)
                    .font(.fixrBody)
                    .foregroundColor(.fixrText)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.fixrMuted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private var appVersionFooter: some View {
        VStack(spacing: 4) {
            Text("Fixr — Quebec Home Services")
                .font(.fixrCaption)
                .foregroundColor(.fixrMuted)
            Text("Version \(appVersion)")
                .font(Font.system(size: 11))
                .foregroundColor(.fixrMuted.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var avatarInitials: String {
        let first = profile.firstName.first.map(String.init) ?? ""
        let last = profile.lastName.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }

    // MARK: - Sign Out

    private func performSignOut() {
        signOutTask?.cancel()
        signOutTask = Task { @MainActor in
            isSigningOut = true
            signOutError = nil
            defer { isSigningOut = false }

            let service = AuthService(client: supabase)
            do {
                try await service.signOut()
            } catch {
                signOutError = UserFriendlyError.from(error, context: .signOut).message
            }
        }
    }
}

// MARK: - Edit Profile Sheet

struct EditProfileView: View {
    let profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var firstName: String
    @State private var lastName: String
    @State private var phone: String
    @State private var city: String
    @State private var isSaving = false

    init(profile: UserProfile) {
        self.profile = profile
        _firstName = State(initialValue: profile.firstName)
        _lastName = State(initialValue: profile.lastName)
        _phone = State(initialValue: profile.phone)
        _city = State(initialValue: profile.city)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FixrGradientBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("First Name")
                                    .font(.fixrCaption).foregroundColor(.fixrMuted)
                                TextField("First name", text: $firstName)
                                    .textFieldStyle(FixrTextFieldStyle())
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Last Name")
                                    .font(.fixrCaption).foregroundColor(.fixrMuted)
                                TextField("Last name", text: $lastName)
                                    .textFieldStyle(FixrTextFieldStyle())
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Phone")
                                .font(.fixrCaption).foregroundColor(.fixrMuted)
                            TextField("514-555-0000", text: $phone)
                                .textFieldStyle(FixrTextFieldStyle())
                                .keyboardType(.phonePad)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("City")
                                .font(.fixrCaption).foregroundColor(.fixrMuted)
                            TextField("Montréal", text: $city)
                                .textFieldStyle(FixrTextFieldStyle())
                        }

                        FixrPrimaryButton("Save Changes", isLoading: isSaving) {
                            saveChanges()
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.fixrMuted)
                }
            }
        }
    }

    private func saveChanges() {
        isSaving = true
        profile.firstName = firstName.trimmingCharacters(in: .whitespaces)
        profile.lastName = lastName.trimmingCharacters(in: .whitespaces)
        profile.phone = phone
        profile.city = city
        try? modelContext.save()
        isSaving = false
        dismiss()
    }
}

// MARK: - Change Password Sheet

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.supabaseClient) private var supabase

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isUpdating = false
    @State private var errorMessage: String?
    @State private var updateTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            ZStack {
                FixrGradientBackground()

                VStack(spacing: 16) {
                    SecureField("New Password (min 8 chars)", text: $newPassword)
                        .textFieldStyle(FixrTextFieldStyle())

                    SecureField("Confirm New Password", text: $confirmPassword)
                        .textFieldStyle(FixrTextFieldStyle())

                    if let error = errorMessage {
                        Text(error)
                            .font(.fixrCaption)
                            .foregroundColor(.red)
                    }

                    FixrPrimaryButton("Update Password", isLoading: isUpdating) {
                        updatePassword()
                    }
                    .padding(.top, 8)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.fixrMuted)
                }
            }
        }
        .onDisappear { updateTask?.cancel() }
    }

    private func updatePassword() {
        guard newPassword == confirmPassword else {
            errorMessage = "Passwords don't match."
            return
        }
        guard newPassword.count >= 8 else {
            errorMessage = "Password must be at least 8 characters."
            return
        }

        updateTask?.cancel()
        updateTask = Task { @MainActor in
            isUpdating = true
            errorMessage = nil
            defer { isUpdating = false }

            do {
                try await supabase.auth.update(user: UserAttributes(password: newPassword))
                dismiss()
            } catch {
                errorMessage = UserFriendlyError.from(error, context: .auth).message
            }
        }
    }
}
