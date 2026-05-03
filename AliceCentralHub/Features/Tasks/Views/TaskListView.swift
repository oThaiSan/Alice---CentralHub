//
//  TaskListView.swift
//  AliceCentralHub
//
//  Created by Ethan Thai on 4/12/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct TaskListView: View {
    @ObservedObject var taskStore: TaskStore
    @State private var showingAddTask = false
    @State private var selectedTask: TaskItem?
    @State private var searchText = ""
    @State private var selectedScope: TaskListScope = .overall
    @State private var selectedCategoryFilter: TaskCategoryFilter = .all
    let onTaskTapped: ((TaskItem) -> Void)?

    init(taskStore: TaskStore, onTaskTapped: ((TaskItem) -> Void)? = nil) {
        self.taskStore = taskStore
        self.onTaskTapped = onTaskTapped
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Picker("View", selection: $selectedScope) {
                    ForEach(TaskListScope.allCases) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top)

                Picker("Category", selection: $selectedCategoryFilter) {
                    ForEach(TaskCategoryFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                contentForSelectedScope
            }
            .navigationTitle("Tasks")
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search by title")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                #elseif os(macOS)
                ToolbarItem {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(taskStore: taskStore)
            }
            .sheet(item: $selectedTask) { task in
                EditTaskView(taskStore: taskStore, task: task)
            }
        }
    }

    @ViewBuilder
    private var contentForSelectedScope: some View {
        switch selectedScope {
        case .overall:
            taskListView(
                title: "All Tasks",
                tasks: taskStore.overallTasks(
                    searchQuery: searchText,
                    categoryFilter: selectedCategoryFilter
                ),
                emptyMessage: "No tasks match your current filters."
            )
        case .board:
            boardView
        case .today:
            taskListView(
                title: "Overdue + Due Today",
                tasks: taskStore.todayTasks(
                    searchQuery: searchText,
                    categoryFilter: selectedCategoryFilter
                ),
                emptyMessage: "No tasks due today."
            )
        case .upcoming:
            taskListView(
                title: "Next 7 Days",
                tasks: taskStore.upcomingTasks(
                    daysAhead: 7,
                    searchQuery: searchText,
                    categoryFilter: selectedCategoryFilter
                ),
                emptyMessage: "No upcoming tasks."
            )
        }
    }

    private var boardView: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 30) {
                TaskStatusColumnView(
                    title: "To Do",
                    status: .todo,
                    tasks: taskStore.tasks(
                        matchingTitle: searchText,
                        status: .todo,
                        categoryFilter: selectedCategoryFilter
                    ),
                    taskStore: taskStore,
                    onTaskTapped: handleTaskTap
                )

                TaskStatusColumnView(
                    title: "In Progress",
                    status: .inProgress,
                    tasks: taskStore.tasks(
                        matchingTitle: searchText,
                        status: .inProgress,
                        categoryFilter: selectedCategoryFilter
                    ),
                    taskStore: taskStore,
                    onTaskTapped: handleTaskTap
                )

                TaskStatusColumnView(
                    title: "Blocked",
                    status: .blocked,
                    tasks: taskStore.tasks(
                        matchingTitle: searchText,
                        status: .blocked,
                        categoryFilter: selectedCategoryFilter
                    ),
                    taskStore: taskStore,
                    onTaskTapped: handleTaskTap
                )

                TaskStatusColumnView(
                    title: "Done",
                    status: .done,
                    tasks: taskStore.tasks(
                        matchingTitle: searchText,
                        status: .done,
                        categoryFilter: selectedCategoryFilter
                    ),
                    taskStore: taskStore,
                    onTaskTapped: handleTaskTap
                )
            }
            .padding()
        }
    }

    private func taskListView(title: String, tasks: [TaskItem], emptyMessage: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)

            if tasks.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("No Matching Tasks")
                        .font(.headline)
                    Text(emptyMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(tasks) { task in
                            TaskRowView(task: task)
                                .onTapGesture {
                                    handleTaskTap(task)
                                }
                                .contextMenu {
                                    Button("Edit Task", systemImage: "pencil") {
                                        selectedTask = task
                                    }
                                    Button("Delete Task", systemImage: "trash", role: .destructive) {
                                        _ = taskStore.deleteTask(id: task.id)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
    }

    private func handleTaskTap(_ task: TaskItem) {
        if let onTaskTapped = onTaskTapped {
            onTaskTapped(task)
        } else {
            selectedTask = task
        }
    }

    private enum TaskListScope: String, CaseIterable, Identifiable {
        case overall = "Overall"
        case board = "Board"
        case today = "Today"
        case upcoming = "Upcoming"

        var id: String { rawValue }
    }

    private struct TaskStatusColumnView: View {
        let title: String
        let status: TaskStatus
        let tasks: [TaskItem]
        let taskStore: TaskStore
        let onTaskTapped: (TaskItem) -> Void

        @State private var isTargeted = false

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)

                if tasks.isEmpty {
                    VStack {
                        Spacer()
                        Text("No tasks")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 120)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(tasks) { task in
                                TaskRowView(task: task)
                                    .onTapGesture {
                                        onTaskTapped(task)
                                    }
                                    .contextMenu {
                                        Button("Delete Task", systemImage: "trash", role: .destructive) {
                                            _ = taskStore.deleteTask(id: task.id)
                                        }
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
            .frame(minWidth: 280, maxWidth: 280, maxHeight: .infinity, alignment: .top)
            .background(isTargeted ? Color.accentColor.opacity(0.12) : Color.gray.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isTargeted ? Color.accentColor.opacity(0.5) : Color.gray.opacity(0.15), lineWidth: 1)
            )
            .onDrop(of: [.text], isTargeted: $isTargeted) { providers in
                guard let provider = providers.first else { return false }

                provider.loadObject(ofClass: NSString.self) { object, _ in
                    guard
                        let idString = object as? String,
                        let taskID = UUID(uuidString: idString)
                    else { return }

                    DispatchQueue.main.async {
                        taskStore.moveTask(taskID, to: status)
                    }
                }

                return true
            }
        }
    }
}

#Preview {
    TaskListView(taskStore: TaskStore())
        .frame(minWidth: 1300, minHeight: 900)
}
