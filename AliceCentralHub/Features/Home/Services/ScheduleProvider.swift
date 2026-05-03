import Foundation

/// Common contract for any source that can return work schedule events.
protocol ScheduleProviding {
    var providerName: String { get }

    /// Fetches upcoming events ordered by time.
    func fetchUpcomingEvents(from startDate: Date, limit: Int) async throws -> [ScheduleEvent]
}

enum ScheduleProviderError: LocalizedError {
    case notConfigured(String)
    case unavailable(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .notConfigured(let message):
            return message
        case .unavailable(let message):
            return message
        case .invalidResponse:
            return "The schedule provider returned data in an unexpected format."
        }
    }
}
