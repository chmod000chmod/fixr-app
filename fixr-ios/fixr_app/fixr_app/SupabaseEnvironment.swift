import Foundation

/// Reads Supabase and analytics configuration from Info.plist.
/// Keys are injected at build time via xcconfig — never hardcoded.
enum SupabaseEnvironment {

    /// The Supabase project URL. Falls back to placeholder so the app builds without xcconfig.
    static var supabaseURL: URL {
        if let rawValue = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
           !rawValue.isEmpty,
           let url = URL(string: rawValue) {
            return url
        }
        // Placeholder — replace with your Supabase project URL via xcconfig
        return URL(string: "https://placeholder.supabase.co")!
    }

    /// The Supabase anon key. Falls back to placeholder so the app builds without xcconfig.
    static var supabaseKey: String {
        if let value = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String,
           !value.isEmpty {
            return value
        }
        // Placeholder — replace with your Supabase anon key via xcconfig
        return "placeholder-anon-key"
    }

    /// PostHog API key — optional. Returns nil if not configured.
    static var posthogAPIKey: String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "POSTHOG_API_KEY") as? String,
              !value.isEmpty else {
            return nil
        }
        return value
    }

    /// Whether PostHog analytics is available for this build.
    static var isAnalyticsEnabled: Bool {
        posthogAPIKey != nil
    }
}
