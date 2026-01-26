import SwiftUI
import SwiftData

@main
struct StoneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var projectsViewModel = ProjectsViewModel()

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
            SettingsWindow(viewModel: projectsViewModel)
                .onAppear {
                    let context = ModelContext(sharedModelContainer)
                    projectsViewModel.configure(modelContext: context)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
