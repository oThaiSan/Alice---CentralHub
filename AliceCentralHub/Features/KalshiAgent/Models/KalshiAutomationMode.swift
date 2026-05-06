import Foundation

enum KalshiAutomationMode: String, CaseIterable, Identifiable, Codable {
    case researchOnly
    case paperTrading
    case demoTrading
    case liveManualApproval
    case liveAutonomousLimited

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .researchOnly:
            return "Research Only"
        case .paperTrading:
            return "Paper Trading"
        case .demoTrading:
            return "Demo Trading"
        case .liveManualApproval:
            return "Live (Manual Approval)"
        case .liveAutonomousLimited:
            return "Live Autonomous (Limited)"
        }
    }

    var isCurrentlyLocked: Bool {
        self == .liveAutonomousLimited
    }
}
