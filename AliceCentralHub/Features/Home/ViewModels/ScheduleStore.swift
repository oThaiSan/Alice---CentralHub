import Foundation
import SwiftUI
import Combine

@MainActor
final class ScheduleStore: ObservableObject {
    @Published private(set) var upcomingEvents: [ScheduleEvent] = []
    @Published private(set) var isLoading = false
    @Published private(set) var lastRefreshDate: Date?
    @Published var errorMessage: String?

    private let provider: any ScheduleProviding

    init(provider: any ScheduleProviding) {
        self.provider = provider

        // Load immediately so Home can render schedule context without extra wiring.
        Task {
            await refreshUpcomingEvents()
        }
    }

    convenience init() {
        self.init(provider: ScheduleStore.makeDefaultProvider())
    }

    func refreshUpcomingEvents(limit: Int = 6) async {
        isLoading = true
        errorMessage = nil

        do {
            let events = try await provider.fetchUpcomingEvents(from: Date(), limit: limit)
            upcomingEvents = events
            lastRefreshDate = Date()
        } catch {
            upcomingEvents = []
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private static func makeDefaultProvider() -> any ScheduleProviding {
        FallbackScheduleProvider(
            primary: OutlookScheduleProvider(),
            fallback: MockScheduleProvider()
        )
    }
}
