# Architecture Patterns for SwiftUI macOS Menu Bar Time Tracker

**Domain:** macOS menu bar time tracking application
**Researched:** 2026-01-26
**Confidence:** HIGH

## Executive Summary

Modern SwiftUI menu bar apps use a hybrid architecture combining SwiftUI's declarative UI with AppKit lifecycle management. The optimal pattern for a time tracker involves: MenuBarExtra scene for menu bar presence, @Observable classes for shared state management, Environment-based window coordination, and CloudKit integration via SwiftData. Critical architectural decisions include choosing between menu vs window popover styles, managing timer state across the app lifecycle, and coordinating multiple windows without coupling.

## Recommended Architecture

### High-Level Structure

```
App Entry Point (@main)
├── AppDelegate (via @NSApplicationDelegateAdaptor)
│   └── Lifecycle events, sleep notifications, activation policy
├── MenuBarExtra Scene
│   ├── Timer display in status bar
│   └── Quick actions popover/menu
├── Window Scenes
│   ├── Preferences Window
│   └── Reports Window
└── Shared Services (@Observable classes)
    ├── TimerManager
    ├── DataManager (SwiftData/CloudKit)
    └── ZoneManager
```

### Component Architecture

| Component | Responsibility | Type | Lifecycle |
|-----------|---------------|------|-----------|
| App | Entry point, scene coordination | Struct conforming to App protocol | Application lifetime |
| AppDelegate | System lifecycle events, sleep notifications | NSApplicationDelegate | Application lifetime |
| MenuBarExtra | Menu bar icon, timer display, quick popover | Scene | Application lifetime |
| PreferencesWindow | Settings UI | WindowGroup scene | On-demand |
| ReportsWindow | Reports UI | WindowGroup scene | On-demand |
| TimerManager | Timer state, start/stop, current zone | @Observable class | Application lifetime |
| DataManager | SwiftData persistence, CloudKit sync | @Observable class | Application lifetime |
| ZoneManager | Project/zone CRUD, organization | @Observable class | Application lifetime |

### Data Flow Pattern

**Modern SwiftUI State Management (iOS 17+, macOS 14+):**

```swift
// Service layer - Application-scoped state
@Observable
class TimerManager {
    var isRunning: Bool = false
    var currentZone: Zone?
    var elapsedSeconds: Int = 0

    private var timer: Timer?

    func start(zone: Zone) { /* ... */ }
    func stop() { /* ... */ }
}

// App-level injection
@main
struct StoneApp: App {
    @State private var timerManager = TimerManager()
    @State private var dataManager = DataManager()

    var body: some Scene {
        MenuBarExtra(/* ... */) {
            ContentView()
                .environment(timerManager)
                .environment(dataManager)
        }

        WindowGroup(id: "preferences") {
            PreferencesView()
                .environment(timerManager)
                .environment(dataManager)
        }
    }
}

// View consumption
struct ContentView: View {
    @Environment(TimerManager.self) private var timerManager

    var body: some View {
        Text("\(timerManager.elapsedSeconds)s")
    }
}
```

**Key principles:**
- Store app-level state in App struct using @State (not in views)
- Use @Observable for service classes (replaces ObservableObject)
- Inject via .environment() for implicit dependency injection
- Views access via @Environment (automatic updates on change)
- No @Published needed - all properties auto-tracked

## Patterns to Follow

### Pattern 1: MenuBarExtra Scene Structure

**What:** SwiftUI-native menu bar app pattern introduced in macOS 13 Ventura.

**When:** Building menu bar apps with modern SwiftUI (macOS 13+).

**Implementation:**

```swift
@main
struct StoneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var timerManager = TimerManager()

    var body: some Scene {
        // Menu bar presence
        MenuBarExtra {
            // Popover content
            MenuBarContentView()
                .environment(timerManager)
        } label: {
            // Menu bar icon + timer display
            HStack(spacing: 4) {
                Image(systemName: "clock")
                Text(timerManager.formattedTime)
            }
        }
        .menuBarExtraStyle(.window) // Use .window for custom UI with controls

        // Additional windows
        WindowGroup(id: "preferences") {
            PreferencesView()
                .environment(timerManager)
        }
        .windowResizability(.contentSize)

        WindowGroup(id: "reports") {
            ReportsView()
                .environment(timerManager)
        }
    }
}
```

