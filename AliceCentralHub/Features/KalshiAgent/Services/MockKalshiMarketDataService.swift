import Foundation

struct MockKalshiMarketDataService: KalshiMarketDataProviding {
    private let now = Date()

    func loadMarkets() -> [KalshiMarket] {
        [
            KalshiMarket(
                id: UUID(),
                ticker: "CPIAPR-26",
                title: "US CPI YoY above 3.2% in April 2026?",
                category: "Macro",
                yesPrice: 0.41,
                noPrice: 0.59,
                volume: 184_500,
                closeDate: Calendar.current.date(byAdding: .day, value: 11, to: now) ?? now,
                status: .open
            ),
            KalshiMarket(
                id: UUID(),
                ticker: "FEDHIKE-JUN26",
                title: "Federal Reserve rate hike by June 2026?",
                category: "Rates",
                yesPrice: 0.28,
                noPrice: 0.72,
                volume: 96_230,
                closeDate: Calendar.current.date(byAdding: .day, value: 39, to: now) ?? now,
                status: .open
            ),
            KalshiMarket(
                id: UUID(),
                ticker: "JOBS-MAY26",
                title: "US payrolls above 220k in May 2026?",
                category: "Labor",
                yesPrice: 0.64,
                noPrice: 0.36,
                volume: 71_009,
                closeDate: Calendar.current.date(byAdding: .day, value: 24, to: now) ?? now,
                status: .paused
            )
        ]
    }

    func loadTradeIdeas() -> [KalshiTradeIdea] {
        [
            KalshiTradeIdea(
                id: UUID(),
                marketTicker: "CPIAPR-26",
                marketTitle: "US CPI YoY above 3.2% in April 2026?",
                proposedAction: .buyNo,
                targetPrice: 0.60,
                confidence: 0.66,
                thesis: "Recent disinflation trend remains intact unless energy surprises sharply.",
                status: .paperTradeCandidate
            ),
            KalshiTradeIdea(
                id: UUID(),
                marketTicker: "FEDHIKE-JUN26",
                marketTitle: "Federal Reserve rate hike by June 2026?",
                proposedAction: .hold,
                targetPrice: 0.30,
                confidence: 0.54,
                thesis: "FOMC language is mixed; signal quality is still weak.",
                status: .needsReview
            ),
            KalshiTradeIdea(
                id: UUID(),
                marketTicker: "JOBS-MAY26",
                marketTitle: "US payrolls above 220k in May 2026?",
                proposedAction: .buyYes,
                targetPrice: 0.62,
                confidence: 0.49,
                thesis: "Momentum supports upside, but liquidity is below preferred threshold.",
                status: .watchlist
            )
        ]
    }

    func loadPaperPositions() -> [KalshiPosition] {
        [
            KalshiPosition(
                id: UUID(),
                marketTicker: "CPIAPR-26",
                side: .no,
                contracts: 30,
                entryPrice: 0.57,
                currentPrice: 0.60,
                unrealizedPnL: 90.0,
                status: .open
            ),
            KalshiPosition(
                id: UUID(),
                marketTicker: "FEDHIKE-JUN26",
                side: .yes,
                contracts: 20,
                entryPrice: 0.24,
                currentPrice: 0.28,
                unrealizedPnL: 80.0,
                status: .open
            )
        ]
    }

    func loadAgentDecision() -> KalshiAgentDecision {
        KalshiAgentDecision(
            id: UUID(),
            recommendation: .buyNo,
            confidence: 0.66,
            reasoning: "CPI nowcasts and recent base effects favor downside surprise risk.",
            proposedAction: "Open paper position: NO on CPIAPR-26 at <= 0.60",
            approvalRequired: true
        )
    }

    func loadAgentRun() -> KalshiAgentRun {
        KalshiAgentRun(
            id: UUID(),
            status: .running,
            summary: "Scanned 18 markets, shortlisted 4, produced 1 high-confidence recommendation.",
            startedAt: Calendar.current.date(byAdding: .minute, value: -26, to: now) ?? now,
            lastUpdatedAt: Calendar.current.date(byAdding: .minute, value: -2, to: now) ?? now
        )
    }

    func loadActivityLog() -> [KalshiAgentActivity] {
        [
            KalshiAgentActivity(
                id: UUID(),
                timestamp: Calendar.current.date(byAdding: .minute, value: -3, to: now) ?? now,
                title: "Updated paper position",
                detail: "CPIAPR-26 unrealized P/L moved to +$90.00",
                type: .position
            ),
            KalshiAgentActivity(
                id: UUID(),
                timestamp: Calendar.current.date(byAdding: .minute, value: -8, to: now) ?? now,
                title: "Created paper trade idea",
                detail: "Suggested NO at 0.60 for CPIAPR-26",
                type: .idea
            ),
            KalshiAgentActivity(
                id: UUID(),
                timestamp: Calendar.current.date(byAdding: .minute, value: -14, to: now) ?? now,
                title: "Rejected low-liquidity market",
                detail: "Skipped a labor market due to volume threshold",
                type: .rejection
            ),
            KalshiAgentActivity(
                id: UUID(),
                timestamp: Calendar.current.date(byAdding: .minute, value: -21, to: now) ?? now,
                title: "Flagged opportunity",
                detail: "CPIAPR-26 divergence between implied odds and macro inputs",
                type: .opportunity
            ),
            KalshiAgentActivity(
                id: UUID(),
                timestamp: Calendar.current.date(byAdding: .minute, value: -29, to: now) ?? now,
                title: "Scanned markets",
                detail: "Parsed 18 macro and rates event contracts",
                type: .scan
            )
        ]
    }

    func loadRiskPolicy() -> KalshiRiskPolicy {
        KalshiRiskPolicy(
            allowLiveTrading: false,
            requireManualApproval: true,
            maxTradeDollars: 500,
            maxDailyLossDollars: 300,
            maxOpenExposureDollars: 2_000
        )
    }
}
