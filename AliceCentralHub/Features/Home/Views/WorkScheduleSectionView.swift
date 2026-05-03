import SwiftUI

struct WorkScheduleSectionView: View {
    @ObservedObject var scheduleStore: ScheduleStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Work Schedule")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    Task {
                        await scheduleStore.refreshUpcomingEvents()
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            }

            if scheduleStore.isLoading && scheduleStore.upcomingEvents.isEmpty {
                ProgressView("Loading events...")
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if scheduleStore.upcomingEvents.isEmpty {
                Text("No upcoming work events.")
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(scheduleStore.upcomingEvents) { event in
                        scheduleEventRow(event)
                    }
                }
            }

            if let errorMessage = scheduleStore.errorMessage {
                Text("Provider Note: \(errorMessage)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.gray.opacity(0.18), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func scheduleEventRow(_ event: ScheduleEvent) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.title)
                .font(.headline)

            HStack(spacing: 8) {
                Text(timeRangeText(for: event))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(event.source.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.gray.opacity(0.12))
                    .clipShape(Capsule())
            }

            if let location = event.location, !location.isEmpty {
                Text("Location: \(location)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let details = event.details, !details.isEmpty {
                Text(details)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 6)
    }

    private func timeRangeText(for event: ScheduleEvent) -> String {
        "\(event.startDate.formatted(date: .abbreviated, time: .shortened)) - \(event.endDate.formatted(date: .omitted, time: .shortened))"
    }
}

#Preview {
    WorkScheduleSectionView(scheduleStore: ScheduleStore(provider: MockScheduleProvider()))
        .padding()
}