**Styles:**
- `.menuBarExtraStyle(.menu)` - Standard macOS menu (text, buttons, dividers only)
- `.menuBarExtraStyle(.window)` - Custom popover window (supports sliders, pickers, any SwiftUI view)

**For time tracker:** Use `.window` style to show timer controls, zone picker, quick stats.

### Pattern 2: AppDelegate Integration for Lifecycle

**What:** Hybrid pattern using @NSApplicationDelegateAdaptor to handle AppKit lifecycle events while maintaining SwiftUI structure.

**When:** Need system-level events (sleep/wake notifications, activation policy, menu bar setup).

**Implementation:**

```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from Dock (menu bar only app)
        NSApp.setActivationPolicy(.accessory)

        // Register for sleep/wake notifications
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemWillSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }

    @objc func systemWillSleep() {
        // Auto-stop timer on sleep
        NotificationCenter.default.post(name: .systemWillSleep, object: nil)
    }

    @objc func systemDidWake() {
        // Resume or alert user
        NotificationCenter.default.post(name: .systemDidWake, object: nil)
    }
}

// In TimerManager
init() {
    NotificationCenter.default.addObserver(
        forName: .systemWillSleep,
        object: nil,
        queue: .main
    ) { [weak self] _ in
        self?.stop()
    }
}
```

**Why needed:** SwiftUI doesn't provide native access to:
- Activation policy (hide from Dock)
- System sleep/wake notifications
- Application lifecycle hooks beyond basic scene events

### Pattern 3: Timer State Management

**What:** Centralized timer logic in @Observable manager, avoiding singletons.

**When:** Background timer that updates UI and needs to be accessed across multiple views/windows.

**Implementation:**

```swift
@Observable
class TimerManager {
    var isRunning: Bool = false
    var currentZone: Zone?
    var elapsedSeconds: Int = 0
    var startTime: Date?

    private var timer: Timer?
    private let dataManager: DataManager

    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }

    func start(zone: Zone) {
        guard !isRunning else { return }

        currentZone = zone
        startTime = Date()
        isRunning = true

        // Use Timer.publish for Combine-based approach, or:
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedSeconds += 1
        }

        // Ensure timer runs even when menu is open
        RunLoop.current.add(timer!, forMode: .common)
    }

    func stop() {
        guard isRunning else { return }

        timer?.invalidate()
        timer = nil

        // Save period to database
        if let zone = currentZone, let start = startTime {
            let period = TimePeriod(
                zone: zone,
                startTime: start,
                endTime: Date(),
                duration: elapsedSeconds
            )
            dataManager.save(period)
        }

        reset()
    }

    private func reset() {
        isRunning = false
        currentZone = nil
        elapsedSeconds = 0
        startTime = nil
    }

    var formattedTime: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
```

**Critical details:**
- Add timer to `.common` RunLoop mode so it continues when menu is open
- Use `[weak self]` in timer closure to prevent retain cycles
- Inject DataManager instead of using singleton pattern
- Update properties directly (no @Published needed with @Observable)

### Pattern 4: Window Coordination

**What:** Environment-based window management using openWindow action.

**When:** Opening preferences/reports windows from menu bar or other windows.

**Implementation:**

```swift
// In menu bar popover or any view
struct MenuBarContentView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(TimerManager.self) private var timerManager

    var body: some View {
        VStack {
            // Timer display
            TimerDisplayView()

            Divider()

            // Actions
            Button("Preferences...") {
                openWindow(id: "preferences")
            }
            .keyboardShortcut(",", modifiers: .command)

            Button("Reports...") {
                openWindow(id: "reports")
            }

            Divider()

            Button("Quit Stone") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding()
    }
}
```

**Window identity:**
- Each WindowGroup needs unique `id: String` parameter
- Use `openWindow(id:)` to show specific window
- System handles window lifecycle (reuses if already open)

**Alternative for data passing:**

```swift
// Window that receives data
WindowGroup(id: "zoneDetails", for: Zone.ID.self) { $zoneID in
    if let zoneID = zoneID {
        ZoneDetailsView(zoneID: zoneID)
    }
}

// Opening with data
openWindow(id: "zoneDetails", value: zone.id)
```

