//
//  TaskCategory.swift
//  AliceCentralHub
//
//  Created by Ethan Thai on 4/18/26.
//
//  Optional grouping for tasks. Keep this lightweight for now.

import Foundation

enum TaskCategory: String, CaseIterable, Codable, Identifiable {
    case personal = "Personal"
    case work = "Work"
    case finance = "Finance"
    case health = "Health"
    case errands = "Errands"

    var id: String { rawValue }
}

/// User-facing filter used by task screens.
/// We intentionally keep this smaller than `TaskCategory` so the UI stays simple.
enum TaskCategoryFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case work = "Work"
    case personal = "Personal"

    var id: String { rawValue }
}

/// Narrow category control used in creation/edit flows.
/// We keep this focused on life-context instead of every technical bucket.
enum TaskLifeContext: String, CaseIterable, Identifiable {
    case personal = "Personal"
    case work = "Work"

    var id: String { rawValue }

    init(taskCategory: TaskCategory?) {
        self = taskCategory == .work ? .work : .personal
    }

    var taskCategoryValue: TaskCategory {
        switch self {
        case .personal:
            return .personal
        case .work:
            return .work
        }
    }
}
