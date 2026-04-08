import SwiftUI
import Supabase

struct LoginView: View {
    @Environment(\.supabaseClient) private var supabase
    @Environment(\.dismiss) private var dismiss

    @State private var mode: LoginMode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var selectedRole: UserRole = .client
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showEmailConfirmation = false
    @State private var pendingEmail = ""
    @State private var loginTask: Task<Void, Never>?

    enum LoginMode { case signIn, signUp }

    var body: some View {
        NavigationStack {
            ZStack {
                FixrGradientBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        FixrLogoHeader()
                            .padding(.top, 32)

                        // Mode toggle
                        HStack(spacing: 0) {
                            modeButton("Sign In", selected: mode == .signIn) { mode = .signIn }
                            modeButton("Create Account", selected: mode == .signUp) { mode = .signUp }
                        }
                        .background(Color.fixrCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 24)

                        // Role selector (sign up only)
                        if mode == .signUp {
                            roleSelector
                                .padding(.horizontal, 24)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // Form fields
                        VStack(spacing: 14) {
                            if mode == .signUp {
                                HStack(spacing: 12) {
                                    TextField("First name", text: $firstName)
                                        .textFieldStyle(FixrTextFieldStyle())
                                    TextField("Last name", text: $lastName)
                                        .textFieldStyle(FixrTextFieldStyle())
                                }
                                .transition(.opacity)
                            }

                            TextField("Email address", text: $email)
                                .textFieldStyle(FixrTextFieldStyle())
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)

                            SecureField("Password (min 8 characters)", text: $password)
                                .textFieldStyle(FixrTextFieldStyle())

                            if mode == .signUp {
                                passwordStrengthView
                                    .transition(.opacity)
                            }
                        }
                        .padding(.horizontal, 24)
                        .animation(.easeInOut(duration: 0.2), value: mode)

                        // Error
                        if let error = errorMessage {
                            Text(error)
                                .font(.fixrCaption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }

                        // Submit
                        VStack(spacing: 14) {
                            if mode == .signIn {
                                FixrPrimaryButton("Sign In", isLoading: isLoading) {
                                    performSignIn()
                                }
                            } else {
                                if selectedRole == .fixer {
                                    FixrOrangeButton("Create Fixer Account", isLoading: isLoading) {
                                        performSignUp()
                                    }
                                } else {
                                    FixrPrimaryButton("Create Client Account", isLoading: isLoading) {
                                        performSignUp()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.fixrMuted)
                }
            }
        }
        .sheet(isPresented: $showEmailConfirmation) {
            EmailConfirmationPendingView(
                email: pendingEmail,
                onBackToSignIn: {
                    showEmailConfirmation = false
                    mode = .signIn
                }
            )
        }
        .onDisappear {
            loginTask?.cancel()
        }
    }

    // MARK: - Subviews

    private var roleSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("I am a...")
                .font(.fixrCaption)
                .foregroundColor(.fixrMuted)

            HStack(spacing: 12) {
                roleChip("Client", role: .client, icon: "house.fill")
                roleChip("Fixer", role: .fixer, icon: "wrench.and.screwdriver.fill")
            }
        }
    }

    private func roleChip(_ label: String, role: UserRole, icon: String) -> some View {
        Button {
            selectedRole = role
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(label)
                    .font(.fixrBody)
            }
            .foregroundColor(selectedRole == role ? .white : .fixrMuted)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(selectedRole == role ? role.accentColor : Color.fixrCard)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    private func modeButton(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: selected ? .semibold : .regular))
                .foregroundColor(selected ? .fixrText : .fixrMuted)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(selected ? Color.fixrPrimary.opacity(0.15) : Color.clear)
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    private var passwordStrengthView: some View {
        let strength = passwordStrength(password)
        return VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.fixrCard).frame(height: 4)
                    Capsule().fill(strength.color)
                        .frame(width: geo.size.width * strength.fraction, height: 4)
                        .animation(.easeInOut(duration: 0.2), value: password)
                }
            }
            .frame(height: 4)

            Text(strength.label)
                .font(.fixrCaption)
                .foregroundColor(strength.color)
        }
    }

    // MARK: - Validation

    private var isSignInValid: Bool {
        isValidEmail(email) && password.count >= 8
    }

    private var isSignUpValid: Bool {
        isSignInValid && !firstName.trimmingCharacters(in: .whitespaces).isEmpty
            && !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func isValidEmail(_ value: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return value.range(of: regex, options: .regularExpression) != nil
    }

    private func passwordStrength(_ pw: String) -> (color: Color, label: String, fraction: CGFloat) {
        if pw.count < 6 { return (.red, "Too short", 0.25) }
        if pw.count < 8 { return (.orange, "Weak", 0.45) }
        let hasUpper = pw.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasDigit = pw.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecial = pw.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        let score = [hasUpper, hasDigit, hasSpecial].filter { $0 }.count
        switch score {
        case 0: return (Color(hex: "#FBBF24"), "Fair", 0.55)
        case 1: return (.fixrPrimary, "Good", 0.75)
        default: return (Color(hex: "#22C55E"), "Strong", 1.0)
        }
    }

    // MARK: - Actions

    private func performSignIn() {
        guard isSignInValid else {
            errorMessage = "Please enter a valid email and password (min 8 characters)."
            return
        }

        loginTask?.cancel()
        loginTask = Task { @MainActor in
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            let service = AuthService(client: supabase)
            do {
                try await service.signIn(email: email, password: password)
                dismiss()
            } catch {
                errorMessage = UserFriendlyError.from(error, context: .auth).message
            }
        }
    }

    private func performSignUp() {
        guard isSignUpValid else {
            errorMessage = "Please fill in all fields with valid information."
            return
        }

        loginTask?.cancel()
        loginTask = Task { @MainActor in
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }

            let service = AuthService(client: supabase)
            do {
                try await service.signUp(
                    email: email,
                    password: password,
                    firstName: firstName.trimmingCharacters(in: .whitespaces),
                    lastName: lastName.trimmingCharacters(in: .whitespaces),
                    role: selectedRole
                )
                dismiss()
            } catch AuthServiceError.emailConfirmationRequired {
                pendingEmail = email
                showEmailConfirmation = true
            } catch {
                errorMessage = UserFriendlyError.from(error, context: .auth).message
            }
        }
    }
}

