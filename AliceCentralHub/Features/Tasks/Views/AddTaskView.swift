//  Defines the button/flow for adding a new task to be displayed in the HomeView.

import SwiftUI

struct AddTaskView: View {
    @ObservedObject var taskStore: TaskStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var dueDate: Date = Date()
    @State private var hasDueDate = false
    @State private var priority: TaskPriority = .medium
    @State private var status: TaskStatus = .todo
    @State private var lifeContext: TaskLifeContext = .personal

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Info") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Details") {
                    Picker("Category", selection: $lifeContext) {
                        ForEach(TaskLifeContext.allCases) { context in
                            Text(context.rawValue).tag(context)
                        }
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

                    Toggle("Add Due Date", isOn: $hasDueDate)

                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Task")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                #elseif os(macOS)
                ToolbarItem {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                #endif
            }
        }
        .frame(minWidth: 500, minHeight: 420)
    }

    private func saveTask() {
        // Keep creation rules inside TaskStore so this view stays presentation-focused.
        let didSave = taskStore.addTask(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            dueDate: hasDueDate ? dueDate : nil,
            priority: priority,
            status: status,
            category: lifeContext.taskCategoryValue
        )

        if didSave {
            dismiss()
        }
    }
}
