import SwiftUI
import SwiftData

struct MenuBarView: View {
    @Bindable var viewModel: MenuBarViewModel
    @State private var showNewProjectSheet = false
    @State private var showTimeEntries = false

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isTracking, let project = viewModel.activeProject {
                activeTimerSection(project: project)
                Divider()
            }

            projectsList

            Divider()

            actionButtons
        }
        .frame(width: 280)
        .sheet(isPresented: $showNewProjectSheet) {
            NewProjectSheet(viewModel: viewModel)
        }
        .alert("Idle Time Detected", isPresented: .init(
            get: { viewModel.showIdleAlert },
            set: { _ in }
        )) {
            Button("Keep Time") {
                viewModel.keepIdleTime()
            }
            Button("Discard \(viewModel.idleSeconds.formattedCompactDuration)", role: .destructive) {
                viewModel.discardIdleTime()
            }
        } message: {
            Text("You've been idle for \(viewModel.idleSeconds.formattedCompactDuration). What would you like to do with this time?")
        }
    }

    private func activeTimerSection(project: Project) -> some View {
        VStack(spacing: 8) {
            HStack {
                Circle()
                    .fill(Color(hex: project.colorHex))
                    .frame(width: 10, height: 10)

                Text(project.name)
                    .font(.headline)

                Spacer()
            }

            Text(viewModel.currentDuration.formattedDuration)
                .font(.system(size: 32, weight: .medium, design: .monospaced))
                .foregroundStyle(.primary)

            Button("Stop") {
                viewModel.stopTracking()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
    }

    private var projectsList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(viewModel.projects) { project in
                    ProjectMenuItem(
                        project: project,
                        isActive: viewModel.activeProject?.id == project.id,
                        todayDuration: project.todayDuration
                    ) {
                        if viewModel.activeProject?.id == project.id {
                            viewModel.stopTracking()
                        } else {
                            viewModel.switchProject(project)
                        }
                    }
                }

                if viewModel.projects.isEmpty {
                    Text("No projects yet")
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .padding(.vertical, 4)
        }
        .frame(maxHeight: 300)
    }

    private var actionButtons: some View {
        VStack(spacing: 0) {
            MenuButton(title: "New Project...", icon: "plus") {
                showNewProjectSheet = true
            }

            MenuButton(title: "Reports...", icon: "chart.pie", shortcut: "r") {
                AppDelegate.shared.showReportsWindow()
            }

            Divider()

            MenuButton(title: "Preferences...", icon: "gear", shortcut: ",") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }

            MenuButton(title: "Quit Stone", icon: "power", shortcut: "q") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

struct ProjectMenuItem: View {
    let project: Project
    let isActive: Bool
    let todayDuration: TimeInterval
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: project.colorHex))
                    .frame(width: 8, height: 8)

                if isActive {
                    Image(systemName: "checkmark")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(project.name)
                    .lineLimit(1)

                Spacer()

                Text(todayDuration.formattedShortDuration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isActive ? Color.accentColor.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    var shortcut: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 16)

                Text(title)

                Spacer()

                if let shortcut {
                    Text("⌘\(shortcut.uppercased())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct NewProjectSheet: View {
    @Bindable var viewModel: MenuBarViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedColor = "#007AFF"

    private let colorOptions = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#AF52DE", "#5856D6", "#FF2D55", "#00C7BE"
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("New Project")
                .font(.headline)

            TextField("Project Name", text: $name)
                .textFieldStyle(.roundedBorder)

            HStack(spacing: 8) {
                ForEach(colorOptions, id: \.self) { color in
                    Circle()
                        .fill(Color(hex: color))
                        .frame(width: 24, height: 24)
                        .overlay {
                            if selectedColor == color {
                                Image(systemName: "checkmark")
                                    .font(.caption2)
                                    .foregroundStyle(.white)
                            }
                        }
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }

                Button("Create") {
                    viewModel.createProject(name: name, colorHex: selectedColor)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty)
            }
        }
        .padding()
        .frame(width: 300)
    }
}
