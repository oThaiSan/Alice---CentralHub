//
//  TaskSource.swift
//  AliceCentralHub
//
//  Created by Ethan Thai on 4/18/26.
//
//  Describes how a task entered the system.

import Foundation

enum TaskSource: String, CaseIterable, Codable, Identifiable {
    case manual = "Manual"
    case imported = "Imported"
    case automation = "Automation"

    var id: String { rawValue }
}
