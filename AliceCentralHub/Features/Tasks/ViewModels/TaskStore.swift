//
//  TaskStore.swift
//  AliceCentralHub
//
//  Created by Ethan Thai on 4/12/26.
//
//  This is the View Model part of the MVVM design pattern

import Foundation
import Combine
import SwiftUI

@MainActor
final class TaskStore: ObservableObject {
    @Published var tasks: [TaskItem] = []

    private let storageURL: URL
    private let calendar = Calendar.current

    init(fileURL: URL? = nil) {
        self.storageURL = fileURL ?? FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("tasks.json")
        loadTasks()
    }

    /// Creates a new task after validating and normalizing user input.
    @discardableResult
    func addTask(
        title: String,
        description: String = "",
        dueDate: Date? = nil,
        priority: TaskPriority = .medium,
        status: TaskStatus = .todo,
        source: TaskSource = .manual,
        category: TaskCategory? = nil
    ) -> Bool {
        guard let normalizedTitle = normalizedTitle(from: title) else {
            return false
        }

        let normalizedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let now = Date()
        let newTask = TaskItem(
            title: normalizedTitle,
            description: normalizedDescription,
            status: status,
            priority: priority,
            dueDate: normalizedDueDate(from: dueDate),
            createdAt: now,
            updatedAt: now,
            source: source,
            category: category
        )

        tasks.append(newTask)
        saveTasks()
        return true
    }

    /// Updates a task from a full payload. We still validate title and always touch `updatedAt`.
    @discardableResult
    func updateTask(_ updatedTask: TaskItem) -> Bool {
        guard let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) else {
            return false
        }

        guard let normalizedTitle = normalizedTitle(from: updatedTask.title) else {
            return false
        }

        var taskToSave = updatedTask
        taskToSave.title = normalizedTitle
        taskToSave.description = updatedTask.description.trimmingCharacters(in: .whitespacesAndNewlines)
        taskToSave.updatedAt = Date()

