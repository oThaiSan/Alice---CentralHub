import SwiftUI

struct KalshiMarketCardView: View {
    let market: KalshiMarket

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(market.title)
                .font(.headline)
            Text("\(market.ticker) • \(market.category)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text("YES: \(priceString(market.yesPrice))")
                Text("NO: \(priceString(market.noPrice))")
            }
            .font(.subheadline.weight(.semibold))

            HStack {
                Text("Volume: \(market.volume.formatted())")
                Spacer()
                Text("Closes: \(market.closeDate, style: .date)")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text("Status: \(market.status.displayName)")
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
