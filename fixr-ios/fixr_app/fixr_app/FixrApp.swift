import SwiftUI
import SwiftData
import Supabase

// MARK: - Supabase Client Factory

extension SupabaseClient {
    /// Shared Supabase client instance. Configuration is read from Info.plist via xcconfig.
    static let shared: SupabaseClient = {
        SupabaseClient(
            supabaseURL: SupabaseEnvironment.supabaseURL,
            supabaseKey: SupabaseEnvironment.supabaseKey
        )
    }()
}

// MARK: - SwiftData Container

extension ModelContainer {
    static let fixrContainer: ModelContainer = {
        let schema = Schema([UserProfile.self, CachedJob.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }()
}

// MARK: - App Entry Point

@main
struct FixrApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.supabaseClient, SupabaseClient.shared)
                .preferredColorScheme(.dark)
        }
        .modelContainer(ModelContainer.fixrContainer)
    }
}

// MARK: - Environment Key for Supabase

private struct SupabaseClientKey: EnvironmentKey {
    static let defaultValue: SupabaseClient = SupabaseClient.shared
}

extension EnvironmentValues {
    var supabaseClient: SupabaseClient {
        get { self[SupabaseClientKey.self] }
        set { self[SupabaseClientKey.self] = newValue }
    }
}
