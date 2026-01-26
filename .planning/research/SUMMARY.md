# Project Research Summary

**Project:** Stone - macOS Menu Bar Time Tracker
**Domain:** Freelancer time tracking application (macOS native)
**Researched:** 2026-01-26
**Confidence:** HIGH

## Executive Summary

Stone is a rewrite of a legacy Objective-C time tracker targeting solo freelancers who need simple, privacy-respecting time tracking without surveillance features. The research shows a clear path: modern Swift 6.2/SwiftUI with Core Data + CloudKit (not SwiftData due to CloudKit sharing limitations), MenuBarExtra for native menu bar integration, and a focus on manual control over automation.

The market expects three core capabilities: frictionless timer start/stop, clear billable vs non-billable distinction, and reliable data that never disappears. The competitive advantage lies in being Mac-native (not Electron), privacy-first (no screenshots/surveillance), and well-organized (folders + tags). The recommended architecture uses @Observable classes with Environment injection, MenuBarExtra in window style for rich UI, and AppDelegate integration for system lifecycle events.

The biggest risks are timer accuracy across sleep/wake cycles, CloudKit schema deployment to production, and App Nap throttling background timers. All three are well-documented with proven solutions. Start with local-only time tracking to validate core UX, then add CloudKit sync once the data model is stable.

## Key Findings

### Recommended Stack

Modern Swift/SwiftUI targeting macOS 14+ (Sonoma) provides the optimal foundation. Swift 6.2's "Approachable Concurrency" delivers data-race safety without annotation fatigue. MenuBarExtra (macOS 13+) offers native SwiftUI menu bar integration. Core Data + CloudKit beats SwiftData for this use case because SwiftData lacks shared/public CloudKit database support and has known array ordering bugs.

**Core technologies:**
- **Swift 6.2+**: Current stable with improved concurrency defaults, data race safety without Swift 6.0's friction
- **SwiftUI 5.0+ (macOS 14)**: MenuBarExtra support, declarative UI, production-ready as of 2025
- **Core Data + CloudKit**: Battle-tested persistence with full CloudKit integration (SwiftData still maturing)
- **Swift Charts (macOS 13+)**: Native data visualization, declarative syntax matching SwiftUI
- **MenuBarExtra (.window style)**: Custom popover for timer controls, zone picker, quick stats

**Critical version requirements:**
- macOS 14.0 (Sonoma) deployment target
- Xcode 26.1.1+ for Swift 6.2 and macOS 14+ SDK
- Swift Charts requires macOS 13.0+ (Xcode 14.1+)

**What NOT to use:**
- SwiftData (no shared/public CloudKit support, array ordering bugs)
- NSStatusItem directly (MenuBarExtra abstracts better)
- Third-party chart libraries (Swift Charts is native)

### Expected Features

