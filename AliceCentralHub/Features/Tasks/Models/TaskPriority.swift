//
//  TaskPriority.swift
//  AliceCentralHub
//
//  Created by Ethan Thai on 4/12/26.
//
//  Defines the level of priority a task is.


import Foundation

enum TaskPriority: String, CaseIterable, Codable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var id: String { rawValue }
}
