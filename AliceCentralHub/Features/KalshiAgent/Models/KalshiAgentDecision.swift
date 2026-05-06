import Foundation

struct KalshiAgentDecision: Identifiable, Hashable {
    enum Recommendation: String, CaseIterable, Codable {
        case buyYes
        case buyNo
        case hold
        case avoid

        var displayName: String {
            switch self {
            case .buyYes:
                return "Buy YES"
            case .buyNo:
                return "Buy NO"
            case .hold:
                return "Hold"
            case .avoid:
                return "Avoid"
            }
        }
    }

    let id: UUID
    let recommendation: Recommendation
    let confidence: Double
    let reasoning: String
    let proposedAction: String
    let approvalRequired: Bool
}