### Pattern 5: CloudKit Integration via SwiftData

**What:** Local-first persistence with automatic CloudKit sync.

**When:** Need iCloud sync without managing CloudKit complexity directly.

**Implementation:**

```swift
import SwiftData

// Model definitions
@Model
class Zone {
    @Attribute(.unique) var id: UUID
    var name: String
    var color: String
    var createdAt: Date
    var folder: String?
    var tags: [String]

    @Relationship(deleteRule: .cascade, inverse: \TimePeriod.zone)
    var periods: [TimePeriod]

    init(name: String, color: String, folder: String? = nil, tags: [String] = []) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.createdAt = Date()
        self.folder = folder
        self.tags = tags
        self.periods = []
    }
}

@Model
class TimePeriod {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date
    var duration: Int // seconds
    var zone: Zone?

    init(zone: Zone, startTime: Date, endTime: Date, duration: Int) {
        self.id = UUID()
        self.zone = zone
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
    }
}

// App setup with CloudKit sync
@main
struct StoneApp: App {
    var body: some Scene {
        MenuBarExtra(/* ... */) { /* ... */ }
            .modelContainer(for: [Zone.self, TimePeriod.self]) { result in
                // CloudKit sync configured here
            }
    }
}

// DataManager using SwiftData
@Observable
class DataManager {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ period: TimePeriod) {
        modelContext.insert(period)
        try? modelContext.save()
        // CloudKit sync happens automatically
    }

    func fetchZones() -> [Zone] {
        let descriptor = FetchDescriptor<Zone>(
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}

// View usage with @Query
struct ZoneListView: View {
    @Query(sort: \.name) private var zones: [Zone]

    var body: some View {
        List(zones) { zone in
            ZoneRowView(zone: zone)
        }
    }
}
```

**CloudKit setup requirements:**
1. Enable CloudKit capability in Xcode
2. Enable "Remote Notifications" in Background Modes (for sync notifications)
3. SwiftData automatically syncs to private CloudKit database

**Important:** Use @Query directly in views (not through manager) for optimal SwiftUI reactivity when CloudKit sync updates arrive.

### Pattern 6: Agent Application (No Dock Icon)

**What:** Menu bar-only app that doesn't appear in Dock or app switcher.

**When:** Building pure menu bar utilities.

**Implementation:**

**Option 1: Info.plist (Recommended)**

```xml
<!-- In Stone-Info.plist -->
<key>LSUIElement</key>
<true/>
```

**Option 2: Programmatic (AppDelegate)**

```swift
func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)
}
```

**Consequences:**
- App won't show in Dock
- Won't show in Command+Tab switcher
- Must provide Quit button in menu (no Dock menu to quit from)
- Windows may not activate properly (need to call `NSApp.activate(ignoringOtherApps: true)`)

**Window activation fix:**

```swift
// When opening preferences/reports window
WindowGroup(id: "preferences") {
    PreferencesView()
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
        }
}
```

## Anti-Patterns to Avoid

### Anti-Pattern 1: Singleton Hell

**What:** Using `static let shared` singletons for TimerManager, DataManager, etc.

