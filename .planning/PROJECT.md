# Stone

## What This Is

A modern macOS menu bar time tracker for freelancers. Track time across projects, organize work with folders and tags, view detailed reports, and sync data via iCloud. Built with Swift and SwiftUI, replacing the legacy Objective-C app.

## Core Value

Users can accurately track and understand where their time goes across projects with minimal friction.

## Current Milestone: v1.0 Complete Rewrite

**Goal:** Full replacement of legacy Objective-C app with modern Swift/SwiftUI implementation plus new organizational and reporting features.

**Target features:**
- Time tracking with start/stop per project
- Project organization (folders, tags, hierarchies)
- Better reporting (charts, summaries, export)
- iCloud sync via CloudKit

## Requirements

### Validated

<!-- Shipped and confirmed valuable. -->

(None yet — ship to validate)

### Active

<!-- Current scope. Building toward these. -->

**Core Tracking:**
- [ ] Menu bar presence with timer display
- [ ] Start/stop time tracking per zone/project
- [ ] Auto-stop on sleep/power off/screen sleep
- [ ] Persistent data storage

**Project Organization:**
- [ ] Create/edit/delete zones (projects)
- [ ] Assign colors to zones
- [ ] Organize zones into folders
- [ ] Tag zones for filtering
- [ ] Rename zones inline

**Reporting:**
- [ ] View tracked periods by day
- [ ] View time summaries per zone
- [ ] Charts showing time distribution
- [ ] Export data (CSV, JSON)

**Sync:**
- [ ] iCloud sync via CloudKit
- [ ] Conflict resolution for concurrent edits

**UI/UX:**
- [ ] Modern SwiftUI interface
- [ ] Preferences window
- [ ] Reports window
- [ ] Dark mode support
- [ ] Native macOS appearance

### Out of Scope

<!-- Explicit boundaries. Includes reasoning to prevent re-adding. -->

- iOS/watchOS apps — macOS only for v1, can add later
- Real-time collaboration — Single user, sync is for own devices
- Pomodoro timer — Different use case, separate app
- Billing/invoicing — Focus is tracking, not business management
- Third-party integrations — Keep it simple, native-only

## Context

**Existing codebase:** Legacy Objective-C app from 2012 with:
- AppDelegate-based architecture
- NSKeyedArchiver for persistence
- Custom NSView subclasses for UI
- No tests, no modern patterns

**Rewrite approach:** Clean slate using modern Apple stack:
- Swift 5+
- SwiftUI for UI
- SwiftData or CloudKit for persistence
- MVVM or similar architecture
- Menu bar app pattern (NSStatusItem + SwiftUI)

## Constraints

- **Platform**: macOS 14+ (Sonoma) — Leverage latest SwiftUI features
- **Stack**: Swift, SwiftUI, CloudKit — Native Apple technologies only
- **Architecture**: Clean separation of concerns — Testable, maintainable code
- **Compatibility**: Data migration from legacy app — Don't lose existing time data

## Key Decisions

<!-- Decisions that constrain future work. Add throughout project lifecycle. -->

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| SwiftUI over AppKit | Modern, declarative, less code | — Pending |
| CloudKit over Core Data + iCloud | Simpler sync, native Apple solution | — Pending |
| macOS 14+ minimum | Latest SwiftUI features, reduce compatibility burden | — Pending |

---
*Last updated: 2026-01-26 after project initialization*
