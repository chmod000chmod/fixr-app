import Foundation

enum ErrorContext {
    case general
    case auth
    case job
    case bid
    case profile
    case verification
    case signOut
}

struct UserFriendlyError: LocalizedError {
    let context: ErrorContext
    let underlying: Error?
    let message: String

    var errorDescription: String? { message }

    static func from(_ error: Error, context: ErrorContext = .general) -> UserFriendlyError {
        let description = error.localizedDescription.lowercased()

        switch context {
        case .auth:
            return authError(from: description, underlying: error)
        case .job:
            return jobError(from: description, underlying: error)
        case .bid:
            return bidError(from: description, underlying: error)
        case .profile:
            return profileError(from: description, underlying: error)
        case .verification:
            return verificationError(from: description, underlying: error)
        case .signOut:
            return UserFriendlyError(
                context: .signOut,
                underlying: error,
                message: "Unable to sign out. Please try again."
            )
        case .general:
            return generalError(from: description, underlying: error)
        }
    }

    private static func authError(from description: String, underlying: Error) -> UserFriendlyError {
        if description.contains("invalid login credentials") || description.contains("invalid_credentials") {
            return UserFriendlyError(context: .auth, underlying: underlying,
                                     message: "Incorrect email or password. Please try again.")
        }
        if description.contains("email already registered") || description.contains("already exists") {
            return UserFriendlyError(context: .auth, underlying: underlying,
                                     message: "An account with this email already exists. Please sign in.")
        }
        if description.contains("network") || description.contains("connection") {
            return UserFriendlyError(context: .auth, underlying: underlying,
                                     message: "No internet connection. Please check your network and try again.")
        }
        if description.contains("timeout") {
            return UserFriendlyError(context: .auth, underlying: underlying,
                                     message: "The request timed out. Please try again.")
        }
        return UserFriendlyError(context: .auth, underlying: underlying,
                                 message: "Authentication failed. Please try again.")
    }

    private static func jobError(from description: String, underlying: Error) -> UserFriendlyError {
        if description.contains("network") || description.contains("connection") {
            return UserFriendlyError(context: .job, underlying: underlying,
                                     message: "Cannot load jobs right now. Check your connection.")
        }
        if description.contains("permission") || description.contains("unauthorized") {
            return UserFriendlyError(context: .job, underlying: underlying,
                                     message: "You don't have permission to perform this action.")
        }
        return UserFriendlyError(context: .job, underlying: underlying,
                                 message: "Something went wrong loading jobs. Please try again.")
    }

    private static func bidError(from description: String, underlying: Error) -> UserFriendlyError {
        if description.contains("network") || description.contains("connection") {
            return UserFriendlyError(context: .bid, underlying: underlying,
                                     message: "Cannot submit bid right now. Check your connection.")
        }
        return UserFriendlyError(context: .bid, underlying: underlying,
                                 message: "Failed to process bid. Please try again.")
    }

    private static func profileError(from description: String, underlying: Error) -> UserFriendlyError {
        if description.contains("network") || description.contains("connection") {
            return UserFriendlyError(context: .profile, underlying: underlying,
                                     message: "Cannot update profile right now. Check your connection.")
        }
        return UserFriendlyError(context: .profile, underlying: underlying,
                                 message: "Failed to update profile. Please try again.")
    }

    private static func verificationError(from description: String, underlying: Error) -> UserFriendlyError {
        if description.contains("invalid") {
            return UserFriendlyError(context: .verification, underlying: underlying,
                                     message: "Invalid licence number. Please check and try again.")
        }
        return UserFriendlyError(context: .verification, underlying: underlying,
                                 message: "Verification failed. Please try again later.")
    }

    private static func generalError(from description: String, underlying: Error) -> UserFriendlyError {
        if description.contains("network") || description.contains("connection") {
            return UserFriendlyError(context: .general, underlying: underlying,
                                     message: "No internet connection. Please check your network.")
        }
        if description.contains("timeout") {
            return UserFriendlyError(context: .general, underlying: underlying,
                                     message: "The request timed out. Please try again.")
        }
        return UserFriendlyError(context: .general, underlying: underlying,
                                 message: "Something went wrong. Please try again.")
    }
}
