//
//  EditTaskView.swift
//  AliceCentralHub
//
//  Created by Ethan Thai on 4/12/26.
//

import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var taskStore: TaskStore
    let task: TaskItem

    @State private var title: String
    @State private var description: String
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @State private var priority: TaskPriority
    @State private var status: TaskStatus
    @State private var lifeContext: TaskLifeContext
    @State private var didChangeLifeContext = false
    @State private var showingDeleteConfirmation = false

    init(taskStore: TaskStore, task: TaskItem) {
        self.taskStore = taskStore
        self.task = task

        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description)
        _dueDate = State(initialValue: task.dueDate ?? Date())
        _hasDueDate = State(initialValue: task.dueDate != nil)
        _priority = State(initialValue: task.priority)
        _status = State(initialValue: task.status)
        _lifeContext = State(initialValue: TaskLifeContext(taskCategory: task.category))
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)

                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3...6)

                Picker(
                    "Category",
                    selection: Binding(
                        get: { lifeContext },
                        set: { newValue in
                            didChangeLifeContext = true
                            lifeContext = newValue
                        }
                    )
                ) {
                    ForEach(TaskLifeContext.allCases) { context in
                        Text(context.rawValue).tag(context)
                    }
                }

                if isUsingLegacyCategory {
                    Text("This task uses a legacy category. It will stay as-is unless you change Category.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Toggle("Add Due Date", isOn: $hasDueDate)

                if hasDueDate {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }

                Picker("Priority", selection: $priority) {
                    ForEach(TaskPriority.allCases) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }

                Picker("Status", selection: $status) {
                    ForEach(TaskStatus.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Task", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Edit Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let categoryToSave = didChangeLifeContext
                            ? lifeContext.taskCategoryValue
                            : task.category

                        // Store owns validation and mutation rules (including updatedAt).
                        let didSave = taskStore.updateTask(
                            id: task.id,
                            title: title,
                            description: description,
                            dueDate: hasDueDate ? dueDate : nil,
                            priority: priority,
                            status: status,
                            source: task.source,
                            category: categoryToSave
                        )

                        if didSave {
                            dismiss()
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .confirmationDialog(
            "Delete this task?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                _ = taskStore.deleteTask(id: task.id)
                dismiss()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var isUsingLegacyCategory: Bool {
        guard let category = task.category else { return false }
        return category != .personal && category != .work
    }
}
