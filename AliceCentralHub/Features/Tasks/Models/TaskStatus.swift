//
//  TaskStatus.swift
//  AliceCentralHub
//
//  Created by Ethan Thai on 4/12/26.
//
//  Defines the different statuses a task could be in.

import Foundation

enum TaskStatus: String, CaseIterable, Codable, Identifiable {
    case todo = "To Do"
    case inProgress = "In Progress"
    case blocked = "Blocked"
    case done = "Done"

    var id: String { rawValue }
}
