import Foundation

/// A lightweight context label that can help future prioritization logic.
enum ScheduleEventContext: String, Codable, CaseIterable {
    case meeting = "Meeting"
    case focusBlock = "Focus Block"
    case travel = "Travel"
    case personal = "Personal"
    case other = "Other"
}
