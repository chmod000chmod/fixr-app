import Foundation
import Supabase

enum AuthServiceError: LocalizedError {
    case emailConfirmationRequired
    case noSession
    case unexpectedResult(String)

    var errorDescription: String? {
        switch self {
        case .emailConfirmationRequired:
            return "Please check your email to confirm your account before signing in."
        case .noSession:
            return "No active session found. Please sign in."
        case .unexpectedResult(let detail):
            return "An unexpected error occurred: \(detail)"
        }
    }
}

final class AuthService {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    /// Creates a new user account and inserts a basic profile row.
    /// Throws `AuthServiceError.emailConfirmationRequired` when email confirmation is pending.
    func signUp(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        role: UserRole
    ) async throws {
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: [
                "first_name": .string(firstName),
                "last_name": .string(lastName),
                "role": .string(role.rawValue)
            ]
        )

        // Supabase returns nil session when email confirmation is required
        if response.session == nil {
            throw AuthServiceError.emailConfirmationRequired
        }
    }

    /// Signs in an existing user with email and password.
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    /// Signs out the currently authenticated user.
    func signOut() async throws {
        try await client.auth.signOut()
    }

    /// Returns the current active session, or throws `noSession` if none exists.
    func getCurrentSession() async throws -> Session {
        guard let session = try await client.auth.session else {
            throw AuthServiceError.noSession
        }
        return session
    }

    /// Returns the current user's ID if a session is active.
    func currentUserId() async -> UUID? {
        guard let session = try? await client.auth.session else { return nil }
        return session.user.id
    }

    /// Resends the confirmation email for a given address.
    func resendConfirmationEmail(to email: String) async throws {
        try await client.auth.resend(email: email, type: .signup)
    }
}
