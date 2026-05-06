import SwiftUI

struct KalshiAgentActivityLogView: View {
    let entries: [KalshiAgentActivity]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Agent Activity Log")
                .font(.headline)

            ForEach(entries) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(entry.title)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(entry.timestamp, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(entry.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(entry.type.displayName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
