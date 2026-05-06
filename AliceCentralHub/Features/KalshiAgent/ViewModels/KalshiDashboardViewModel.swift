import Foundation
import Combine

@MainActor
final class KalshiDashboardViewModel: ObservableObject {
    @Published var automationMode: KalshiAutomationMode = .researchOnly
    @Published private(set) var markets: [KalshiMarket] = []
    @Published private(set) var tradeIdeas: [KalshiTradeIdea] = []
    @Published private(set) var positions: [KalshiPosition] = []
    @Published private(set) var decision: KalshiAgentDecision?
    @Published private(set) var currentRun: KalshiAgentRun?
    @Published private(set) var activityLog: [KalshiAgentActivity] = []
    @Published private(set) var riskPolicy: KalshiRiskPolicy

    private let dataProvider: KalshiMarketDataProviding

    init(dataProvider: KalshiMarketDataProviding) {
        self.dataProvider = dataProvider
        self.riskPolicy = dataProvider.loadRiskPolicy()
        reload()
    }

    convenience init() {
        self.init(dataProvider: MockKalshiMarketDataService())
    }

    func reload() {
        markets = dataProvider.loadMarkets()
        tradeIdeas = dataProvider.loadTradeIdeas()
        positions = dataProvider.loadPaperPositions()
        decision = dataProvider.loadAgentDecision()
        currentRun = dataProvider.loadAgentRun()
        activityLog = dataProvider.loadActivityLog()
    }

    var openPositionCount: Int {
        positions.filter { $0.status == .open }.count
    }

    var todaysMockPnL: Double {
        positions.reduce(0) { $0 + $1.unrealizedPnL }
    }

    var openExposure: Double {
        positions.reduce(0) { partial, position in
            partial + (Double(position.contracts) * position.currentPrice)
        }
    }

    var riskUsage: Double {
        KalshiRiskManager(policy: riskPolicy).riskUsage(openExposure: openExposure)
    }

    var agentStatusText: String {
        currentRun?.status.displayName ?? "Unknown"
    }
}
