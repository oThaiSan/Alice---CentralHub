import SwiftUI

struct KalshiPositionCardView: View {
    let position: KalshiPosition

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(position.marketTicker)
                .font(.headline)

            HStack {
                Text("Side: \(position.side.displayName)")
                Spacer()
                Text("Contracts: \(position.contracts)")
            }
            .font(.subheadline)

            HStack {
                Text("Entry: \(priceString(position.entryPrice))")
                Spacer()
                Text("Current: \(priceString(position.currentPrice))")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text("Unrealized P/L: \(position.unrealizedPnL.formatted(.currency(code: "USD")))")
                .font(.subheadline.weight(.semibold))

            Text("Status: \(position.status.displayName)")
                .font(.caption.weight(.medium))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func priceString(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(2)))
    }
}