Freelancer time trackers in 2026 have well-established expectations. The table stakes are timer start/stop, manual entry, idle detection, project organization, and basic reporting. Differentiation happens through automation quality (we'll skip AI for manual control), native platform integration (Mac-only advantage), and user experience simplicity.

**Must have (table stakes):**
- Start/stop timer with one-click menu bar access
- Manual time entry for retroactive logging
- Idle detection with smart prompts on wake (not annoying notifications)
- Auto-stop on system sleep
- Multiple projects with quick switcher
- Billable vs non-billable toggle (per project)
- Daily/weekly/monthly summaries
- CSV export for invoicing tools
- Persistent local storage (data never lost)

**Should have (competitive differentiators):**
- Hierarchical folders for project organization (Client > Project structure)
- Tags for cross-cutting categorization (multiple tags per project)
- Visual charts (time distribution pie/bar charts)
- Project colors for visual differentiation
- Global keyboard shortcuts (⌘⌥T to toggle, ⌘⌥P for project picker)
- CloudKit sync for multi-device access
- No account required (local-first, privacy-respecting)
- Native Mac polish (dark mode, menu bar integration, keyboard-first)

**Defer (v2+):**
- Revenue projections (hourly rates × billable hours)
- Calendar.app integration
- macOS Shortcuts app support
- Project templates
- Smart filters for reports

**Explicit anti-features (do NOT build):**
- Screenshot/activity monitoring (surveillance culture, privacy nightmare)
- Invasive reminders (kills flow state, users disable notifications)
- Built-in invoicing (feature creep, users have tools already)
- Team/multi-user features (solo freelancer focus)
- AI/automatic tracking (manual control, no surveillance feeling)

### Architecture Approach

The optimal pattern combines SwiftUI's declarative UI with AppKit lifecycle management. MenuBarExtra scene provides menu bar presence, @Observable classes manage shared state, Environment-based dependency injection keeps code testable, and Core Data + CloudKit handles persistence with automatic sync.

**Major components:**

1. **App Entry Point (@main)** — Scene coordination, @State-based service injection
2. **AppDelegate (NSApplicationDelegateAdaptor)** — System lifecycle (sleep notifications, activation policy)
3. **MenuBarExtra Scene (.window style)** — Timer display, quick actions popover with rich UI
4. **Window Scenes (Settings, Reports)** — On-demand windows via openWindow environment action
5. **TimerManager (@Observable)** — Timer state, start/stop, current zone tracking
6. **DataManager (@Observable)** — Core Data persistence, CloudKit sync coordination
7. **ZoneManager (@Observable)** — Project/zone CRUD, folder/tag organization

**Key architectural patterns:**

- **@Observable + Environment injection** (not singletons): Testable, clean, automatic view updates
- **MenuBarExtra window style** (not menu): Rich UI with controls, pickers, charts
- **AppDelegate hybrid** (not pure SwiftUI): Access to NSWorkspace sleep notifications
- **Core Data + CloudKit** (not SwiftData): Full CloudKit integration, battle-tested
- **Date-based timer calculation** (not tick counting): Prevents drift across sleep/wake
- **.common RunLoop mode**: Timer continues during menu interaction

**Data flow:**
- Services created as @State in App struct (application lifetime)
- Injected via .environment() to scenes
- Views consume via @Environment (automatic updates)
- SwiftUI @Query for direct database access (optimal CloudKit reactivity)

### Critical Pitfalls

Research identified 15 pitfalls ranging from critical (causes rewrites) to minor (cosmetic). The top 5 must be addressed in early phases to avoid architectural rework.

1. **Timer inaccuracy after sleep/wake cycles** — NSTimer accumulates sleep duration as elapsed time, causing massive drift. Prevention: Use NSWorkspace notifications to pause on sleep, resume on wake, and calculate elapsed time from Date timestamps (not tick counting).

2. **CloudKit schema not deployed to production** — Development sync works perfectly, but production users see zero sync (silent failure). Prevention: Add "Deploy CloudKit schema to production" to pre-release checklist, verify in CloudKit Dashboard before every TestFlight build.

3. **App Nap throttling background timers** — Timer updates slow from 1 second to 5-10 seconds when menu is closed. Prevention: Use ProcessInfo.processInfo.beginActivity with .userInitiated option while timer is running, add timer to .common RunLoop mode.

4. **NSStatusItem released causing menu bar icon to disappear** — Icon appears briefly then vanishes if not retained. Prevention: Store NSStatusItem as property in AppDelegate or use MenuBarExtra (SwiftUI handles retention).

5. **SwiftData relationships must be optional for CloudKit** — Non-optional relationships crash at runtime with CloudKit sync. Prevention: All relationships optional in @Model classes, use computed properties for convenience access.

**Additional moderate pitfalls:**
- Forgetting LSUIElement in Info.plist (app shows in Dock when it shouldn't)
- MenuBarExtra window style cannot be programmatically controlled (no toggle API)
- CloudKit rate limiting not handled gracefully (serviceUnavailable error, not requestRateLimited)
- SwiftUI view refresh only triggers on first appearance (menu shows stale data)
- iCloud account changes wipe local SwiftData (listen for CKAccountChanged notification)

## Implications for Roadmap

Based on research, the recommended phase structure follows dependency order: data model foundation, then core tracking, then organization features, then sync, then polish.

### Phase 1: Foundation + Core Tracking
**Rationale:** Establish architecture skeleton and prove timer accuracy before building on top.

**Delivers:**
- MenuBarExtra setup with static icon
- AppDelegate integration (sleep notifications, activation policy)
- @Observable service classes with Environment injection
- Core Data models (Zone, TimePeriod)
- TimerManager with start/stop/reset
- Date-based elapsed time calculation (prevents drift)
- Sleep/wake notification handling (auto-pause/resume)
- Timer display in menu bar label
- Basic zone selection in popover
- Save TimePeriod on timer stop

**Addresses from FEATURES.md:**
- Start/stop timer (table stakes)
- Manual time entry (table stakes)
- Auto-stop on sleep (table stakes)
- Timer visibility in menu bar (table stakes)
- Multiple projects (table stakes)

**Avoids from PITFALLS.md:**
- Pitfall 1: Timer drift (use Date timestamps, NSWorkspace notifications)
- Pitfall 3: App Nap throttling (beginActivity while tracking)
- Pitfall 4: NSStatusItem released (MenuBarExtra handles retention)
- Pitfall 6: Dock icon appears (set LSUIElement in Info.plist)

**Research flag:** LOW - Timer patterns are well-documented, NSWorkspace APIs are standard.

---

### Phase 2: Project Organization
**Rationale:** Users need to organize projects before long-term usage. Build on stable timer foundation.

**Delivers:**
- Zone CRUD UI in preferences window
- Window management via openWindow environment action
- Project colors (color picker)
- Billable vs non-billable toggle
- Folders for hierarchical organization (Client > Project)
- Tags for cross-cutting categorization
- Zone filtering in picker
- Project archiving (hide without delete)

**Addresses from FEATURES.md:**
- Project/client separation (table stakes)
- Billable vs non-billable (table stakes)
- Project colors (table stakes)
- Hierarchical folders (differentiator)
- Tags/labels (differentiator)

**Avoids from PITFALLS.md:**
- Pitfall 11: Multiple windows share state incorrectly (use FocusedValues or scene-specific state)
- Pitfall 15: Settings window opens multiple instances (use Settings scene or Window with id)

**Uses from STACK.md:**
- SwiftUI for preferences UI
- Core Data for zone persistence
- MenuBarExtra popover for quick zone switching

**Research flag:** LOW - Standard CRUD patterns, SwiftUI window management documented.

---

### Phase 3: Reporting
**Rationale:** Reports require time entry history. Build after users have tracked some time.

**Delivers:**
- Reports window scene
- Fetch periods by date range (custom or presets)
- Display periods grouped by day
- Time summaries per zone (daily/weekly/monthly)
- Swift Charts integration (pie/bar charts)
- CSV export via FileExporter
- JSON export for full data backup
- Edit time entries retroactively

**Addresses from FEATURES.md:**
- Daily/weekly/monthly totals (table stakes)
- Time entry history (table stakes)
- Export to CSV (table stakes)
- Visual charts (differentiator)
- Custom date ranges (differentiator)

**Avoids from PITFALLS.md:**
- Pitfall 9: SwiftUI view refresh issues (use @Query directly, timer-based updates)
- Pitfall 13: Memory leaks in views (weak self, limit @Query scope to recent entries)

**Uses from STACK.md:**
- Swift Charts for visualization (macOS 13+)
- FileExporter for CSV export (native SwiftUI)
- Native Codable for JSON export

**Research flag:** MEDIUM - Swift Charts examples are available but may need experimentation for optimal time tracking visualizations (pie vs bar vs timeline).

---

### Phase 4: CloudKit Sync
**Rationale:** Most complex feature. Build last when data model is stable and local experience is validated.

**Delivers:**
- CloudKit capability configuration
- NSPersistentCloudKitContainer setup
- Automatic sync to private CloudKit database
- Background notification handling
- Sync status UI in preferences
- Conflict resolution (last-write-wins via Core Data)
- iCloud account change detection
- Data export warning before account switch
- CloudKit quota monitoring

**Addresses from FEATURES.md:**
- Data backup (table stakes, iCloud as backup)
- CloudKit sync for multi-device (differentiator)
- No data loss on crashes (table stakes, CloudKit adds redundancy)

**Avoids from PITFALLS.md:**
- Pitfall 2: CloudKit schema not deployed (add to release checklist, verify in Dashboard)
- Pitfall 5: Non-optional relationships (all relationships optional in models)
- Pitfall 8: CloudKit rate limiting (exponential backoff, batch operations)
- Pitfall 10: iCloud account changes wipe data (listen for CKAccountChanged, show export dialog)
- Pitfall 14: CloudKit quota exceeded (monitor quota, show user-friendly message)

**Uses from STACK.md:**
- Core Data + CloudKit (not SwiftData)
- NSPersistentCloudKitContainer
- CloudKit entitlements (iCloud services, remote notifications)

**Research flag:** HIGH - CloudKit integration is complex, error handling needs careful testing. Phase-specific research recommended for production deployment checklist, conflict resolution strategies, and quota management.

---

### Phase 5: Polish + Power User Features
**Rationale:** Core functionality complete. Add convenience features and Mac-native polish.

**Delivers:**
- Global keyboard shortcuts (⌘⌥T toggle, ⌘⌥P project picker, ⌘⌥R reports)
- Preferences for customization (timer format, default project, launch at login)
- Dark mode support (automatic, SF Symbols + template images)
- Menu bar icon sizing (22×22pt canvas, 16×16pt icon)
- Idle detection with smart prompts (not annoying)
- Notification Center integration (optional end-of-day summary)
- Memory leak fixes (Instruments profiling)
- Performance optimization (lazy loading, efficient queries)

**Addresses from FEATURES.md:**
- Global keyboard shortcuts (differentiator)
- Menu bar customization (differentiator)
- Notification Center (differentiator, opt-in)
- Native Mac feel (differentiator)

**Avoids from PITFALLS.md:**
- Pitfall 7: MenuBarExtra programmatic control (workaround via AppKit bridge for shortcuts)
- Pitfall 12: Menu bar icon sizing (22×22pt canvas, template rendering)
- Pitfall 13: Memory leaks (Instruments, weak self in closures)

**Uses from STACK.md:**
- SwiftUI dark mode (automatic)
- SF Symbols (auto-sized for menu bar)

**Research flag:** LOW - Keyboard shortcuts and preferences are standard macOS patterns. Memory profiling via Instruments is well-documented.

---

### Phase Ordering Rationale

**Dependencies discovered:**
- Timer must work reliably before adding organization (can't test with broken timer)
- Organization needed before reporting (need projects to report on)
- Data model must be stable before CloudKit (schema changes require migration)
- CloudKit last to avoid breaking changes after production deployment
- Polish after core features validated with users

**Architecture patterns inform grouping:**
- Phase 1 establishes service layer (@Observable managers, Environment injection)
- Phase 2 builds on window management foundation
- Phase 3 leverages Core Data queries established in Phase 1-2
- Phase 4 adds CloudKit without changing data access patterns
- Phase 5 enhances existing UI without architectural changes

**Pitfall avoidance sequencing:**
- Critical pitfalls (1-5) all addressed in Phase 1 or 4 (when relevant)
- Moderate pitfalls spread across phases when introduced
- Phase 4 (CloudKit) bundles all sync-related pitfalls for focused attention

### Research Flags

**Phases needing deeper research during planning:**

- **Phase 3 (Reporting):** MEDIUM priority — Swift Charts examples exist but optimal visualizations for time tracking may need experimentation. Research focus: which chart types (pie/bar/timeline) best show time distribution, how to handle large datasets (thousands of entries), custom date range UX patterns.

- **Phase 4 (CloudKit Sync):** HIGH priority — CloudKit production deployment has many gotchas. Research focus: pre-release checklist for schema deployment, conflict resolution edge cases (concurrent edits on same entry), quota monitoring strategies, account change UX flows, TestFlight testing without development environment.

**Phases with standard patterns (skip research):**

- **Phase 1 (Foundation + Core Tracking):** Timer patterns well-documented, NSWorkspace APIs standard, MenuBarExtra examples plentiful.
- **Phase 2 (Project Organization):** Standard CRUD, SwiftUI window management documented, Core Data relationships established.
- **Phase 5 (Polish):** Keyboard shortcuts standard, preferences patterns established, Instruments profiling well-documented.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Official Apple docs, current versions verified (Swift 6.2, macOS 14+), Core Data vs SwiftData community consensus on CloudKit limitations |
| Features | HIGH | 10+ sources unanimous on table stakes, clear market patterns for differentiators, extensive competitor analysis (Toggl, Timing, Harvest, etc.) |
| Architecture | HIGH | Official SwiftUI patterns for macOS 14+, MenuBarExtra since macOS 13, @Observable since iOS 17/macOS 14, Core Data CloudKit integration battle-tested |
| Pitfalls | HIGH | All critical pitfalls verified via official Apple docs or multiple community sources (2024-2026 forums/blogs), sleep/wake behavior documented in Energy Efficiency Guide |

**Overall confidence:** HIGH

All four research areas achieved high confidence through triangulation of official Apple documentation, recent community resources (2024-2026), and established patterns. Core Data vs SwiftData decision particularly well-supported (CloudKit sharing limitations documented by multiple developers who switched from SwiftData to Core Data).

### Gaps to Address

**Swift Charts visualization patterns:**
- Research found Swift Charts integration is straightforward, but optimal chart types for time tracking unclear
- Validation approach: Prototype 2-3 chart styles (pie, stacked bar, timeline) in Phase 3, user test with beta users
- Fallback: All chart types are supported, so technical risk is low

**CloudKit production deployment checklist:**
- High-level steps documented, but need detailed pre-release checklist
- Validation approach: Phase-specific research in Phase 4 to create comprehensive deployment guide
- Critical: Test with fresh TestFlight install before public release

**Idle detection UX:**
- Technical implementation clear (NSWorkspace notifications), but prompt timing and messaging needs validation
- Validation approach: A/B test 2-3 idle thresholds (5/10/15 minutes) and prompt styles during beta
- Fallback: Make idle threshold configurable in preferences

**Memory leak patterns on macOS 14+:**
- Forums report SwiftUI view leaks on iOS 17/macOS 14, but may be fixed in newer versions
- Validation approach: Instruments profiling during Phase 5 development, test on macOS 14.0 and latest
- Monitoring: Add memory usage tracking to beta builds, gather telemetry

## Sources

### Primary (HIGH confidence)

**Official Apple Documentation:**
- [Swift Charts - Apple Developer](https://developer.apple.com/documentation/Charts)
- [MenuBarExtra - Apple Developer](https://developer.apple.com/documentation/swiftui/menubarextra)
- [CloudKit - Apple Developer](https://developer.apple.com/documentation/cloudkit)
- [Enabling CloudKit in Your App - Apple Developer](https://developer.apple.com/documentation/cloudkit/enabling-cloudkit-in-your-app)
- [Adopting strict concurrency in Swift 6 - Apple Developer](https://developer.apple.com/documentation/swift/adoptingswift6)
- [NSWorkspace Sleep/Wake Notifications](https://developer.apple.com/documentation/appkit/nsworkspace/willsleepnotification)
- [Energy Efficiency Guide: App Nap](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/AppNap.html)
- [Building and customizing the menu bar with SwiftUI - WWDC](https://developer.apple.com/documentation/SwiftUI/Building-and-customizing-the-menu-bar-with-SwiftUI)

**Technical Analysis (2025-2026):**
- [Core Data vs SwiftData: Which Should You Use in 2025? - DistantJob](https://distantjob.com/blog/core-data-vs-swiftdata/)
- [Should I use SwiftData or CoreData in 2025? - byby.dev](https://byby.dev/swiftdata-or-coredata)
- [SwiftData CloudKit Quirks - firewhale.io](https://firewhale.io/posts/swift-data-quirks/)
- [Key Considerations Before Using SwiftData - fatbobman.com](https://fatbobman.com/en/posts/key-considerations-before-using-swiftdata/)
- [Approachable Concurrency in Swift 6.2 - avanderlee.com](https://www.avanderlee.com/concurrency/approachable-concurrency-in-swift-6-2-a-clear-guide/)
- [State of Swift 2026 - Dev Newsletter](https://devnewsletter.com/p/state-of-swift-2026)

**Market Research (2026):**
- [Desklog: 7 Best Free Time Tracking Software for Freelancers 2026](https://desklog.io/blog/free-time-tracking-for-freelancers/)
- [Upwork: Best Freelance Time-Tracking Apps for 2026](https://www.upwork.com/resources/best-time-tracking-apps-for-freelancers)
- [Timing: 11 Best Time Tracking Apps for Mac in 2026](https://timingapp.com/blog/mac-time-tracking-apps/)
- [Toggl: Freelance Time Tracking for Projects, Clients, & Invoices](https://toggl.com/track/freelance-time-tracking/)
- [Digital Project Manager: 40 Best Time Tracking Software for Productivity In 2026](https://thedigitalprojectmanager.com/tools/time-tracking-software/)

### Secondary (MEDIUM confidence)

**Community Tutorials & Best Practices:**
- [Showing Settings from macOS Menu Bar Items: A 5-Hour Journey - steipete.me (Feb 2025)](https://steipete.me/posts/2025/showing-settings-from-macos-menu-bar-items)
- [macOS Menu Bar App Tutorial - anaghsharma.com](https://www.anaghsharma.com/blog/macos-menu-bar-app-with-swiftui)
- [Building a MacOS Menu Bar App with Swift - gaitatzis.medium.com](https://gaitatzis.medium.com/building-a-macos-menu-bar-app-with-swift-d6e293cd48eb)
- [Window Management in SwiftUI - swiftwithmajid.com](https://swiftwithmajid.com/2022/11/02/window-management-in-swiftui/)
- [Using an AppDelegate with the new SwiftUI-based app lifecycle - swiftbysundell.com](https://www.swiftbysundell.com/tips/using-an-app-delegate-with-swiftui-app-lifecycle/)
- [CloudKit Sync Library Lessons - ryanashcraft.com](https://ryanashcraft.com/what-i-learned-writing-my-own-cloudkit-sync-library/)

**Anti-Pattern Documentation:**
- [Toggl: When Time Tracking Goes Bad: 7 Cases And Fixes](https://toggl.com/blog/why-time-tracking-is-bad)
- [Memtime: Time Tracking Doesn't Work – 3 Ways to Fix It](https://www.memtime.com/blog/time-tracking-problems-and-how-to-fix-them)
- [MakeUseOf: 4 Reasons Time-Tracking Apps Actually Waste Your Time](https://www.makeuseof.com/why-time-tracking-apps-waste-your-time/)

### Tertiary (LOW confidence - needs validation)

**Specific Issues & Workarounds:**
- [MenuBarExtra Window Management Issue - GitHub Feedback Assistant](https://github.com/feedback-assistant/reports/issues/383)
- [SwiftUI View Leaks iOS 17 - Apple Developer Forums](https://developer.apple.com/forums/thread/737967)
- [iCloud Throttling - eclecticlight.co (Feb 2024)](https://eclecticlight.co/2024/02/22/icloud-does-throttle-data-syncing-after-all/)

---

*Research completed: 2026-01-26*
*Ready for roadmap: Yes*
*Next step: Requirements definition and roadmap creation*
