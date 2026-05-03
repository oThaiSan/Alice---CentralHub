//
//  TaskItem.swift
//  AliceCentralHub
//
//  Created by Ethan Thai on 4/12/26.
//
//  This is the Model part of the MVVM design pattern

import Foundation

struct TaskItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var status: TaskStatus
    var priority: TaskPriority
    var dueDate: Date?
    let createdAt: Date
    var updatedAt: Date
    var source: TaskSource
    var category: TaskCategory?

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        status: TaskStatus = .todo,
        priority: TaskPriority = .medium,
        dueDate: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date? = nil,
        source: TaskSource = .manual,
        category: TaskCategory? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.priority = priority
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt
        self.source = source
        self.category = category
    }
}

// MARK: - Codable Migration Support
extension TaskItem {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case status
        case priority
        case dueDate
        case createdAt
        case updatedAt
        case source
        case category
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        status = try container.decode(TaskStatus.self, forKey: .status)
        priority = try container.decode(TaskPriority.self, forKey: .priority)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()

        // Keep older persisted payloads compatible by backfilling new fields.
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? createdAt
        source = try container.decodeIfPresent(TaskSource.self, forKey: .source) ?? .manual
        category = try container.decodeIfPresent(TaskCategory.self, forKey: .category)
    }
}
