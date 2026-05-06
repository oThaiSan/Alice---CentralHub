import SwiftUI

struct KalshiAgentStatusCardView: View {
    let mode: KalshiAutomationMode
    let statusText: String
    let runSummary: String
    let openPositions: Int
    let todaysPnL: Double
    let riskUsage: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Agent Overview")
                .font(.headline)

            HStack(spacing: 16) {
                metric(title: "Mode", value: mode.displayName)
                metric(title: "Status", value: statusText)
                metric(title: "Open Positions", value: "\(openPositions)")
            }

            HStack(spacing: 16) {
                metric(title: "Today Mock P/L", value: currencyString(todaysPnL))
                metric(title: "Risk Usage", value: "\(Int(riskUsage * 100))%")
            }

            Text(runSummary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func currencyString(_ amount: Double) -> String {
        amount.formatted(.currency(code: "USD"))
    }
}
