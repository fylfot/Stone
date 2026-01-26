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
