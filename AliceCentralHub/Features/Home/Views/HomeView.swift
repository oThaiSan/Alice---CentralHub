import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    @State private var selectedSidebarItem: SidebarItem = .home
    @State private var selectedStock: StockItem = .sample[0]
    @State private var selectedTimeFilter: SentimentTimeFilter = .oneDay
    
//    Adding calls to the Task-related components
    @StateObject private var taskStore = TaskStore()
    @StateObject private var scheduleStore = ScheduleStore()
    @State private var showingAddTask = false
    @State private var selectedTask: TaskItem?
    
    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailView
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// MARK: - Sections
private extension HomeView {
    @ViewBuilder
    var detailView: some View {
        switch selectedSidebarItem {
        case .home:
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    stockSentimentSection
                    workScheduleSection
                    tasksOverviewSection
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(Color(nsColor: .windowBackgroundColor))

        case .personalOps:
            TaskListView(taskStore: taskStore)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor))

        case .marketingAnalyst:
            VStack(alignment: .leading, spacing: 16) {
                Text("Marketing Analyst")
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                Text("This section is not built yet.")
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(nsColor: .windowBackgroundColor))

        case .kalshiAgent:
            KalshiDashboardView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor))
        }
    }
    
    var sidebar: some View {
        List(selection: $selectedSidebarItem) {
            ForEach(SidebarItem.allCases, id: \.self) { item in
                Label(item.title, systemImage: item.icon)
                    .tag(item)
            }
        }
        .navigationTitle("Assistant Hub")
        .listStyle(.sidebar)
    }

    var headerSection: some View {
        Text(greetingText)
            .font(.system(size: 40, weight: .semibold))
            .padding(.top, 8)
    }

    var stockSentimentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stock Sentiment Overview")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    stockListPanel
                        .frame(width: 170)

                    Divider()
                        .padding(.vertical, 16)

                    stockInsightPanel
                }
                .frame(minHeight: 280)

                Divider()

                recentSentimentPanel
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.18), lineWidth: 1)
            )
        }
    }

    var stockListPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Watchlist")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Range")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Picker("", selection: $selectedTimeFilter) {
                    ForEach(SentimentTimeFilter.allCases, id: \.self) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .font(.system(size: 15, weight: .semibold))
                .labelsHidden()
                .pickerStyle(.segmented)
                .controlSize(.small)
                .frame(maxWidth: .infinity)
                .tint(.blue)
            }
            .padding(.bottom, 4)

            ForEach(StockItem.sample) { stock in
                Button {
                    selectedStock = stock
                } label: {
                    HStack {
                        Text(stock.ticker)
                            .font(.title3)
                            .fontWeight(selectedStock == stock ? .semibold : .regular)
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedStock == stock ? Color.accentColor.opacity(0.14) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(20)
    }

    var stockInsightPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Insight on Selected Stock")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                Text(selectedStock.ticker)
                    .font(.system(size: 34, weight: .bold))

                Text(selectedStock.summary)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    sentimentBadge(title: "Sentiment", value: selectedStock.sentimentLabel)
                    sentimentBadge(title: "Trend", value: selectedStock.trendLabel)
                }
            }

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    var recentSentimentPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sentiments")
                .font(.headline)

            ForEach(selectedStock.recentNotes) { note in
                Button {
                    // Detailed view later
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(note.sentimentColor)
                            .frame(width: 10, height: 10)
                            .padding(.top, 5)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)

                            Text(note.preview)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var tasksOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Overview of Tasks")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    showingAddTask = true
                } label: {
                    Label("Add Task", systemImage: "plus")
                }
            }

            HStack(alignment: .top, spacing: 16) {
                TaskStatusColumnCard(
                    title: "To Do",
                    status: .todo,
                    tasks: taskStore.tasks(for: .todo),
                    taskStore: taskStore,
                    onTaskTap: { task in
                        selectedTask = task
                    }
                )

                TaskStatusColumnCard(
                    title: "In Progress",
                    status: .inProgress,
                    tasks: taskStore.tasks(for: .inProgress),
                    taskStore: taskStore,
                    onTaskTap: { task in
                        selectedTask = task
                    }
                )

                TaskStatusColumnCard(
                    title: "Done",
                    status: .done,
                    tasks: taskStore.tasks(for: .done),
                    taskStore: taskStore,
                    onTaskTap: { task in
                        selectedTask = task
                    }
                )
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(taskStore: taskStore)
        }
        .sheet(item: $selectedTask) { task in
            EditTaskView(taskStore: taskStore, task: task)
        }
    }

    var workScheduleSection: some View {
        WorkScheduleSectionView(scheduleStore: scheduleStore)
    }

    func sentimentBadge(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good Morning, Ethan"
        case 12..<18:
            return "Good Afternoon, Ethan"
        default:
            return "Good Evening, Ethan"
        }
    }
}

