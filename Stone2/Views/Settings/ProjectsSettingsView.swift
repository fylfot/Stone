import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ProjectsSettingsView: View {
    @Bindable var viewModel: ProjectsViewModel
    @State private var showNewProjectSheet = false
    @State private var showNewFolderSheet = false
    @State private var editingProjectName: String = ""
    @State private var editingProjectId: UUID?

    var body: some View {
        VStack(spacing: 0) {
            toolbar

            Divider()

            if viewModel.selectedTagId != nil {
                tagFilterBanner
            }

            projectList
        }
        .sheet(isPresented: $showNewProjectSheet) {
            NewProjectSheetPrefs(viewModel: viewModel)
        }
        .sheet(isPresented: $showNewFolderSheet) {
            NewFolderSheet(viewModel: viewModel)
        }
        .confirmationDialog(
            "Delete Item",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            if viewModel.projectToDelete != nil {
                Button("Delete Project", role: .destructive) {
                    viewModel.deleteProject()
                }
            }
            if viewModel.folderToDelete != nil {
                Button("Delete Folder", role: .destructive) {
                    viewModel.deleteFolder()
                }
            }
            Button("Cancel", role: .cancel) {
                viewModel.cancelDelete()
            }
        } message: {
            if let project = viewModel.projectToDelete {
                Text("Are you sure you want to delete \"\(project.name)\"? This will also delete all time entries for this project.")
            } else if let folder = viewModel.folderToDelete {
                Text("Are you sure you want to delete \"\(folder.name)\"? Projects in this folder will be moved to the root level.")
            }
        }
    }

    private var toolbar: some View {
        HStack {
            Button {
                showNewProjectSheet = true
            } label: {
                Label("New Project", systemImage: "plus")
            }

            Button {
                showNewFolderSheet = true
            } label: {
                Label("New Folder", systemImage: "folder.badge.plus")
            }

            Spacer()
        }
        .padding(8)
    }

    private var tagFilterBanner: some View {
        HStack {
            if let tagId = viewModel.selectedTagId,
               let tag = viewModel.tags.first(where: { $0.id == tagId }) {
                Text("Filtering by:")
                TagBadge(tag: tag)

                Spacer()

                Button("Clear") {
                    viewModel.filterByTag(nil)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.1))
    }

    private var projectList: some View {
        List {
            // Folders with their projects
            ForEach(viewModel.folders) { folder in
                FolderRow(
                    folder: folder,
                    viewModel: viewModel,
                    editingProjectId: $editingProjectId,
                    editingProjectName: $editingProjectName
                )
            }

            // Unfoldered projects
            Section("Uncategorized") {
                ForEach(viewModel.unfolderedProjects) { project in
                    ProjectRow(
                        project: project,
                        viewModel: viewModel,
                        editingProjectId: $editingProjectId,
                        editingProjectName: $editingProjectName
                    )
                }
                .onMove { indices, destination in
                    handleMove(indices: indices, destination: destination, folder: nil)
                }
            }
        }
        .listStyle(.sidebar)
    }

    private func handleMove(indices: IndexSet, destination: Int, folder: Folder?) {
        guard let firstIndex = indices.first else { return }
        let projects = folder?.projects.sorted { $0.sortOrder < $1.sortOrder } ?? viewModel.unfolderedProjects
        guard let project = projects[safe: firstIndex] else { return }
        viewModel.reorderProject(project, to: destination, inFolder: folder)
    }
}

struct FolderRow: View {
    let folder: Folder
    @Bindable var viewModel: ProjectsViewModel
    @Binding var editingProjectId: UUID?
    @Binding var editingProjectName: String
    @State private var isEditingFolderName = false
    @State private var editedFolderName = ""

    var body: some View {
        DisclosureGroup(isExpanded: .init(
            get: { folder.isExpanded },
            set: { _ in viewModel.toggleFolderExpanded(folder) }
        )) {
            ForEach(folder.projects.sorted { $0.sortOrder < $1.sortOrder }) { project in
                ProjectRow(
                    project: project,
                    viewModel: viewModel,
                    editingProjectId: $editingProjectId,
                    editingProjectName: $editingProjectName
                )
            }
        } label: {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundStyle(.secondary)

                if isEditingFolderName {
                    TextField("Folder Name", text: $editedFolderName, onCommit: {
                        viewModel.updateFolder(folder, name: editedFolderName)
                        isEditingFolderName = false
                    })
                    .textFieldStyle(.plain)
                } else {
                    Text(folder.name)
                        .onTapGesture(count: 2) {
                            editedFolderName = folder.name
                            isEditingFolderName = true
                        }
                }

                Spacer()

                Text("\(folder.projects.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contextMenu {
            Button("Rename") {
                editedFolderName = folder.name
                isEditingFolderName = true
            }
            Divider()
            Button("Delete", role: .destructive) {
                viewModel.confirmDeleteFolder(folder)
            }
        }
    }
}

struct ProjectRow: View {
    let project: Project
    @Bindable var viewModel: ProjectsViewModel
    @Binding var editingProjectId: UUID?
    @Binding var editingProjectName: String
    @State private var showTagMenu = false

    var isEditing: Bool {
        editingProjectId == project.id
    }

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: project.colorHex))
                .frame(width: 12, height: 12)

            if isEditing {
                TextField("Project Name", text: $editingProjectName, onCommit: {
                    viewModel.updateProject(project, name: editingProjectName, colorHex: project.colorHex)
                    editingProjectId = nil
                })
                .textFieldStyle(.plain)
            } else {
                Text(project.name)
                    .onTapGesture(count: 2) {
                        editingProjectName = project.name
                        editingProjectId = project.id
                    }
            }

            Spacer()

            // Tag badges
            HStack(spacing: 4) {
                ForEach(project.tags.prefix(3)) { tag in
                    TagBadge(tag: tag, compact: true)
                }
                if project.tags.count > 3 {
                    Text("+\(project.tags.count - 3)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Text(project.todayDuration.formattedShortDuration)
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 2)
        .contextMenu {
            Button("Rename") {
                editingProjectName = project.name
                editingProjectId = project.id
            }

            Menu("Move to Folder") {
                Button("None (Root)") {
                    viewModel.moveProject(project, to: nil)
                }
                Divider()
                ForEach(viewModel.folders) { folder in
                    Button(folder.name) {
                        viewModel.moveProject(project, to: folder)
                    }
                }
            }

            Menu("Tags") {
                ForEach(viewModel.tags) { tag in
                    let hasTag = project.tags.contains { $0.id == tag.id }
                    Button {
                        if hasTag {
                            viewModel.removeTag(tag, from: project)
                        } else {
                            viewModel.addTag(tag, to: project)
                        }
                    } label: {
                        HStack {
                            Text(tag.name)
                            if hasTag {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }

            Divider()

            Button("Delete", role: .destructive) {
                viewModel.confirmDeleteProject(project)
            }
        }
        .draggable(project.id.uuidString) {
            Text(project.name)
        }
    }
}

struct TagBadge: View {
    let tag: Tag
    var compact: Bool = false

    var body: some View {
        Text(tag.name)
            .font(compact ? .caption2 : .caption)
            .padding(.horizontal, compact ? 4 : 6)
            .padding(.vertical, compact ? 1 : 2)
            .background(Color(hex: tag.colorHex).opacity(0.2))
            .foregroundStyle(Color(hex: tag.colorHex))
            .clipShape(Capsule())
    }
}

struct NewProjectSheetPrefs: View {
    @Bindable var viewModel: ProjectsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedColor = "#007AFF"
    @State private var selectedFolderId: UUID?

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

            Picker("Folder", selection: $selectedFolderId) {
                Text("None").tag(nil as UUID?)
                ForEach(viewModel.folders) { folder in
                    Text(folder.name).tag(folder.id as UUID?)
                }
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }

                Button("Create") {
                    let folder = viewModel.folders.first { $0.id == selectedFolderId }
                    viewModel.createProject(name: name, colorHex: selectedColor, folder: folder)
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

struct NewFolderSheet: View {
    @Bindable var viewModel: ProjectsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("New Folder")
                .font(.headline)

            TextField("Folder Name", text: $name)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Cancel") {
                    dismiss()
                }

                Button("Create") {
                    viewModel.createFolder(name: name)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty)
            }
        }
        .padding()
        .frame(width: 250)
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
