//
//  AliceCentralHubTests.swift
//  AliceCentralHubTests
//
//  Created by Ethan Thai on 4/11/26.
//

import Foundation
import Testing
@testable import AliceCentralHub

struct AliceCentralHubTests {

    @MainActor
    @Test("Due dates persist for nil, yesterday, today, and future after reload")
    func dueDatePersistenceAcrossReload() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tasks-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let futureDate = calendar.date(byAdding: .day, value: 5, to: today)!

        let store = TaskStore(fileURL: fileURL)
        #expect(store.addTask(title: "No Due Date", dueDate: nil))
        #expect(store.addTask(title: "Yesterday Due", dueDate: yesterday))
        #expect(store.addTask(title: "Today Due", dueDate: today))
        #expect(store.addTask(title: "Future Due", dueDate: futureDate))

        // Simulate app relaunch by creating a new store that reads the same file.
        let reloadedStore = TaskStore(fileURL: fileURL)
        let tasksByTitle = Dictionary(uniqueKeysWithValues: reloadedStore.tasks.map { ($0.title, $0) })

        #expect(tasksByTitle["No Due Date"]?.dueDate == nil)

        if let persistedYesterday = tasksByTitle["Yesterday Due"]?.dueDate {
            #expect(calendar.isDate(persistedYesterday, inSameDayAs: yesterday))
        } else {
            Issue.record("Expected yesterday due date to persist")
        }

        if let persistedToday = tasksByTitle["Today Due"]?.dueDate {
            #expect(calendar.isDate(persistedToday, inSameDayAs: today))
        } else {
            Issue.record("Expected today due date to persist")
        }

        if let persistedFuture = tasksByTitle["Future Due"]?.dueDate {
            #expect(calendar.isDate(persistedFuture, inSameDayAs: futureDate))
        } else {
            Issue.record("Expected future due date to persist")
        }
    }

    @MainActor
    @Test("Today and upcoming buckets classify tasks by due date")
    func taskExecutionBuckets() throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tasks-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let today = now
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        let inThreeDays = calendar.date(byAdding: .day, value: 3, to: now)!

        let store = TaskStore(fileURL: fileURL)
        #expect(store.addTask(title: "Overdue", dueDate: yesterday))
        #expect(store.addTask(title: "Due Today", dueDate: today))
        #expect(store.addTask(title: "Due Tomorrow", dueDate: tomorrow))
        #expect(store.addTask(title: "Due In Three", dueDate: inThreeDays))

        let todayTitles = Set(store.todayTasks(referenceDate: now).map(\.title))
        #expect(todayTitles.contains("Overdue"))
        #expect(todayTitles.contains("Due Today"))
        #expect(!todayTitles.contains("Due Tomorrow"))

        let upcomingTitles = Set(store.upcomingTasks(daysAhead: 7, referenceDate: now).map(\.title))
        #expect(!upcomingTitles.contains("Overdue"))
        #expect(!upcomingTitles.contains("Due Today"))
        #expect(upcomingTitles.contains("Due Tomorrow"))
        #expect(upcomingTitles.contains("Due In Three"))
    }
}
