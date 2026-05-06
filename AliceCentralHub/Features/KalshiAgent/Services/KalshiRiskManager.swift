import Foundation

struct KalshiRiskManager {
    let policy: KalshiRiskPolicy

    func canOpenPaperPosition(estimatedCost: Double, totalOpenExposure: Double) -> Bool {
        guard estimatedCost <= policy.maxTradeDollars else { return false }
        guard totalOpenExposure + estimatedCost <= policy.maxOpenExposureDollars else { return false }
        return true
    }

    func remainingExposure(after totalOpenExposure: Double) -> Double {
        max(policy.maxOpenExposureDollars - totalOpenExposure, 0)
    }

    func riskUsage(openExposure: Double) -> Double {
        guard policy.maxOpenExposureDollars > 0 else { return 0 }
        return min(openExposure / policy.maxOpenExposureDollars, 1)
    }
}
