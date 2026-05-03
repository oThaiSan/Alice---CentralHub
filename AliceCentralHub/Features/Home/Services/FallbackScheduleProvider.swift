import Foundation

/// Tries a primary provider first (Outlook), then falls back to a safer local provider.
struct FallbackScheduleProvider: ScheduleProviding {
    let providerName = "Primary + Fallback"

    private let primary: any ScheduleProviding
    private let fallback: any ScheduleProviding

    init(primary: any ScheduleProviding, fallback: any ScheduleProviding) {
        self.primary = primary
        self.fallback = fallback
    }

    func fetchUpcomingEvents(from startDate: Date, limit: Int) async throws -> [ScheduleEvent] {
        do {
            return try await primary.fetchUpcomingEvents(from: startDate, limit: limit)
        } catch ScheduleProviderError.notConfigured,
                ScheduleProviderError.unavailable {
            // Expected integration-stage failures should not break the app.
            return try await fallback.fetchUpcomingEvents(from: startDate, limit: limit)
        }
    }
}
