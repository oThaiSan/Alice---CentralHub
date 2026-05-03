//
//  TaskRowView.swift
//  AliceCentralHub
//
//  Created by Ethan Thai on 4/12/26.
//
//  Displays each task in the HomeView with the priority level and due date.

import SwiftUI

struct TaskRowView: View {
    let task: TaskItem

    private var categoryLabel: String {
        // Legacy tasks can have nil category. We show them as Personal in the UI
        // so category filtering and badges remain understandable.
        (task.category == .work ? TaskCategory.work : TaskCategory.personal).rawValue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task.title)
                .font(.headline)

            if !task.description.isEmpty {
                Text(task.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 12) {
                Text(task.priority.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.thinMaterial)
                    .clipShape(Capsule())

                Text(categoryLabel)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.thinMaterial)
                    .clipShape(Capsule())

                Text(task.status.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let dueDate = task.dueDate {
                    Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15))
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onDrag {
            NSItemProvider(object: task.id.uuidString as NSString)
        }
    }
}
