# Technology Stack

**Project:** Stone - macOS Menu Bar Time Tracker
**Platform:** macOS 14+ (Sonoma)
**Researched:** 2026-01-26
**Overall Confidence:** HIGH

## Executive Summary

Modern Swift/SwiftUI stack leveraging native macOS 14+ APIs. Core Data + CloudKit recommended over SwiftData due to CloudKit sharing limitations. MenuBarExtra provides native SwiftUI menu bar integration. Swift 6.2's "Approachable Concurrency" enables data-race safety without annotation fatigue.

## Core Framework & Language

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Swift | 6.2+ | Language | Current stable with "Approachable Concurrency" - data race safety without Swift 6.0's annotation fatigue. Better defaults (-default-isolation MainActor). |
| SwiftUI | 5.0+ (macOS 14) | UI Framework | Native declarative UI. MenuBarExtra support (macOS 13+). Better List performance (10x improvement on macOS 26). |
| Xcode | 26.1.1+ | IDE | Current stable. Required for Swift 6.2 and macOS 14+ SDK. |

**Rationale:**
- Swift 6.2's approachable concurrency maintains safety while reducing "async contamination"
- SwiftUI is production-ready as of 2025 - widespread adoption confirms maturity
- MenuBarExtra (macOS 13+) provides native menu bar integration vs legacy NSStatusItem

## Data Persistence

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Core Data | Current | Local persistence | Battle-tested, full CloudKit integration including public/shared databases. SwiftData still lacks shared/public CloudKit support. |
| CloudKit | Current | Cloud sync | Native iCloud integration. Requires Core Data for advanced features (sharing, public data). |

**Why NOT SwiftData:**
- SwiftData only supports private CloudKit databases (no sharing, no public data)
- Known issues with array ordering (randomly reorders elements on reload)
- "After discussing with DTS, I've started converting to Core Data + CloudKit" - common pattern for serious CloudKit use cases
- Still maturing - Core Data updates at WWDC25 suggest Apple not deprecating it

**Configuration Requirements:**
```swift
// Core Data + CloudKit container setup
let container = NSPersistentCloudKitContainer(name: "Stone")
container.loadPersistentStores { description, error in
    // Handle errors
}
```

**Entitlements Required:**
- `com.apple.developer.icloud-services` = ["CloudKit"]
- `com.apple.developer.icloud-container-identifiers` = ["iCloud.com.yourteam.Stone"]
- `com.apple.developer.aps-environment` = "production"
- Network: incoming/outgoing (required for CloudKit sync)

## Menu Bar Integration

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| MenuBarExtra | macOS 13+ | Menu bar presence | Native SwiftUI menu bar API. Cleaner than NSStatusItem. Two built-in styles: menu (pulldown) and window (popover). |
| AppKit bridge | As needed | Advanced interactions | For features MenuBarExtra doesn't expose (custom click handlers, advanced positioning). |

**MenuBarExtra Styles:**
```swift
// Window style (popover-like)
@main
struct StoneApp: App {
    var body: some Scene {
        MenuBarExtra("Stone", systemImage: "clock") {
            TimerView()
        }
        .menuBarExtraStyle(.window)
    }
}
```

**Known Limitations:**
- Settings scene integration requires workarounds on macOS 14+ (Apple removed `showSettingsWindow:` selector)
- Use SettingsAccess library or manual window management for preferences
- Activation policy juggling needed for proper window focus

**What NOT to use:**
- Legacy NSStatusItem directly - MenuBarExtra abstracts this better
- NSPopover manually - MenuBarExtra's `.window` style handles it

## Charts & Reporting

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Swift Charts | macOS 13+ | Data visualization | Native framework. Declarative syntax matches SwiftUI. Supports bar, line, pie charts with minimal code. |
| FileExporter | SwiftUI | Export functionality | Native file save dialog. Works with CSV, JSON, PDF. |

**Swift Charts Availability:**
- Requires macOS 13.0+ (shipped with macOS Ventura)
- Xcode 14.1+ required for full SDK support
- Hover gestures enabled by default on macOS for value selection

**Example Usage:**
```swift
import Charts

Chart(timeEntries) { entry in
    BarMark(
        x: .value("Date", entry.date),
        y: .value("Hours", entry.duration)
    )
}
```