**Why bad:**
- Global mutable state
- Impossible to test (can't inject dependencies)
- Couples entire app to single instance
- Makes view previews difficult
- Violates dependency injection principles

**Instead:** Use @Observable with @State in App struct, inject via Environment:

```swift
// BAD
class TimerManager {
    static let shared = TimerManager()
    private init() {}
}

// In views
TimerManager.shared.start()

// GOOD
@Observable class TimerManager { /* ... */ }

@main
struct StoneApp: App {
    @State private var timerManager = TimerManager()

    var body: some Scene {
        MenuBarExtra { /* ... */ }
            .environment(timerManager)
    }
}

// In views
@Environment(TimerManager.self) private var timerManager
```

### Anti-Pattern 2: ObservableObject with @Published

**What:** Using the older ObservableObject protocol with @Published properties.

**Why bad:**
- Causes entire object to publish changes (performance)
- More boilerplate than @Observable
- Requires @ObservedObject/@StateObject distinctions
- Less efficient view updates

**Instead:** Use @Observable macro (iOS 17+, macOS 14+):

```swift
// OLD WAY (macOS 13 and earlier)
class TimerManager: ObservableObject {
    @Published var isRunning = false
    @Published var elapsedSeconds = 0
}

// In views
@StateObject private var timerManager = TimerManager()

// NEW WAY (macOS 14+)
@Observable
class TimerManager {
    var isRunning = false
    var elapsedSeconds = 0
}

// In App struct
@State private var timerManager = TimerManager()

// In views
@Environment(TimerManager.self) private var timerManager
```

### Anti-Pattern 3: Timer in View Lifecycle

**What:** Creating Timer instances in view lifecycle hooks (onAppear, task, etc.).

**Why bad:**
- Timer gets recreated every time view appears
- Difficult to share timer state across views
- Memory leaks if not properly invalidated
- Timer stops when view disappears

**Instead:** Centralize timer in TimerManager service:

```swift
// BAD
struct TimerView: View {
    @State private var seconds = 0

    var body: some View {
        Text("\(seconds)")
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    seconds += 1
                }
            }
    }
}

// GOOD
@Observable
class TimerManager {
    var elapsedSeconds = 0
    private var timer: Timer?

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
        }
    }
}

struct TimerView: View {
    @Environment(TimerManager.self) private var timerManager

    var body: some View {
        Text("\(timerManager.elapsedSeconds)")
    }
}
```

### Anti-Pattern 4: MenuBarExtra with .menu Style for Complex UI

**What:** Using `.menuBarExtraStyle(.menu)` when you need rich UI with controls.

**Why bad:**
- Limited to text, buttons, and dividers
- Button styles ignored to match macOS menu appearance
- Can't use sliders, pickers, charts, or custom controls
- Frustrating developer experience fighting against limitations

**Instead:** Use `.menuBarExtraStyle(.window)` for time tracker controls:

```swift
// BAD - Limited to basic menu items
MenuBarExtra("Stone", systemImage: "clock") {
    Button("Start Timer") { /* ... */ }
    Button("Stop Timer") { /* ... */ }
    // Can't add: zone picker, time display, progress bar, etc.
}
.menuBarExtraStyle(.menu)

// GOOD - Full SwiftUI control
MenuBarExtra {
    VStack {
        // Rich UI with any SwiftUI views
        TimerDisplay()
        ZonePicker()
        ProgressView(value: progress)
        Slider(value: $volume)
        Button("Start") { /* ... */ }
    }
} label: {
    Label("Stone", systemImage: "clock")
}
.menuBarExtraStyle(.window)
```

### Anti-Pattern 5: Manual CloudKit API Usage

**What:** Using CloudKit APIs directly (CKContainer, CKRecord, etc.) with SwiftData.

**Why bad:**
- SwiftData handles CloudKit sync automatically
- Mixing manual CloudKit with SwiftData causes conflicts
- Much more code to maintain
- Sync logic is error-prone and complex

**Instead:** Let SwiftData handle CloudKit:

```swift
// BAD - Manual CloudKit management
class DataManager {
    private let container = CKContainer.default()

    func saveZone(_ zone: Zone) async throws {
        let record = CKRecord(recordType: "Zone")
        record["name"] = zone.name
        // ... more manual mapping
        try await container.privateCloudDatabase.save(record)
    }
}

// GOOD - SwiftData automatic sync
@main
struct StoneApp: App {
    var body: some Scene {
        MenuBarExtra { /* ... */ }
            .modelContainer(for: [Zone.self, TimePeriod.self])
            // CloudKit sync happens automatically
    }
}

// Just use SwiftData normally
@Query private var zones: [Zone]
```

### Anti-Pattern 6: Not Using .common RunLoop Mode for Timers

**What:** Creating Timer without adding to .common RunLoop mode.

**Why bad:**
- Timer pauses when menu bar popover is open (tracking is active)
- User interaction blocks timer updates
- Inconsistent timer behavior

**Instead:** Always add timer to .common mode:

```swift
// BAD
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    elapsedSeconds += 1
}
// Timer stops when menu is interacted with

// GOOD
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    elapsedSeconds += 1
}
RunLoop.current.add(timer!, forMode: .common)
// Timer continues running during user interaction
```

## Component Build Order

Recommended implementation sequence based on dependencies:

### Phase 1: Foundation (Core Architecture)

**Build order:**
1. Project setup + SwiftUI App entry point
2. AppDelegate integration + activation policy
3. Basic MenuBarExtra (static icon, empty menu)
4. @Observable service classes (empty shells)
5. Environment injection setup

**Why first:** Establishes architectural skeleton that everything builds on.

**Validation:** Menu bar icon appears, app doesn't show in Dock, services accessible via Environment.

### Phase 2: Data Layer

**Build order:**
1. SwiftData models (Zone, TimePeriod)
2. ModelContainer configuration
3. DataManager with basic CRUD
4. Test data creation for development

**Why second:** Data layer needed before implementing business logic.

**Validation:** Can create/fetch zones and periods, data persists across app restarts.

### Phase 3: Timer Core

**Build order:**
1. TimerManager with start/stop/reset
2. Timer display in menu bar label
3. Zone selection in popover
4. Save TimePeriod on timer stop
5. Sleep notification handling (auto-stop)

**Why third:** Core value proposition - time tracking works.

**Validation:** Can start/stop timer, see time count up, data saves to database.

### Phase 4: Zone Management UI

**Build order:**
1. Zone list view in preferences
2. Create/edit/delete zones
3. Color picker for zones
4. Basic zone organization (folders later)

**Why fourth:** Needs timer to test zone selection, but not critical for MVP.

**Validation:** Can manage zones from preferences window, changes reflect in timer popover.

### Phase 5: Reports Window

**Build order:**
1. Reports window scene setup
2. Fetch periods by date range
3. Display periods grouped by day
4. Time summaries per zone
5. Basic charts (time distribution)

**Why fifth:** Requires data from timer usage, enhances but not required for core tracking.

**Validation:** Can view tracked periods, see summaries, understand time distribution.

### Phase 6: Advanced Organization

**Build order:**
1. Folder support for zones
2. Tag support for zones
3. Filtering in zone picker
4. Hierarchical zone display

**Why sixth:** Enhancement to zone management, not core functionality.

**Validation:** Can organize zones into folders, filter by tags.

### Phase 7: CloudKit Sync

**Build order:**
1. Enable CloudKit capability
2. Configure SwiftData model container for CloudKit
3. Test sync between devices
4. Handle sync conflicts (SwiftData automatic)
5. Background notification handling

**Why last:** Most complex, depends on stable data model, not needed for single-device usage.

**Validation:** Data syncs between devices, conflicts resolve gracefully.

## Scalability Considerations

| Concern | At 10 zones | At 100 zones | At 10K+ periods |
|---------|-------------|--------------|-----------------|
| Zone list rendering | Direct @Query works | Still fast with @Query | Same (zones grow slowly) |
| Period queries | Fetch all works | Date range filtering needed | Pagination required |
| CloudKit sync | Instant | < 5 sec sync | Batch operations, background sync |
| Timer performance | No impact | No impact | No impact (timer independent) |
| Reports generation | Instant | Instant with indexes | Requires optimization, caching |

**When to optimize:**
- Reports: Add computed properties for common aggregations when > 1000 periods
- Zone picker: Add search/filtering when > 50 zones
- CloudKit: Monitor CKQueryOperation batch sizes, implement incremental sync for > 10K records

## Technology Decisions

| Category | Recommended | Version | Rationale |
|----------|-------------|---------|-----------|
| Language | Swift | 5.9+ | Modern, safe, SwiftUI native |
| UI Framework | SwiftUI | macOS 14+ | Declarative, less code than AppKit |
| Persistence | SwiftData | macOS 14+ | Modern, simple, automatic CloudKit sync |
| Sync | CloudKit (via SwiftData) | N/A | Native, free tier, automatic with SwiftData |
| Architecture | @Observable + Environment | macOS 14+ | Clean DI, performance, minimal boilerplate |
| Testing | XCTest | Built-in | Standard Apple testing framework |

## Testing Strategy

**Unit tests:**
- TimerManager logic (start/stop/reset)
- DataManager CRUD operations
- Date/duration calculations
- Zone organization logic

**Integration tests:**
- Timer → DataManager flow
- SwiftData model relationships
- CloudKit sync (requires real CloudKit environment)

**UI tests:**
- Menu bar interaction
- Window opening
- Timer start/stop from UI

**Testing with @Observable and Environment:**

```swift
final class TimerManagerTests: XCTestCase {
    func testTimerStartStop() {
        let modelConfig = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Zone.self, TimePeriod.self, configurations: modelConfig)
        let dataManager = DataManager(modelContext: container.mainContext)
        let timerManager = TimerManager(dataManager: dataManager)

        let zone = Zone(name: "Test Project", color: "#FF0000")

        timerManager.start(zone: zone)
        XCTAssertTrue(timerManager.isRunning)
        XCTAssertEqual(timerManager.currentZone?.name, "Test Project")

        timerManager.stop()
        XCTAssertFalse(timerManager.isRunning)
        XCTAssertNil(timerManager.currentZone)
    }
}
```

## Migration from Legacy App

**Legacy architecture (Objective-C):**
- AppDelegate-based with NSStatusItem
- Custom NSView subclasses (ZoneView, ReportView)
- NSKeyedArchiver for persistence
- Manual file I/O for data

**Migration strategy:**
1. Parse legacy NSKeyedArchiver data format
2. Convert to SwiftData models
3. One-time import on first launch
4. Keep legacy app installed during transition (user choice)

**Data import:**

```swift
class LegacyDataImporter {
    func importLegacyData() async throws {
        // Find legacy data file
        let legacyPath = /* ... */

        // Unarchive legacy objects
        let legacyZones = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [LegacyZone]

        // Convert to SwiftData models
        for legacyZone in legacyZones {
            let zone = Zone(
                name: legacyZone.name,
                color: legacyZone.color,
                folder: nil,
                tags: []
            )
            modelContext.insert(zone)

            // Convert periods
            for legacyPeriod in legacyZone.periods {
                let period = TimePeriod(
                    zone: zone,
                    startTime: legacyPeriod.startTime,
                    endTime: legacyPeriod.endTime,
                    duration: legacyPeriod.duration
                )
                modelContext.insert(period)
            }
        }

        try modelContext.save()
    }
}
```

## Key Architectural Decisions

| Decision | Options Considered | Chosen | Rationale |
|----------|-------------------|--------|-----------|
| State management | ObservableObject vs @Observable | @Observable | macOS 14+ target, better performance, less boilerplate |
| Menu bar style | .menu vs .window | .window | Need rich UI controls for timer/zone picker |
| Persistence | Core Data vs SwiftData | SwiftData | Simpler API, automatic CloudKit, modern |
| CloudKit approach | Manual API vs SwiftData integration | SwiftData | Automatic sync, less code, fewer bugs |
| Dependency injection | Singletons vs Environment | Environment | Testable, clean, SwiftUI-native |
| App lifecycle | Pure SwiftUI vs AppDelegate | Hybrid | Need AppDelegate for sleep notifications |
| Window management | Manual NSWindow vs SwiftUI scenes | SwiftUI scenes | Declarative, system-managed lifecycle |

## Common Pitfalls for Time Trackers

### Pitfall 1: Timer Drift

**What goes wrong:** Using repeated 1-second timer intervals accumulates drift over long tracking sessions.

**Why it happens:** Timer doesn't guarantee exact 1.0 second intervals, small delays compound.

**Prevention:**
```swift
// BAD - Accumulates drift
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    self?.elapsedSeconds += 1
}

// GOOD - Calculate from start time
func updateElapsedTime() {
    guard let startTime = startTime else { return }
    elapsedSeconds = Int(Date().timeIntervalSince(startTime))
}

timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    self?.updateElapsedTime()
}
```

### Pitfall 2: Not Handling Sleep/Wake

**What goes wrong:** Timer continues "running" during system sleep, showing incorrect elapsed time.

**Why it happens:** Timer doesn't fire during sleep, but startTime remains in past.

**Prevention:**
- Auto-stop timer on sleep notification
- Ask user if they want to continue on wake
- Store sleep/wake timestamps for manual adjustment

### Pitfall 3: CloudKit Sync Conflicts

**What goes wrong:** Same zone edited on two devices causes data conflicts.

**Why it happens:** Concurrent edits without conflict resolution.

**Prevention:** SwiftData handles this automatically with last-write-wins strategy. For custom logic, implement conflict resolution in ModelContainer configuration.

### Pitfall 4: Menu Bar Icon Not Updating

**What goes wrong:** Timer runs but menu bar icon doesn't show updated time.

**Why it happens:** Menu bar label not observing TimerManager changes.

**Prevention:** Ensure MenuBarExtra label closure reads @Observable properties:

```swift
MenuBarExtra {
    ContentView()
} label: {
    // This closure must read timerManager property to update
    Text(timerManager.formattedTime)
}
.environment(timerManager) // Ensure environment is set
```

## References and Sources

### Official Apple Documentation
- [Building and customizing the menu bar with SwiftUI](https://developer.apple.com/documentation/SwiftUI/Building-and-customizing-the-menu-bar-with-SwiftUI)
- [Bring multiple windows to your SwiftUI app - WWDC22](https://developer.apple.com/videos/play/wwdc2022/10061/)
- [Efficiency awaits: Background tasks in SwiftUI - WWDC22](https://developer.apple.com/videos/play/wwdc2022/10142/)

### Architecture Patterns
- [Build a macOS menu bar utility in SwiftUI](https://nilcoalescing.com/blog/BuildAMacOSMenuBarUtilityInSwiftUI/)
- [Window management in SwiftUI](https://swiftwithmajid.com/2022/11/02/window-management-in-swiftui/)
- [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)
- [App architecture basics in SwiftUI, Part 2: SwiftUI's natural pattern](https://www.cocoawithlove.com/blog/swiftui-natural-pattern.html)

### State Management
- [Using @Observable in SwiftUI views](https://nilcoalescing.com/blog/ObservableInSwiftUI/)
- [Observable Macro in SwiftUI: A Game-Changer for State Management](https://anushka-samarasinghe.medium.com/observable-macro-in-swiftui-a-game-changer-for-state-management-b53e04274dbb)
- [A guide to SwiftUI's state management system](https://www.swiftbysundell.com/articles/swiftui-state-management-guide/)

### MenuBarExtra Specifics
- [Showing Settings from macOS Menu Bar Items: A 5-Hour Journey](https://steipete.me/posts/2025/showing-settings-from-macos-menu-bar-items) - February 2025
- [Create a mac menu bar app in SwiftUI with MenuBarExtra](https://sarunw.com/posts/swiftui-menu-bar-app/)
- [Creating Menu Bar Apps in SwiftUI for macOS Ventura](https://blog.schurigeln.com/menu-bar-apps-swift-ui/)

### CloudKit & SwiftData
- [SwiftData Meets CloudKit: Build Seamless Offline Apps in SwiftUI](https://medium.com/@ashitranpura27/swiftdata-meets-cloudkit-build-seamless-offline-apps-in-swiftui-5b5844f23ac3)
- [Swiftdata Architecture Patterns And Practices](https://azamsharp.com/2025/03/28/swiftdata-architecture-patterns-and-practices.html)
- [Syncing SwiftData with CloudKit](https://www.hackingwithswift.com/books/ios-swiftui/syncing-swiftdata-with-cloudkit)

### AppDelegate Integration
- [Using an AppDelegate with the new SwiftUI-based app lifecycle](https://www.swiftbysundell.com/tips/using-an-app-delegate-with-swiftui-app-lifecycle/)
- [SwiftUI App Lifecycle: How to Integrate AppDelegate Code in SwiftUI](https://www.oneclickitsolution.com/centerofexcellence/ios/swiftui-app-lifecycle-appdelegate-code)

### Timer Patterns
- [Simple State Management in SwiftUI](https://kanecohen.com/blog/state-management-sui/)
- [SwiftUI Cookbook, Chapter 8: Best Practices for State Management in SwiftUI](https://www.kodeco.com/books/swiftui-cookbook/v1.0/chapters/8-best-practices-for-state-management-in-swiftui)

### NSStatusItem & Popovers
- [Using NSPopover with NSStatusItem](https://shaheengandhi.com/using-nspopover-with-nsstatusitem/)
- [Pushing the limits of NSStatusItem beyond what Apple wants you to do](https://multi.app/blog/pushing-the-limits-nsstatusitem)

---

**Research confidence:** HIGH - Based on official Apple documentation, recent 2025-2026 sources, and established SwiftUI patterns for macOS 14+.
