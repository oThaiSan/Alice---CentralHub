import Foundation

struct KalshiRiskPolicy: Hashable {
    let allowLiveTrading: Bool
    let requireManualApproval: Bool
    let maxTradeDollars: Double
    let maxDailyLossDollars: Double
    let maxOpenExposureDollars: Double
}