// MARK: - Supporting Views
struct TaskStatusColumnCard: View {
    let title: String
    let status: TaskStatus
    let tasks: [TaskItem]
    let taskStore: TaskStore
    let onTaskTap: (TaskItem) -> Void
    @State private var isTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.headline)

                Spacer()

                Text("\(tasks.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if tasks.isEmpty {
                Text("No tasks")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(tasks.prefix(5)) { task in
                    Button {
                        onTaskTap(task)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(task.title)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)

                            HStack(spacing: 8) {
                                Text(task.priority.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.12))
                                    .clipShape(Capsule())

                                if let dueDate = task.dueDate {
                                    Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .onDrag {
                        NSItemProvider(object: task.id.uuidString as NSString)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 220, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isTargeted ? Color.accentColor.opacity(0.12) : Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isTargeted ? Color.accentColor.opacity(0.5) : Color.gray.opacity(0.18), lineWidth: 1)
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

// MARK: - Models
enum SidebarItem: CaseIterable {
    case home
    case personalOps
    case marketingAnalyst
    case kalshiAgent

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .personalOps:
            return "Personal Ops"
        case .marketingAnalyst:
            return "Marketing Analyst"
        case .kalshiAgent:
            return "Kalshi Agent"
        }
    }

    var icon: String {
        switch self {
        case .home:
            return "house"
        case .personalOps:
            return "checklist"
        case .marketingAnalyst:
            return "chart.line.uptrend.xyaxis"
        case .kalshiAgent:
            return "chart.line.uptrend.xyaxis.circle"
        }
    }
}

enum SentimentTimeFilter: CaseIterable {
    case oneDay
    case threeDay
    case oneWeek

    var title: String {
        switch self {
        case .oneDay:
            return "1D"
        case .threeDay:
            return "3D"
        case .oneWeek:
            return "1W"
        }
    }
}

struct StockItem: Identifiable, Hashable {
    let id = UUID()
    let ticker: String
    let summary: String
    let sentimentLabel: String
    let trendLabel: String
    let recentNotes: [SentimentNote]

    static let sample: [StockItem] = [
        StockItem(
            ticker: "NVDA",
            summary: "Strong AI demand remains the core driver, but recent sentiment is balancing enthusiasm with valuation sensitivity.",
            sentimentLabel: "Positive",
            trendLabel: "Upward",
            recentNotes: [
                SentimentNote(
                    title: "AI demand still strong",
                    preview: "Coverage continues to frame data center demand as the main long-term support for the name.",
                    sentimentColor: .green
                ),
                SentimentNote(
                    title: "Valuation concerns resurfacing",
                    preview: "Some recent takes are more cautious, focusing on how much growth is already priced in.",
                    sentimentColor: .orange
                )
            ]
        ),
        StockItem(
            ticker: "EQX",
            summary: "Gold price strength is helping sentiment, though some commentary remains tied to broader commodity volatility.",
            sentimentLabel: "Mixed Positive",
            trendLabel: "Stable",
            recentNotes: [
                SentimentNote(
                    title: "Gold tailwind persists",
                    preview: "Commentary remains constructive as macro uncertainty supports the gold trade.",
                    sentimentColor: .green
                )
            ]
        ),
        StockItem(
            ticker: "VOO",
            summary: "Sentiment is generally stable and long-term oriented, with less name-specific volatility than single-stock coverage.",
            sentimentLabel: "Neutral Positive",
            trendLabel: "Stable",
            recentNotes: [
                SentimentNote(
                    title: "Broad market proxy",
                    preview: "Most mentions position it as a long-term allocation rather than a tactical idea.",
                    sentimentColor: .blue
                )
            ]
        ),
        StockItem(
            ticker: "AAPL",
            summary: "Narratives are balancing ecosystem strength and services durability against growth expectations and hardware cycle questions.",
            sentimentLabel: "Mixed",
            trendLabel: "Watch",
            recentNotes: [
                SentimentNote(
                    title: "Services remains a support",
                    preview: "Recent coverage highlights recurring revenue strength as a stabilizing factor.",
                    sentimentColor: .green
                ),
                SentimentNote(
                    title: "Hardware cycle under scrutiny",
                    preview: "Some coverage is waiting for stronger product-cycle momentum before turning more bullish.",
                    sentimentColor: .orange
                )
            ]
        )
    ]
}

struct SentimentNote: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let preview: String
    let sentimentColor: Color
}

#Preview {
    HomeView()
        .frame(minWidth: 1300, minHeight: 900)
}