## Data Export

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| SwiftCSV | Current | CSV parsing/export | If need bidirectional CSV (import + export). Lightweight, supports delimiters. |
| Native Codable | Built-in | JSON export | Simple JSON export. No dependencies. Use for API-style exports. |
| FileExporter | SwiftUI | File save dialog | Always use for save location picking. Native macOS experience. |

**Recommendation:** Use native `Codable` + `FileExporter` for CSV. SwiftCSV only if importing CSV data.

```swift
// Native CSV generation
let csvString = timeEntries.map { entry in
    "\(entry.date),\(entry.project),\(entry.duration)"
}.joined(separator: "\n")
```

## Supporting Libraries

### Recommended

| Library | Purpose | Why |
|---------|---------|-----|
| None initially | - | Start with native APIs. Add libraries only when native solution insufficient. |

### Consider Later (if needed)

| Library | Purpose | When |
|---------|---------|------|
| SettingsAccess | Settings window management | If MenuBarExtra settings integration proves insufficient |
| MenuBarExtraAccess | Programmatic menu visibility | If need to show/hide menu bar extra dynamically |
| SwiftCSV | CSV import | Only if users need to import CSV time logs |

**Philosophy:** Favor native APIs. Third-party libraries add dependency risk and update lag.

## Architecture Constraints

### App Sandbox (Required for Mac App Store)

**Entitlements Needed:**
- `com.apple.security.app-sandbox` = true
- `com.apple.security.network.client` = true (CloudKit)
- `com.apple.security.network.server` = true (CloudKit)
- `com.apple.developer.icloud-services` = ["CloudKit"]

**Implications:**
- File access restricted to user-selected files
- Must use Security-Scoped Bookmarks for persistent file access
- Network access requires entitlement declaration

### Agent App Configuration

For menu bar-only app (no Dock icon):
```xml
<!-- Info.plist -->
<key>LSUIElement</key>
<true/>
```

**Important:** This removes Dock icon and main menu bar. Settings must be accessed via menu bar extra menu.

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Persistence | Core Data + CloudKit | SwiftData | No shared/public CloudKit support. Array ordering bugs. Still maturing. |
| Menu Bar | MenuBarExtra | NSStatusItem | MenuBarExtra is native SwiftUI, cleaner API. NSStatusItem requires AppKit bridge. |
| Charts | Swift Charts | Third-party (Charts) | Native integration. Declarative syntax. No external dependencies. |
| Concurrency | Swift 6.2 | Swift 5 mode | Data race safety at compile time. Approachable concurrency reduces friction. |
| Export | Native Codable | SwiftCSVExport | Simpler. No dependencies. CSV generation is straightforward. |

## Migration Path from Objective-C

Current project is legacy Objective-C rewrite. Migration strategy:

1. **New Xcode Project**: Start fresh with SwiftUI app template
2. **Data Migration**: Export existing data, import into Core Data
3. **No Bridging**: Pure Swift rewrite, avoid Objective-C bridging overhead
4. **Feature Parity First**: Match existing features before adding new ones

**DO NOT:**
- Mix Objective-C/Swift in new project (increases complexity)
- Try to wrap existing Objective-C code (defeats rewrite purpose)
- Use deprecated APIs (NSStatusItem when MenuBarExtra available)

## Version Requirements Summary

| Component | Minimum Version | Recommended | Notes |
|-----------|----------------|-------------|-------|
| macOS | 14.0 (Sonoma) | 14.0+ | Target deployment |
| Xcode | 14.1 | 26.1.1+ | Current stable |
| Swift | 5.9 | 6.2+ | Approachable concurrency |
| Swift Charts | macOS 13+ | Latest | Requires Xcode 14.1+ |
| MenuBarExtra | macOS 13+ | Latest | Native SwiftUI |

## Installation & Setup

### New Project Creation
```bash
# Create new macOS app in Xcode
# File > New > Project > macOS > App
# Interface: SwiftUI
# Language: Swift
# Storage: Core Data
```

### Capabilities Configuration
1. Signing & Capabilities > + Capability
2. Add "iCloud" - check CloudKit
3. Add "Background Modes" - check Remote Notifications
4. Add "App Sandbox" (if Mac App Store)
   - Check "Outgoing Connections (Client)"
   - Check "Incoming Connections (Server)"

### Core Dependencies
```swift
// Package.swift (only if needed later)
dependencies: [
    // Start with zero dependencies
    // Add only when native solution insufficient
]
```

## Development Environment

