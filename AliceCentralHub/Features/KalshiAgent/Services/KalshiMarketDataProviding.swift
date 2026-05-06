import Foundation

protocol KalshiMarketDataProviding {
    func loadMarkets() -> [KalshiMarket]
    func loadTradeIdeas() -> [KalshiTradeIdea]
    func loadPaperPositions() -> [KalshiPosition]
    func loadAgentDecision() -> KalshiAgentDecision
    func loadAgentRun() -> KalshiAgentRun
    func loadActivityLog() -> [KalshiAgentActivity]
    func loadRiskPolicy() -> KalshiRiskPolicy
}
