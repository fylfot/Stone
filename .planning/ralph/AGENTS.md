# Codebase Patterns and Learnings

This file is automatically updated by Ralph after each iteration.
Future iterations will read this to learn from past work.

## Patterns Discovered

### Project Structure
- Swift code lives in `Stone2/` directory (separate from legacy Objective-C in `Stone/`)
- Uses Swift Package Manager for builds (`Package.swift`)
- Directory structure: App/, Models/, Services/, ViewModels/, Views/, Utilities/, Tests/

### Architecture
- MVVM with @Observable view models (not ObservableObject)
- SwiftData for persistence (not Core Data)
- AppKit NSStatusItem for menu bar, SwiftUI for popover content
- Services are standalone (TimeTrackerService, SystemEventService)

### Data Models
- All @Model classes should conform to `Identifiable` for SwiftUI ForEach
- Use UUID for IDs, not auto-incremented integers
- Relationships use @Relationship macro with deleteRule

### Services
- TimeTrackerService manages active timer state
- SystemEventService handles sleep/wake via NSWorkspace notifications
- Both are injected into view models

### Views
- Menu bar uses NSPopover with NSHostingController(rootView:)
- SwiftUI views use @Bindable for view models
- Use .contentShape(Rectangle()) for hit testing on custom rows

## Gotchas

### Swift/SwiftUI
- CGFloat arrays use subscript `[index]`, not `.at(index)` method
- TimeInterval formatting: use `Int(self)` then `%` operator, not `truncatingRemainder`
- @Model classes don't auto-conform to Identifiable

### macOS Menu Bar Apps
- Set LSUIElement=true in Info.plist to hide Dock icon
- Use ProcessInfo.beginActivity to prevent App Nap
- NSStatusItem button needs .target and .action set
- Popover needs .behavior = .transient to dismiss on click outside

### SwiftData
- ModelContext must be created from ModelContainer
- Use FetchDescriptor with #Predicate for queries
- Call modelContext.save() explicitly after changes

## Conventions

### File naming
- Models: `Project.swift`, `TimeEntry.swift`
- Services: `TimeTrackerService.swift`, `SystemEventService.swift`
- View Models: `MenuBarViewModel.swift`, `TimeEntryViewModel.swift`
- Views: `MenuBarView.swift`, `TimeEntryListView.swift`
- Extensions: `TimeInterval+Formatting.swift`, `Color+Hex.swift`

### Code style
- Use `Int()` for numeric conversions (per CLAUDE.md, not parseInt)
- Define functions as `let fn = () => {}` when possible
- Inline parameter types for non-reusable interfaces
- Prefer subscript access for arrays

### Testing
- Tests in `Tests/StoneTests.swift`
- Import SwiftUI in tests if testing Color extensions
- Use @testable import Stone

## Additional Services Discovered

### CloudKit Sync
- CloudKitSyncService wraps CKContainer for iCloud sync
- Use CKAccountStatus for account availability
- NotificationCenter for CKAccountChanged events
- SwiftData supports CloudKit via cloudKitDatabase parameter
- Server-wins conflict resolution is safest

### Launch at Login
- Use SMAppService.mainApp for modern login items API
- Check .status for .requiresApproval state
- register()/unregister() for enabling/disabling

### Reports
- ReportsViewModel aggregates TimeEntry data
- Swift Charts for pie (SectorMark) and bar (BarMark) charts
- NSSavePanel for CSV export
- ReportPeriod enum for date range selection

## Complete File Manifest

### App Layer
- App/StoneApp.swift - @main entry, Scene configuration
- App/AppDelegate.swift - Menu bar setup, window management

### Models
- Models/Project.swift - SwiftData project model
- Models/TimeEntry.swift - SwiftData time entry model
- Models/Folder.swift - Project folder hierarchy
- Models/Tag.swift - Project tagging

### Services
- Services/TimeTrackerService.swift - Timer management
- Services/SystemEventService.swift - Sleep/wake/idle detection
- Services/CloudKitSyncService.swift - iCloud sync
- Services/LaunchAtLoginService.swift - Login item management

### ViewModels
- ViewModels/MenuBarViewModel.swift - Menu bar state
- ViewModels/TimeEntryViewModel.swift - Entry editing
- ViewModels/ProjectsViewModel.swift - Project management
- ViewModels/ReportsViewModel.swift - Report data

### Views
- Views/MenuBar/MenuBarView.swift - Popover content
- Views/TimeEntry/TimeEntryListView.swift - Entry list/edit
- Views/Settings/SettingsWindow.swift - Preferences container
- Views/Settings/ProjectsSettingsView.swift - Project management
- Views/Settings/TagsSettingsView.swift - Tag management
- Views/Reports/ReportsWindow.swift - Reports window
- Views/Components/SyncStatusView.swift - Sync indicator

### Utilities
- Utilities/TimeInterval+Formatting.swift
- Utilities/Color+Hex.swift
- Utilities/Date+Extensions.swift

### Tests
- Tests/StoneTests.swift
