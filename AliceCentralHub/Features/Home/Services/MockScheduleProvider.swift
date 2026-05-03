import Foundation

/// Local development provider so the schedule UI works even before real integrations are connected.
struct MockScheduleProvider: ScheduleProviding {
    let providerName = "Mock Schedule"

    func fetchUpcomingEvents(from startDate: Date, limit: Int) async throws -> [ScheduleEvent] {
        let calendar = Calendar.current
        let startOfHour = calendar.dateInterval(of: .hour, for: startDate)?.start ?? startDate

        let events = [
            ScheduleEvent(
                title: "Daily Work Planning",
                startDate: calendar.date(byAdding: .minute, value: 30, to: startOfHour) ?? startOfHour,
                endDate: calendar.date(byAdding: .minute, value: 60, to: startOfHour) ?? startOfHour,
                source: .mock,
                location: "Desk",
                details: "Review priorities and sequence deep work blocks.",
                context: .focusBlock
            ),
            ScheduleEvent(
                title: "Team Standup",
                startDate: calendar.date(byAdding: .hour, value: 2, to: startOfHour) ?? startOfHour,
                endDate: calendar.date(byAdding: .hour, value: 3, to: startOfHour) ?? startOfHour,
                source: .mock,
                location: "Zoom",
                details: "Share blockers and upcoming delivery risks.",
                context: .meeting
            ),
            ScheduleEvent(
                title: "Stakeholder Sync",
                startDate: calendar.date(byAdding: .hour, value: 5, to: startOfHour) ?? startOfHour,
                endDate: calendar.date(byAdding: .hour, value: 6, to: startOfHour) ?? startOfHour,
                source: .mock,
                location: "Conference Room A",
                details: "Walk through sprint outcomes and next priorities.",
                context: .meeting
            )
        ]

        return Array(events.sorted { $0.startDate < $1.startDate }.prefix(limit))
    }
}
