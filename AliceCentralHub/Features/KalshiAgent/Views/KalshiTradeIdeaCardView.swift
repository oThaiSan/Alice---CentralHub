import SwiftUI

struct KalshiTradeIdeaCardView: View {
    let idea: KalshiTradeIdea

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(idea.marketTitle)
                .font(.headline)
            Text(idea.marketTicker)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text("Action: \(idea.proposedAction.displayName)")
                Spacer()
                Text("Target: \(idea.targetPrice.formatted(.number.precision(.fractionLength(2))))")
            }
            .font(.subheadline)

            Text("Confidence: \(Int(idea.confidence * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(idea.thesis)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Status: \(idea.status.displayName)")
                .font(.caption.weight(.medium))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
