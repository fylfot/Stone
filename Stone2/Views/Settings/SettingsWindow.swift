import SwiftUI
import SwiftData

struct SettingsWindow: View {
    @Bindable var viewModel: ProjectsViewModel
    let syncService: CloudKitSyncService
    let launchAtLoginService: LaunchAtLoginService
    @State private var selectedTab = "projects"

    var body: some View {
        TabView(selection: $selectedTab) {
            ProjectsSettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Projects", systemImage: "folder")
                }
                .tag("projects")

            TagsSettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Tags", systemImage: "tag")
                }
                .tag("tags")

            SyncSettingsView(syncService: syncService)
                .tabItem {
                    Label("Sync", systemImage: "icloud")
                }
                .tag("sync")

            GeneralSettingsView(launchAtLoginService: launchAtLoginService)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag("general")
        }
        .frame(width: 500, height: 400)
    }
}

struct GeneralSettingsView: View {
    let launchAtLoginService: LaunchAtLoginService

    var body: some View {
        Form {
            Section("Startup") {
                Toggle("Launch at Login", isOn: .init(
                    get: { launchAtLoginService.isEnabled },
                    set: { launchAtLoginService.setEnabled($0) }
                ))

                if launchAtLoginService.status == .requiresApproval {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                        Text("Approval required in System Settings > General > Login Items")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("About") {
                LabeledContent("Version") {
                    Text("2.0.0")
                        .foregroundStyle(.secondary)
                }

                LabeledContent("Build") {
                    Text("1")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
