import Foundation

/// Separate model for schedule items so we never force events into TaskItem.
struct ScheduleEvent: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let startDate: Date
    let endDate: Date
    let source: ScheduleEventSource
    let location: String?
    let details: String?
    let context: ScheduleEventContext?

    init(
        id: UUID = UUID(),
        title: String,
        startDate: Date,
        endDate: Date,
        source: ScheduleEventSource,
        location: String? = nil,
        details: String? = nil,
        context: ScheduleEventContext? = nil
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.source = source
        self.location = location
        self.details = details
        self.context = context
    }
}
