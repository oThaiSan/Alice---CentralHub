import SwiftUI

struct KalshiAgentDecisionCardView: View {
    let decision: KalshiAgentDecision

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current Agent Decision")
                .font(.headline)

            Text("Recommendation: \(decision.recommendation.displayName)")
                .font(.subheadline.weight(.semibold))
            Text("Confidence: \(Int(decision.confidence * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(decision.reasoning)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)

            Text("Proposed Action: \(decision.proposedAction)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(decision.approvalRequired ? "Approval Required" : "Approval Not Required")
                .font(.caption.weight(.medium))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
