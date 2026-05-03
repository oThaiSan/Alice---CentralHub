import Foundation

/// Identifies where a schedule event came from so the UI can show trust/source context.
enum ScheduleEventSource: String, Codable, CaseIterable {
    case outlookWorkCalendar = "Outlook Work Calendar"
    case slackSignal = "Slack Signal"
    case mock = "Mock"
}
