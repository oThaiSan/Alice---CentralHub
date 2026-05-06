import SwiftUI

struct KalshiRiskPolicyView: View {
    let policy: KalshiRiskPolicy

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Risk Policy")
                .font(.headline)

            Text("allowLiveTrading: \(policy.allowLiveTrading ? "true" : "false")")
            Text("requireManualApproval: \(policy.requireManualApproval ? "true" : "false")")
            Text("maxTradeDollars: \(policy.maxTradeDollars.formatted(.currency(code: "USD")))")
            Text("maxDailyLossDollars: \(policy.maxDailyLossDollars.formatted(.currency(code: "USD")))")
            Text("maxOpenExposureDollars: \(policy.maxOpenExposureDollars.formatted(.currency(code: "USD")))")
        }
        .font(.subheadline)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
