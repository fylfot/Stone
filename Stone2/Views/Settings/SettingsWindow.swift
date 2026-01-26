import SwiftUI
import SwiftData

struct SettingsWindow: View {
    @Bindable var viewModel: ProjectsViewModel
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

            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag("general")
        }
        .frame(width: 500, height: 400)
    }
}

struct GeneralSettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        Form {
            Toggle("Launch at Login", isOn: $launchAtLogin)
        }
        .formStyle(.grouped)
        .padding()
    }
}
