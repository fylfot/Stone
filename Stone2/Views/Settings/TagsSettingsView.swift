import SwiftUI

struct TagsSettingsView: View {
    @Bindable var viewModel: ProjectsViewModel
    @State private var showNewTagSheet = false
    @State private var editingTagId: UUID?
    @State private var editingTagName: String = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    showNewTagSheet = true
                } label: {
                    Label("New Tag", systemImage: "plus")
                }

                Spacer()
            }
            .padding(8)

            Divider()

            if viewModel.tags.isEmpty {
                emptyState
            } else {
                tagList
            }
        }
        .sheet(isPresented: $showNewTagSheet) {
            NewTagSheet(viewModel: viewModel)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tag")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No tags yet")
                .foregroundStyle(.secondary)

            Button("Create Tag") {
                showNewTagSheet = true
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var tagList: some View {
        List {
            ForEach(viewModel.tags) { tag in
                TagRow(
                    tag: tag,
                    viewModel: viewModel,
                    editingTagId: $editingTagId,
                    editingTagName: $editingTagName
                )
            }
        }
        .listStyle(.inset)
    }
}

struct TagRow: View {
    let tag: Tag
    @Bindable var viewModel: ProjectsViewModel
    @Binding var editingTagId: UUID?
    @Binding var editingTagName: String

    var isEditing: Bool {
        editingTagId == tag.id
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: tag.colorHex))
                .frame(width: 12, height: 12)

            if isEditing {
                TextField("Tag Name", text: $editingTagName, onCommit: {
                    viewModel.updateTag(tag, name: editingTagName, colorHex: tag.colorHex)
                    editingTagId = nil
                })
                .textFieldStyle(.plain)
            } else {
                Text(tag.name)
                    .onTapGesture(count: 2) {
                        editingTagName = tag.name
                        editingTagId = tag.id
                    }
            }

            Spacer()

            Text("\(tag.projects.count) projects")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                viewModel.filterByTag(tag)
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
            .buttonStyle(.plain)
            .help("Filter projects by this tag")
        }
        .contextMenu {
            Button("Rename") {
                editingTagName = tag.name
                editingTagId = tag.id
            }

            Button("Filter Projects") {
                viewModel.filterByTag(tag)
            }

            Divider()

            Button("Delete", role: .destructive) {
                viewModel.deleteTag(tag)
            }
        }
    }
}

struct NewTagSheet: View {
    @Bindable var viewModel: ProjectsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedColor = "#8E8E93"

    private let colorOptions = [
        "#8E8E93", "#007AFF", "#34C759", "#FF9500",
        "#FF3B30", "#AF52DE", "#5856D6", "#FF2D55"
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("New Tag")
                .font(.headline)

            TextField("Tag Name", text: $name)
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
                    viewModel.createTag(name: name, colorHex: selectedColor)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty)
            }
        }
        .padding()
        .frame(width: 280)
    }
}
