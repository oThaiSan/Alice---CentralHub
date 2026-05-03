import Foundation

/// Read-only Microsoft Graph provider for work calendar events.
///
/// This provider is intentionally lightweight for Sprint 4:
/// - If no access token is available, it reports `notConfigured`.
/// - If a token is provided, it can read upcoming events from `/me/calendarView`.
///
/// Production follow-up should move token handling into a dedicated auth service.
struct OutlookScheduleProvider: ScheduleProviding {
    let providerName = "Outlook Work Calendar"

    /// Temporary token injection point for development.
    /// In a full implementation this should come from secure auth state.
    private let accessToken: String?

    init(accessToken: String? = nil) {
        self.accessToken = accessToken
    }

    func fetchUpcomingEvents(from startDate: Date, limit: Int) async throws -> [ScheduleEvent] {
        guard let accessToken, !accessToken.isEmpty else {
            throw ScheduleProviderError.notConfigured(
                "Outlook is not connected yet. Configure Microsoft auth and pass a valid Graph access token."
            )
        }

        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? startDate
        let request = try makeRequest(startDate: startDate, endDate: endDate, limit: limit, accessToken: accessToken)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ScheduleProviderError.unavailable("Outlook calendar request failed. Verify token scopes and account permissions.")
        }

        let decoded = try JSONDecoder().decode(OutlookCalendarViewResponse.self, from: data)
        let mappedEvents = decoded.value.compactMap(Self.mapGraphEvent)
        return Array(mappedEvents.sorted { $0.startDate < $1.startDate }.prefix(limit))
    }

    private func makeRequest(startDate: Date, endDate: Date, limit: Int, accessToken: String) throws -> URLRequest {
        var components = URLComponents(string: "https://graph.microsoft.com/v1.0/me/calendarView")
        components?.queryItems = [
            URLQueryItem(name: "startDateTime", value: Self.iso8601Formatter.string(from: startDate)),
            URLQueryItem(name: "endDateTime", value: Self.iso8601Formatter.string(from: endDate)),
            URLQueryItem(name: "$top", value: String(limit))
        ]

        guard let url = components?.url else {
            throw ScheduleProviderError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private static func mapGraphEvent(_ graphEvent: OutlookEventDTO) -> ScheduleEvent? {
        guard
            let startDate = parseGraphDateTime(graphEvent.start),
            let endDate = parseGraphDateTime(graphEvent.end)
        else {
            return nil
        }

        let locationName = graphEvent.location?.displayName?.trimmingCharacters(in: .whitespacesAndNewlines)

        return ScheduleEvent(
            title: graphEvent.subject ?? "Untitled Event",
            startDate: startDate,
            endDate: endDate,
            source: .outlookWorkCalendar,
            location: (locationName?.isEmpty == false) ? locationName : nil,
            details: graphEvent.bodyPreview,
            context: .meeting
        )
    }

    private static func parseGraphDateTime(_ graphDateTime: GraphDateTimeDTO?) -> Date? {
        guard let graphDateTime, let dateTimeString = graphDateTime.dateTime else {
            return nil
        }

        // Graph usually returns ISO-8601 style date strings.
        if let parsed = iso8601Formatter.date(from: dateTimeString) {
            return parsed
        }

        // Some payloads omit timezone offsets, so we parse using the provided time zone.
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: graphDateTime.timeZone ?? "UTC")
        return formatter.date(from: dateTimeString)
    }

    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

private struct OutlookCalendarViewResponse: Decodable {
    let value: [OutlookEventDTO]
}

private struct OutlookEventDTO: Decodable {
    let subject: String?
    let bodyPreview: String?
    let start: GraphDateTimeDTO?
    let end: GraphDateTimeDTO?
    let location: OutlookLocationDTO?
}

private struct GraphDateTimeDTO: Decodable {
    let dateTime: String?
    let timeZone: String?
}

private struct OutlookLocationDTO: Decodable {
    let displayName: String?
}
