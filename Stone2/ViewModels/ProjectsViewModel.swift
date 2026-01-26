import Foundation
import SwiftData
import SwiftUI

@Observable
final class ProjectsViewModel {
    private(set) var projects: [Project] = []
    private(set) var folders: [Folder] = []
    private(set) var tags: [Tag] = []
    private(set) var unfolderedProjects: [Project] = []
    private var modelContext: ModelContext?

    // Filter state
    var selectedTagId: UUID?

    // Edit states
    var editingProject: Project?
    var editingFolder: Folder?
    var editingTag: Tag?

    // Confirmation dialog
    var showDeleteConfirmation = false
    var projectToDelete: Project?
    var folderToDelete: Folder?

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadAll()
    }

    func loadAll() {
        loadFolders()
        loadTags()
        loadProjects()
    }

    private func loadFolders() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<Folder>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        do {
            folders = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch folders: \(error)")
        }
    }

    private func loadTags() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<Tag>(
            sortBy: [SortDescriptor(\.name)]
        )
        do {
            tags = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch tags: \(error)")
        }
    }

    private func loadProjects() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<Project>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.sortOrder)]
        )

        do {
            let allProjects = try modelContext.fetch(descriptor)

            // Apply tag filter if selected
            if let tagId = selectedTagId {
                projects = allProjects.filter { project in
                    project.tags.contains { $0.id == tagId }
                }
            } else {
                projects = allProjects
            }

            unfolderedProjects = projects.filter { $0.folder == nil }
        } catch {
            print("Failed to fetch projects: \(error)")
        }
    }

    // MARK: - Project Operations

    func createProject(name: String, colorHex: String, folder: Folder? = nil) {
        guard let modelContext else { return }
        let project = Project(
            name: name,
            colorHex: colorHex,
            sortOrder: projects.count
        )
        project.folder = folder
        if let folder {
            folder.projects.append(project)
        }
        modelContext.insert(project)
        try? modelContext.save()
        loadAll()
    }

    func updateProject(_ project: Project, name: String, colorHex: String) {
        project.name = name
        project.colorHex = colorHex
        try? modelContext?.save()
        loadAll()
    }

    func confirmDeleteProject(_ project: Project) {
        projectToDelete = project
        showDeleteConfirmation = true
    }

    func deleteProject() {
        guard let project = projectToDelete, let modelContext else { return }
        modelContext.delete(project)
        try? modelContext.save()
        projectToDelete = nil
        showDeleteConfirmation = false
        loadAll()
    }

    func moveProject(_ project: Project, to folder: Folder?) {
        project.folder?.projects.removeAll { $0.id == project.id }
        project.folder = folder
        folder?.projects.append(project)
        try? modelContext?.save()
        loadAll()
    }

    func reorderProject(_ project: Project, to newIndex: Int, inFolder folder: Folder?) {
        let projectList: [Project]
        if let folder {
            projectList = folder.projects.sorted { $0.sortOrder < $1.sortOrder }
        } else {
            projectList = unfolderedProjects
        }

        var mutableList = projectList
        if let currentIndex = mutableList.firstIndex(where: { $0.id == project.id }) {
            mutableList.remove(at: currentIndex)
            let targetIndex = min(newIndex, mutableList.count)
            mutableList.insert(project, at: targetIndex)

            for (index, proj) in mutableList.enumerated() {
                proj.sortOrder = index
            }
        }
        try? modelContext?.save()
        loadAll()
    }

    // MARK: - Folder Operations

    func createFolder(name: String) {
        guard let modelContext else { return }
        let folder = Folder(
            name: name,
            sortOrder: folders.count
        )
        modelContext.insert(folder)
        try? modelContext.save()
        loadAll()
    }

    func updateFolder(_ folder: Folder, name: String) {
        folder.name = name
        try? modelContext?.save()
        loadAll()
    }

    func confirmDeleteFolder(_ folder: Folder) {
        folderToDelete = folder
        showDeleteConfirmation = true
    }

    func deleteFolder() {
        guard let folder = folderToDelete, let modelContext else { return }
        // Move projects out of folder first
        for project in folder.projects {
            project.folder = nil
        }
        modelContext.delete(folder)
        try? modelContext.save()
        folderToDelete = nil
        showDeleteConfirmation = false
        loadAll()
    }

    func toggleFolderExpanded(_ folder: Folder) {
        folder.isExpanded.toggle()
        try? modelContext?.save()
    }

    // MARK: - Tag Operations

    func createTag(name: String, colorHex: String) {
        guard let modelContext else { return }
        let tag = Tag(name: name, colorHex: colorHex)
        modelContext.insert(tag)
        try? modelContext.save()
        loadAll()
    }

    func updateTag(_ tag: Tag, name: String, colorHex: String) {
        tag.name = name
        tag.colorHex = colorHex
        try? modelContext?.save()
        loadAll()
    }

    func deleteTag(_ tag: Tag) {
        guard let modelContext else { return }
        // Remove tag from all projects first
        for project in tag.projects {
            project.tags.removeAll { $0.id == tag.id }
        }
        modelContext.delete(tag)
        try? modelContext.save()
        if selectedTagId == tag.id {
            selectedTagId = nil
        }
        loadAll()
    }

    func addTag(_ tag: Tag, to project: Project) {
        guard !project.tags.contains(where: { $0.id == tag.id }) else { return }
        project.tags.append(tag)
        tag.projects.append(project)
        try? modelContext?.save()
        loadAll()
    }

    func removeTag(_ tag: Tag, from project: Project) {
        project.tags.removeAll { $0.id == tag.id }
        tag.projects.removeAll { $0.id == project.id }
        try? modelContext?.save()
        loadAll()
    }

    func filterByTag(_ tag: Tag?) {
        selectedTagId = tag?.id
        loadProjects()
    }

    func cancelDelete() {
        projectToDelete = nil
        folderToDelete = nil
        showDeleteConfirmation = false
    }
}