// MARK: - Email Confirmation Pending

struct EmailConfirmationPendingView: View {
    let email: String
    var onBackToSignIn: () -> Void

    @Environment(\.supabaseClient) private var supabase
    @State private var isResending = false
    @State private var resendMessage: String?
    @State private var resendTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            FixrGradientBackground()

            VStack(spacing: 28) {
                Spacer()

                Image(systemName: "envelope.circle.fill")
                    .font(.system(size: 72))
                    .foregroundColor(.fixrPrimary)

                VStack(spacing: 10) {
                    Text("Confirm your email")
                        .fixrTitleStyle()

                    Text("We sent a confirmation link to\n\(email)")
                        .fixrSubtitleStyle()
                        .padding(.horizontal, 32)
                }

                VStack(spacing: 16) {
                    FixrBullet(text: "Open the email from Fixr")
                    FixrBullet(text: "Click the confirmation link")
                    FixrBullet(text: "Return here to sign in")
                }
                .padding(.horizontal, 40)

                if let message = resendMessage {
                    Text(message)
                        .font(.fixrCaption)
                        .foregroundColor(.fixrMuted)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                VStack(spacing: 14) {
                    FixrSecondaryButton("Resend Email") {
                        resendConfirmation()
                    }

                    Button("Back to Sign In") {
                        onBackToSignIn()
                    }
                    .font(.fixrBody)
                    .foregroundColor(.fixrMuted)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onDisappear {
            resendTask?.cancel()
        }
    }

    private func resendConfirmation() {
        resendTask?.cancel()
        resendTask = Task { @MainActor in
            isResending = true
            defer { isResending = false }

            let service = AuthService(client: supabase)
            do {
                try await service.resendConfirmationEmail(to: email)
                resendMessage = "Email resent. Check your inbox."
            } catch {
                resendMessage = "Failed to resend. Please try again."
            }
        }
    }
}
