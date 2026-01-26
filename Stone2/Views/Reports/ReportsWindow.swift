import SwiftUI
import SwiftData
import Charts
import AppKit

struct ReportsWindow: View {
    @Bindable var viewModel: ReportsViewModel
    @State private var selectedTab = "summary"

    var body: some View {
        VStack(spacing: 0) {
            toolbar

            Divider()

            TabView(selection: $selectedTab) {
                SummaryView(viewModel: viewModel)
                    .tabItem { Label("Summary", systemImage: "chart.pie") }
                    .tag("summary")

                TimelineView(viewModel: viewModel)
                    .tabItem { Label("Timeline", systemImage: "chart.bar") }
                    .tag("timeline")

                EntriesListView(viewModel: viewModel)
                    .tabItem { Label("Entries", systemImage: "list.bullet") }
                    .tag("entries")
            }
        }
        .frame(minWidth: 600, minHeight: 450)
    }

    private var toolbar: some View {
        HStack {
            Picker("Period", selection: $viewModel.selectedPeriod) {
                ForEach(ReportPeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 140)

            if viewModel.selectedPeriod == .custom {
                DatePicker("From", selection: $viewModel.customStartDate, displayedComponents: .date)
                    .labelsHidden()
                DatePicker("To", selection: $viewModel.customEndDate, displayedComponents: .date)
                    .labelsHidden()
            }

            Spacer()

            Text("Total: \(viewModel.totalDuration.formattedCompactDuration)")
                .font(.headline)
                .monospacedDigit()

            Button {
                exportCSV()
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
        }
        .padding()
    }

    private func exportCSV() {
        guard let fileURL = viewModel.saveCSVToFile() else { return }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.commaSeparatedText]
        savePanel.nameFieldStringValue = fileURL.lastPathComponent
        savePanel.canCreateDirectories = true

        if savePanel.runModal() == .OK, let destination = savePanel.url {
            do {
                try FileManager.default.copyItem(at: fileURL, to: destination)
            } catch {
                print("Failed to save file: \(error)")
            }
        }
    }
}

struct SummaryView: View {
    @Bindable var viewModel: ReportsViewModel

    var body: some View {
        HStack(spacing: 20) {
            // Pie chart
            if !viewModel.projectSummaries.isEmpty {
                Chart(viewModel.projectSummaries) { summary in
                    SectorMark(
                        angle: .value("Duration", summary.duration),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5
                    )
                    .foregroundStyle(Color(hex: summary.colorHex))
                    .annotation(position: .overlay) {
                        if summary.percentage > 10 {
                            Text("\(Int(summary.percentage))%")
                                .font(.caption2)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .chartLegend(.hidden)
                .frame(width: 200, height: 200)
            } else {
                VStack {
                    Image(systemName: "chart.pie")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No data")
                        .foregroundStyle(.secondary)
                }
                .frame(width: 200, height: 200)
            }

            // Project breakdown list
            VStack(alignment: .leading, spacing: 0) {
                Text("By Project")
                    .font(.headline)
                    .padding(.bottom, 8)

                if viewModel.projectSummaries.isEmpty {
                    Text("No time entries in this period")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.projectSummaries) { summary in
                        HStack {
                            Circle()
                                .fill(Color(hex: summary.colorHex))
                                .frame(width: 10, height: 10)

                            Text(summary.name)

                            Spacer()

                            Text(summary.duration.formattedCompactDuration)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)

                            Text("(\(Int(summary.percentage))%)")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
}

struct TimelineView: View {
    @Bindable var viewModel: ReportsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.dailySummaries.isEmpty {
                VStack {
                    Image(systemName: "chart.bar")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No data for this period")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Bar chart
                Chart(viewModel.dailySummaries) { day in
                    BarMark(
                        x: .value("Date", day.date, unit: .day),
                        y: .value("Hours", day.totalDuration / 3600)
                    )
                    .foregroundStyle(.blue.gradient)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.weekday(.abbreviated))
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let hours = value.as(Double.self) {
                                Text("\(Int(hours))h")
                            }
                        }
                        AxisGridLine()
                    }
                }
                .frame(height: 200)
                .padding()

                // Daily breakdown
                List(viewModel.dailySummaries) { day in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(day.date.relativeDescription)
                                .font(.headline)

                            Spacer()

                            Text(day.totalDuration.formattedCompactDuration)
                                .monospacedDigit()
                        }

                        HStack(spacing: 4) {
                            ForEach(day.projectBreakdown.prefix(5)) { project in
                                HStack(spacing: 2) {
                                    Circle()
                                        .fill(Color(hex: project.colorHex))
                                        .frame(width: 6, height: 6)
                                    Text(project.duration.formattedShortDuration)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.inset)
            }
        }
    }
}

struct EntriesListView: View {
    @Bindable var viewModel: ReportsViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search entries...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding()

            Divider()

            if viewModel.entries.isEmpty {
                VStack {
                    Image(systemName: "clock")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text(viewModel.searchText.isEmpty ? "No entries in this period" : "No matching entries")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.entries) { entry in
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
                                Text(entry.startedAt.relativeDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

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
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.inset)
            }
        }
    }
}