        tasks[index] = taskToSave
        saveTasks()
        return true
    }

    /// Preferred edit API for views so business rules stay in the store/service layer.
    @discardableResult
    func updateTask(
        id: UUID,
        title: String,
        description: String,
        dueDate: Date?,
        priority: TaskPriority,
        status: TaskStatus,
        source: TaskSource,
        category: TaskCategory?
    ) -> Bool {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            return false
        }

        guard let normalizedTitle = normalizedTitle(from: title) else {
            return false
        }

        tasks[index].title = normalizedTitle
        tasks[index].description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        tasks[index].dueDate = normalizedDueDate(from: dueDate)
        tasks[index].priority = priority
        tasks[index].status = status
        tasks[index].source = source
        tasks[index].category = category
        tasks[index].updatedAt = Date()
        saveTasks()
        return true
    }

    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }

    /// Deletes by model instance.
    func deleteTask(_ task: TaskItem) {
        _ = deleteTask(id: task.id)
    }

    /// Deletes by id so future call sites do not need the full model object.
    @discardableResult
    func deleteTask(id: UUID) -> Bool {
        let previousCount = tasks.count
        tasks.removeAll { $0.id == id }
        let didDelete = tasks.count != previousCount

        if didDelete {
            saveTasks()
        }

        return didDelete
    }

    /// Reorders tasks in the same list and updates `updatedAt` for moved tasks.
    func moveTask(from source: IndexSet, to destination: Int) {
        let movedTaskIDs: [UUID] = source.compactMap { index in
            guard tasks.indices.contains(index) else { return nil }
            return tasks[index].id
        }

        tasks.move(fromOffsets: source, toOffset: destination)

        let now = Date()
        for id in movedTaskIDs {
            guard let index = tasks.firstIndex(where: { $0.id == id }) else { continue }
            tasks[index].updatedAt = now
        }

        saveTasks()
    }

    func tasks(for status: TaskStatus) -> [TaskItem] {
        tasks.filter { $0.status == status }
    }

    /// Lightweight search + status + category filtering used by list screens.
    func tasks(
        matchingTitle query: String,
        status: TaskStatus? = nil,
        categoryFilter: TaskCategoryFilter = .all
    ) -> [TaskItem] {
        tasks.filter { task in
            if let status, task.status != status {
                return false
            }

            return matchesTask(task, searchQuery: query, categoryFilter: categoryFilter)
        }
    }

    /// Unified "Overall" list for all tasks regardless of status.
    /// Sorting keeps actionable items near the top while still showing done work.
    func overallTasks(searchQuery: String = "", categoryFilter: TaskCategoryFilter = .all) -> [TaskItem] {
        tasks
            .filter { matchesTask($0, searchQuery: searchQuery, categoryFilter: categoryFilter) }
            .sorted { lhs, rhs in
                if lhs.status == .done && rhs.status != .done { return false }
                if lhs.status != .done && rhs.status == .done { return true }

                switch (lhs.dueDate, rhs.dueDate) {
                case let (lhsDate?, rhsDate?):
                    return lhsDate < rhsDate
                case (_?, nil):
                    return true
                case (nil, _?):
                    return false
                case (nil, nil):
                    return lhs.updatedAt > rhs.updatedAt
                }
            }
    }

    /// Overdue + due today, excluding completed tasks for execution focus.
    func todayTasks(
        referenceDate: Date = Date(),
        searchQuery: String = "",
        categoryFilter: TaskCategoryFilter = .all
    ) -> [TaskItem] {
        let endOfToday = calendar.date(
            byAdding: DateComponents(day: 1, second: -1),
            to: calendar.startOfDay(for: referenceDate)
        ) ?? referenceDate

        return tasks
            .filter { task in
                guard task.status != .done, let dueDate = task.dueDate else { return false }
                guard dueDate <= endOfToday else { return false }

                return matchesTask(task, searchQuery: searchQuery, categoryFilter: categoryFilter)
            }
            .sorted { lhs, rhs in
                guard let lhsDate = lhs.dueDate, let rhsDate = rhs.dueDate else { return false }
                return lhsDate < rhsDate
            }
    }

    /// Tasks due after today through the configured number of future days.
    func upcomingTasks(
        daysAhead: Int = 7,
        referenceDate: Date = Date(),
        searchQuery: String = "",
        categoryFilter: TaskCategoryFilter = .all
    ) -> [TaskItem] {
        let startOfTomorrow = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: referenceDate)
        ) ?? referenceDate
        let endDate = calendar.date(byAdding: .day, value: daysAhead, to: startOfTomorrow) ?? startOfTomorrow

        return tasks
            .filter { task in
                guard task.status != .done, let dueDate = task.dueDate else { return false }
                guard dueDate >= startOfTomorrow && dueDate < endDate else { return false }

                return matchesTask(task, searchQuery: searchQuery, categoryFilter: categoryFilter)
            }
            .sorted { lhs, rhs in
                guard let lhsDate = lhs.dueDate, let rhsDate = rhs.dueDate else { return false }
                return lhsDate < rhsDate
            }
    }
    
    /// Handles drag/drop status changes and keeps `updatedAt` in sync.
    @discardableResult
    func moveTask(_ taskID: UUID, to newStatus: TaskStatus) -> Bool {
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else {
            return false
        }

        if tasks[index].status == newStatus {
            return false
        }

        tasks[index].status = newStatus
        tasks[index].updatedAt = Date()
        saveTasks()
        return true
    }

    /// Persists to local JSON in Documents so data survives app relaunches.
    func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Error saving tasks: \(error.localizedDescription)")
        }
    }

    /// Loads persisted tasks at startup. If migration fails, we recover with an empty list.
    func loadTasks() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            tasks = []
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            tasks = try JSONDecoder().decode([TaskItem].self, from: data)
        } catch {
            print("Error loading tasks: \(error.localizedDescription)")
            tasks = []
        }
    }

    /// Centralized predicate to keep search/category rules out of the view layer.
    private func matchesTask(_ task: TaskItem, searchQuery: String, categoryFilter: TaskCategoryFilter) -> Bool {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedQuery.isEmpty && !task.title.localizedCaseInsensitiveContains(trimmedQuery) {
            return false
        }

        switch categoryFilter {
        case .all:
            return true
        case .work:
            return task.category == .work
        case .personal:
            // Legacy tasks may not have a category yet. We treat nil as Personal
            // so older data remains visible when users focus on personal work.
            guard let category = task.category else { return true }
            return category != .work
        }
    }

    private func normalizedTitle(from rawTitle: String) -> String? {
        let trimmedTitle = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedTitle.isEmpty ? nil : trimmedTitle
    }

    private func normalizedDueDate(from dueDate: Date?) -> Date? {
        guard let dueDate else { return nil }

        // Due dates are date-only in the UI, so normalize to local noon to avoid day drift.
        let components = calendar.dateComponents([.year, .month, .day], from: dueDate)
        return calendar.date(from: DateComponents(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: 12
        )) ?? dueDate
    }

    private var fileURL: URL {
        storageURL
    }
}
