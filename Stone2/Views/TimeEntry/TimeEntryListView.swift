import SwiftUI
import SwiftData

struct TimeEntryListView: View {
    @Bindable var viewModel: TimeEntryViewModel
    @State private var selectedDate: Date = .now

    var body: some View {
        VStack(spacing: 0) {
            dateSelector

            Divider()

            if viewModel.entries.isEmpty {
                emptyState
            } else {
                entriesList
            }

            Spacer()

            addButton
        }
        .sheet(isPresented: $viewModel.isEditing) {
            if viewModel.editingEntry != nil {
                TimeEntryEditSheet(viewModel: viewModel, mode: .edit)
            }
        }
        .sheet(isPresented: $viewModel.isAdding) {
            TimeEntryEditSheet(viewModel: viewModel, mode: .add)
        }
        .onChange(of: selectedDate) { _, newValue in
            viewModel.loadEntries(for: newValue)
        }
    }

    private var dateSelector: some View {
        HStack {
            Button {
                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            } label: {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(.plain)

            Spacer()

            Text(selectedDate.relativeDescription)
                .font(.headline)

            Spacer()

            Button {
                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.plain)
            .disabled(Calendar.current.isDateInToday(selectedDate))
        }
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No time entries")
                .foregroundStyle(.secondary)

            Button("Add Entry") {
                viewModel.startAdding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var entriesList: some View {
        List {
            ForEach(viewModel.entries) { entry in
                TimeEntryRow(entry: entry)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.startEditing(entry)
                    }
                    .contextMenu {
                        Button("Edit") {
                            viewModel.startEditing(entry)
                        }
                        Button("Delete", role: .destructive) {
                            viewModel.deleteEntry(entry)
                        }
                    }
            }
        }
    }

    private var addButton: some View {
        Button {
            viewModel.startAdding()
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Time Entry")
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(.plain)
        .background(Color.accentColor.opacity(0.1))
    }
}

struct TimeEntryRow: View {
    let entry: TimeEntry

    var body: some View {
        HStack(spacing: 12) {
            if let project = entry.project {
                Circle()
                    .fill(Color(hex: project.colorHex))
                    .frame(width: 8, height: 8)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.project?.name ?? "No Project")
                    .font(.headline)

                HStack {
                    Text("\(entry.startedAt.timeDescription) - \(entry.endedAt?.timeDescription ?? "Running")")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let note = entry.note, !note.isEmpty {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(note)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            Text(entry.duration.formattedShortDuration)
                .font(.subheadline)
                .monospacedDigit()
                .foregroundStyle(.secondary)

            if entry.isRunning {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
}

enum TimeEntryEditMode {
    case edit
    case add
}

struct TimeEntryEditSheet: View {
    @Bindable var viewModel: TimeEntryViewModel
    let mode: TimeEntryEditMode
    @Environment(\.dismiss) private var dismiss

    var title: String {
        mode == .edit ? "Edit Time Entry" : "Add Time Entry"
    }

    var startDate: Binding<Date> {
        mode == .edit ? $viewModel.editStartDate : $viewModel.addStartDate
    }

    var endDate: Binding<Date> {
        mode == .edit ? $viewModel.editEndDate : $viewModel.addEndDate
    }

    var note: Binding<String> {
        mode == .edit ? $viewModel.editNote : $viewModel.addNote
    }

    var projectId: Binding<UUID?> {
        mode == .edit ? $viewModel.editProjectId : $viewModel.addProjectId
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)

            Form {
                Picker("Project", selection: projectId) {
                    Text("No Project").tag(nil as UUID?)
                    ForEach(viewModel.projects) { project in
                        HStack {
                            Circle()
                                .fill(Color(hex: project.colorHex))
                                .frame(width: 8, height: 8)
                            Text(project.name)
                        }
                        .tag(project.id as UUID?)
                    }
                }

                DatePicker("Start", selection: startDate)
                DatePicker("End", selection: endDate)

                TextField("Note (optional)", text: note)
            }
            .formStyle(.grouped)

            HStack {
                Button("Cancel") {
                    if mode == .edit {
                        viewModel.cancelEdit()
                    } else {
                        viewModel.cancelAdd()
                    }
                    dismiss()
                }

                Button("Save") {
                    if mode == .edit {
                        viewModel.saveEdit()
                    } else {
                        viewModel.saveAdd()
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 350, height: 300)
    }
}
