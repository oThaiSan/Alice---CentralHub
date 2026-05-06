import Foundation

struct KalshiAgentActivity: Identifiable, Hashable {
    enum ActivityType: String, CaseIterable, Codable {
        case scan
        case opportunity
        case rejection
        case idea
        case position

        var displayName: String {
            rawValue.capitalized
        }
    }

    let id: UUID
    let timestamp: Date
    let title: String
    let detail: String
    let type: ActivityType
}
