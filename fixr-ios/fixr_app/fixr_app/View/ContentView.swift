import SwiftUI
import SwiftData
import Supabase

enum NavigationState {
    case splash
    case welcome
    case authenticated
}

struct ContentView: View {
    @Environment(\.supabaseClient) private var supabase
    @Environment(\.modelContext) private var modelContext

    @State private var navigationState: NavigationState = .splash
    @State private var showLogin = false
    @State private var loginStartsInSignUp = false
    @State private var onboardingTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            Color.fixrBackground.ignoresSafeArea()

            switch navigationState {
            case .splash:
                SplashView()
                    .transition(.opacity)

            case .welcome:
                WelcomeView(
                    onGetStarted: {
                        loginStartsInSignUp = true
                        showLogin = true
                    },
                    onSignIn: {
                        loginStartsInSignUp = false
                        showLogin = true
                    }
                )
                .transition(.opacity)
                .sheet(isPresented: $showLogin) {
                    LoginView()
                }

            case .authenticated:
                AuthenticatedRootView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: navigationState)
        .task {
            await observeAuthState()
        }
        .onDisappear {
            onboardingTask?.cancel()
        }
    }

    private func observeAuthState() async {
        // Brief splash display
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        for await (event, session) in await supabase.auth.authStateChanges {
            await handleAuthEvent(event, session: session)
        }
    }

    @MainActor
    private func handleAuthEvent(_ event: AuthChangeEvent, session: Session?) async {
        switch event {
        case .initialSession:
            if let session = session {
                await resolveOnboarding(userId: session.user.id)
            } else {
                navigationState = .welcome
            }

        case .signedIn:
            if let session = session {
                await resolveOnboarding(userId: session.user.id)
            }

        case .signedOut:
            clearLocalProfiles()
            navigationState = .welcome

        case .tokenRefreshed, .userUpdated, .mfaChallengeVerified:
            break

        default:
            break
        }
    }

    @MainActor
    private func resolveOnboarding(userId: UUID) async {
        onboardingTask?.cancel()
        onboardingTask = Task {
            // Check SwiftData for an existing profile
            let descriptor = FetchDescriptor<UserProfile>(
                predicate: #Predicate { $0.userId == userId }
            )
            let profiles = try? modelContext.fetch(descriptor)
            let localProfile = profiles?.first

            // If local profile says onboarding is done, go straight to app
            if localProfile?.hasCompletedOnboarding == true {
                navigationState = .authenticated
                return
            }

            // Check UserDefaults onboarding state
            if OnboardingState.isCompleted(for: userId) {
                navigationState = .authenticated
                return
            }

            // No completed onboarding found — show authenticated root
            // (which will handle the onboarding flow internally)
            navigationState = .authenticated
        }
    }

    @MainActor
    private func clearLocalProfiles() {
        let descriptor = FetchDescriptor<UserProfile>()
        if let profiles = try? modelContext.fetch(descriptor) {
            for profile in profiles {
                modelContext.delete(profile)
            }
            try? modelContext.save()
        }
    }
}

// MARK: - Authenticated Root

private struct AuthenticatedRootView: View {
    @Environment(\.supabaseClient) private var supabase
    @Environment(\.modelContext) private var modelContext

    @State private var currentProfile: UserProfile?
    @State private var showOnboarding = false
    @State private var loadTask: Task<Void, Never>?

    var body: some View {
        Group {
            if let profile = currentProfile {
                if profile.hasCompletedOnboarding {
                    MainTabView(profile: profile)
                } else {
                    OnboardingFlow(
                        role: profile.userRole,
                        onFinish: {
                            profile.onboardingCompletedAt = Date()
                            try? modelContext.save()
                            currentProfile = profile
                        },
                        onSignIn: {}
                    )
                }
            } else {
                ProgressView()
                    .tint(.fixrPrimary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.fixrBackground)
            }
        }
        .task {
            await loadProfile()
        }
        .onDisappear {
            loadTask?.cancel()
        }
    }

    @MainActor
    private func loadProfile() async {
        loadTask?.cancel()
        loadTask = Task {
            guard let userId = await supabase.auth.currentUser?.id else { return }

            let descriptor = FetchDescriptor<UserProfile>(
                predicate: #Predicate { $0.userId == userId }
            )
            currentProfile = (try? modelContext.fetch(descriptor))?.first
        }
    }
}
