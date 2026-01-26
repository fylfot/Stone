import AppKit
import SwiftUI
import SwiftData

final class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var shared: AppDelegate!

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var reportsWindow: NSWindow?
    private var menuBarViewModel: MenuBarViewModel?
    private var timeEntryViewModel: TimeEntryViewModel?
    private var reportsViewModel: ReportsViewModel?
    private var modelContainer: ModelContainer?

    private let timeTracker = TimeTrackerService()
    private let systemEvents = SystemEventService()

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self

        setupModelContainer()
        setupViewModels()
        setupStatusItem()
        setupPopover()

        // Prevent app nap for accurate timing
        ProcessInfo.processInfo.beginActivity(
            options: .userInitiated,
            reason: "Time tracking requires accurate timing"
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        systemEvents.stopObserving()
    }

    private func setupModelContainer() {
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
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    private func setupViewModels() {
        guard let modelContainer else { return }
        let context = ModelContext(modelContainer)

        menuBarViewModel = MenuBarViewModel(
            timeTracker: timeTracker,
            systemEvents: systemEvents
        )
        menuBarViewModel?.configure(modelContext: context)

        timeEntryViewModel = TimeEntryViewModel()
        timeEntryViewModel?.configure(modelContext: context)

        reportsViewModel = ReportsViewModel()
        reportsViewModel?.configure(modelContext: context)
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            updateStatusButton(button)
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Update status item every second
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let button = self?.statusItem?.button else { return }
            self?.updateStatusButton(button)
        }
    }

    private func updateStatusButton(_ button: NSStatusBarButton) {
        let image = NSImage(systemSymbolName: "clock.fill", accessibilityDescription: "Stone")
        image?.isTemplate = true
        button.image = image

        if let viewModel = menuBarViewModel, viewModel.isTracking {
            button.title = " \(viewModel.currentDuration.formattedShortDuration)"

            // Tint with project color
            if let project = viewModel.activeProject {
                let color = NSColor(Color(hex: project.colorHex))
                button.contentTintColor = color
            }
        } else {
            button.title = ""
            button.contentTintColor = nil
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover?.behavior = .transient
        popover?.animates = true

        if let viewModel = menuBarViewModel {
            let contentView = MenuBarView(viewModel: viewModel)
            popover?.contentViewController = NSHostingController(rootView: contentView)
        }
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem?.button, let popover else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

            // Focus the popover window
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func showReportsWindow() {
        // Close popover first
        popover?.performClose(nil)

        if let window = reportsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        guard let viewModel = reportsViewModel else { return }

        // Refresh data when opening
        viewModel.loadData()

        let contentView = ReportsWindow(viewModel: viewModel)
        let hostingController = NSHostingController(rootView: contentView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = "Reports"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(NSSize(width: 700, height: 500))
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)

        reportsWindow = window
        NSApp.activate(ignoringOtherApps: true)
    }
}
