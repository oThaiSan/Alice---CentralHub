import SwiftUI

struct KalshiDashboardView: View {
    @StateObject private var viewModel: KalshiDashboardViewModel

    @MainActor init(viewModel: KalshiDashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    @MainActor init() {
        _viewModel = StateObject(wrappedValue: KalshiDashboardViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Kalshi Agent")
                    .font(.largeTitle.weight(.bold))

                Picker("Automation Mode", selection: $viewModel.automationMode) {
                    ForEach(KalshiAutomationMode.allCases) { mode in
                        Text(mode.displayName)
                            .tag(mode)
                            .disabled(mode.isCurrentlyLocked)
                    }
                }
                .pickerStyle(.segmented)

                KalshiAgentStatusCardView(
                    mode: viewModel.automationMode,
                    statusText: viewModel.agentStatusText,
                    runSummary: viewModel.currentRun?.summary ?? "No active run",
                    openPositions: viewModel.openPositionCount,
                    todaysPnL: viewModel.todaysMockPnL,
                    riskUsage: viewModel.riskUsage
                )

                if let decision = viewModel.decision {
                    KalshiAgentDecisionCardView(decision: decision)
                }

                sectionTitle("Watched Markets")
                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ForEach(viewModel.markets) { market in
                        KalshiMarketCardView(market: market)
                    }
                }

                sectionTitle("Trade Ideas / Recommendations")
                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ForEach(viewModel.tradeIdeas) { idea in
                        KalshiTradeIdeaCardView(idea: idea)
                    }
                }

                sectionTitle("Open Paper Positions")
                LazyVGrid(columns: gridColumns, spacing: 12) {
                    ForEach(viewModel.positions) { position in
                        KalshiPositionCardView(position: position)
                    }
                }

                KalshiRiskPolicyView(policy: viewModel.riskPolicy)
                KalshiAgentActivityLogView(entries: viewModel.activityLog)
            }
            .padding(20)
        }
        .navigationTitle("Kalshi Agent")
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 280), spacing: 12, alignment: .top)
        ]
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.semibold))
    }
}

#Preview {
    NavigationStack {
        KalshiDashboardView()
    }
    .frame(minWidth: 1100, minHeight: 800)
}