**Current System:**
- macOS 26.1 (Darwin 25.1.0)
- Xcode 26.1.1
- Swift 6.2.1
- Target: arm64-apple-macosx26.0

**Deployment Target:** macOS 14.0 (Sonoma)

## Confidence Assessment

| Area | Level | Rationale |
|------|-------|-----------|
| Swift/SwiftUI | HIGH | Official docs, current versions verified, ecosystem mature |
| Core Data + CloudKit | HIGH | Well-documented limitation of SwiftData for sharing, community consensus |
| MenuBarExtra | HIGH | Official API since macOS 13, community adoption confirmed |
| Swift Charts | HIGH | Native framework, macOS 13+ availability verified |
| Export Strategy | HIGH | Native APIs sufficient, no external dependencies needed |

## Known Issues & Workarounds

### MenuBarExtra Settings Window (macOS 14+)
**Issue:** Apple removed `showSettingsWindow:` selector in Sonoma
**Workaround:** Use SettingsAccess library or manual NSWindow management
**Impact:** Settings require custom window lifecycle management

### Core Data CloudKit Performance
**Issue:** Initial sync can be slow for large datasets
**Mitigation:** Use NSPersistentCloudKitContainer's history tracking, batch operations
**Impact:** UX should show sync status, don't block UI on sync

### App Sandbox File Access
**Issue:** Sandboxed apps need explicit user permission for file access
**Mitigation:** Use FileExporter for exports (handles permissions)
**Impact:** Cannot auto-save to arbitrary locations, must prompt user

## Sources

**Official Documentation:**
- [Swift Charts - Apple Developer](https://developer.apple.com/documentation/Charts)
- [MenuBarExtra - Apple Developer](https://developer.apple.com/documentation/swiftui/menubarextra)
- [CloudKit - Apple Developer](https://developer.apple.com/documentation/cloudkit)
- [Enabling CloudKit in Your App - Apple Developer](https://developer.apple.com/documentation/cloudkit/enabling-cloudkit-in-your-app)
- [Adopting strict concurrency in Swift 6 apps - Apple Developer](https://developer.apple.com/documentation/swift/adoptingswift6)

**Community Resources & Best Practices:**
- [SwiftUI macOS menu bar app - Anagh Sharma](https://www.anaghsharma.com/blog/macos-menu-bar-app-with-swiftui)
- [Building a MacOS Menu Bar App with Swift - Medium](https://gaitatzis.medium.com/building-a-macos-menu-bar-app-with-swift-d6e293cd48eb)
- [Core Data vs SwiftData: Which Should You Use in 2025? - DistantJob](https://distantjob.com/blog/core-data-vs-swiftdata/)
- [SwiftData vs Core Data - Medium](https://medium.com/@arunzzrip/swiftdata-vs-core-data-ebfab59c80a2)
- [Should I use SwiftData or CoreData in 2025? - byby.dev](https://byby.dev/swiftdata-or-coredata)
- [Approachable Concurrency in Swift 6.2 - avanderlee.com](https://www.avanderlee.com/concurrency/approachable-concurrency-in-swift-6-2-a-clear-guide/)
- [State of Swift 2026 - Dev Newsletter](https://devnewsletter.com/p/state-of-swift-2026)
- [MenuBarExtra Settings Integration - Peter Steinberger](https://steipete.me/posts/2025/showing-settings-from-macos-menu-bar-items)
- [Syncing SwiftData with CloudKit - Hacking with Swift](https://www.hackingwithswift.com/books/ios-swiftui/syncing-swiftdata-with-cloudkit)
- [Using App Sandbox for macOS App - Medium](https://medium.com/macos-app-development/using-app-sandbox-for-macos-app-9bc90556f9ce)

**Technical Forums:**
- [Swift Charts forum - Apple Developer Forums](https://developer.apple.com/forums/tags/swift-charts)
- [MenuBarExtra availability - Apple Developer Forums](https://developer.apple.com/forums/thread/740943)
- [Swift Data and CloudKit - Hacking with Swift Forums](https://www.hackingwithswift.com/forums/swift/swift-data-and-cloudkit/22393)

**Additional Resources:**
- [CSVEditor macOS example - GitHub](https://github.com/gahntpo/CSVEditor)
- [SettingsAccess library - GitHub](https://github.com/orchetect/SettingsAccess)
- [SwiftCSV parser - GitHub](https://github.com/swiftcsv/SwiftCSV)
