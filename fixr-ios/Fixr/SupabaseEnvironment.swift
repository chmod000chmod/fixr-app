import Foundation

/// Reads Supabase and analytics configuration from Info.plist.
/// Keys are injected at build time via xcconfig — never hardcoded.
enum SupabaseEnvironment {

    /// The Supabase project URL. Crashes at launch if missing — misconfigured build.
    static var supabaseURL: URL {
        guard let rawValue = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              !rawValue.isEmpty,
              let url = URL(string: rawValue) else {
            fatalError("SUPABASE_URL is missing or invalid in Info.plist. Check your xcconfig.")
        }
        return url
    }

    /// The Supabase anon key. Crashes at launch if missing — misconfigured build.
    static var supabaseKey: String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String,
              !value.isEmpty else {
            fatalError("SUPABASE_KEY is missing in Info.plist. Check your xcconfig.")
        }
        return value
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
