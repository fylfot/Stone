# Stone

## What This Is

A modern macOS menu bar time tracker for freelancers. Track time across projects with folders and tags, view detailed reports with charts, and sync data across devices via iCloud. Built with Swift, SwiftUI, and SwiftData.

## Core Value

Users can accurately track and understand where their time goes across projects with minimal friction.

## Current State (v1.0 shipped)

**Shipped:** 2026-01-26

**Tech stack:**
- Swift 5+, SwiftUI, SwiftData
- macOS 14+ (Sonoma)
- CloudKit for iCloud sync
- Swift Charts for reporting
- SMAppService for launch at login

**Codebase:**
- 26 Swift source files
- ~3,964 lines of code
- @Observable architecture with MVVM pattern

## Requirements

### Validated

<!-- Shipped and confirmed valuable. -->

**Core Tracking (v1.0):**
- ✓ TRACK-01: User can start timer from menu bar — v1.0
- ✓ TRACK-02: User can stop active timer from menu bar — v1.0
- ✓ TRACK-03: User can see elapsed time in menu bar — v1.0
- ✓ TRACK-04: User can switch between projects (auto-stops previous) — v1.0
- ✓ TRACK-05: User can add time entry manually — v1.0
- ✓ TRACK-06: User can edit existing time entries — v1.0
- ✓ TRACK-07: User is prompted on idle return — v1.0
- ✓ TRACK-08: Timer auto-stops on sleep/screen lock — v1.0
- ✓ TRACK-09: Timer auto-stops on power off — v1.0
- ✓ TRACK-10: Timer data persists across restarts — v1.0

**Project Organization (v1.0):**
- ✓ PROJ-01: User can create new project — v1.0
- ✓ PROJ-02: User can edit project name inline — v1.0
- ✓ PROJ-03: User can delete project with confirmation — v1.0
- ✓ PROJ-04: User can assign color to project — v1.0
- ✓ PROJ-05: User can organize projects into folders — v1.0
- ✓ PROJ-06: User can create/edit/delete folders — v1.0
- ✓ PROJ-07: User can add tags to projects — v1.0
- ✓ PROJ-08: User can filter projects by tag — v1.0
- ✓ PROJ-09: User can reorder projects — v1.0

**Reporting (v1.0):**
- ✓ REPORT-01: User can view daily time summary — v1.0
- ✓ REPORT-02: User can view weekly time summary — v1.0
- ✓ REPORT-03: User can view monthly time summary — v1.0
- ✓ REPORT-04: User can see searchable entry history — v1.0
- ✓ REPORT-05: User can view pie chart by project — v1.0
- ✓ REPORT-06: User can view bar chart by day/week — v1.0
- ✓ REPORT-07: User can export to CSV — v1.0

**Sync (v1.0):**
- ✓ SYNC-01: Data syncs via iCloud — v1.0
- ✓ SYNC-02: User can see sync status — v1.0
- ✓ SYNC-03: Conflicts resolved automatically — v1.0

**UI/UX (v1.0):**
- ✓ UI-01: App runs in menu bar — v1.0
- ✓ UI-02: User can open Preferences — v1.0
- ✓ UI-03: User can open Reports — v1.0
- ✓ UI-04: Dark mode support — v1.0
- ✓ UI-05: Launch at login option — v1.0
- ✓ UI-06: Configurable menu bar display — v1.0

### Active

<!-- Current scope for next milestone. -->

(None — planning next milestone)

### Out of Scope

<!-- Explicit boundaries. Includes reasoning to prevent re-adding. -->

- iOS/watchOS apps — macOS only for v1, can add later
- Real-time collaboration — Single user, sync is for own devices
- Pomodoro timer — Different use case, separate app
- Billing/invoicing — Focus is tracking, not business management
- Third-party integrations — Keep it simple, native-only
- Screenshot/activity monitoring — Privacy concern, manual tracking preferred

## Context

**v1.0 shipped** with complete feature set:
- Time tracking with persistent storage via SwiftData
- Project organization (folders, tags, colors)
- Comprehensive reporting with Swift Charts
- CloudKit sync with conflict resolution
- Launch at login via SMAppService

**Architecture decisions validated:**
- @Observable + SwiftData worked well for state management
- SwiftUI MenuBarExtra with .window style provides good UX
- CloudKit sync via SwiftData requires careful schema management

## Constraints

- **Platform**: macOS 14+ (Sonoma) — Latest SwiftUI features
- **Stack**: Swift, SwiftUI, SwiftData, CloudKit — Native Apple only
- **Architecture**: @Observable MVVM — Clean, testable code

## Key Decisions

<!-- Decisions that constrain future work. Updated throughout project lifecycle. -->

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| SwiftUI + SwiftData over AppKit | Modern, declarative, less code | ✓ Good - Clean implementation |
| CloudKit via SwiftData | Simpler sync, native solution | ✓ Good - Works with minimal code |
| macOS 14+ minimum | Latest SwiftUI features | ✓ Good - MenuBarExtra, @Observable |
| @Observable over ObservableObject | Simpler state management | ✓ Good - Less boilerplate |
| SMAppService for launch at login | Apple's recommended API | ✓ Good - Clean, reliable |

---
*Last updated: 2026-01-26 after v1.0 milestone*
