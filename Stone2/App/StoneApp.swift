import SwiftUI
import SwiftData

@main
struct StoneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var projectsViewModel = ProjectsViewModel()
    @State private var syncService = CloudKitSyncService()
    @State private var launchAtLoginService = LaunchAtLoginService()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Project.self,
            TimeEntry.self,
            Folder.self,
            Tag.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        Settings {
            SettingsWindow(
                viewModel: projectsViewModel,
                syncService: syncService,
                launchAtLoginService: launchAtLoginService
            )
            .onAppear {
                let context = ModelContext(sharedModelContainer)
                projectsViewModel.configure(modelContext: context)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
