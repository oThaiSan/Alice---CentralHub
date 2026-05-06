import Foundation

struct KalshiAgentRun: Identifiable, Hashable {
    enum Status: String, CaseIterable, Codable {
        case idle
        case running
        case completed
        case paused

        var displayName: String {
            rawValue.capitalized
        }
    }

    let id: UUID
    let status: Status
    let summary: String
    let startedAt: Date
    let lastUpdatedAt: Date
}
