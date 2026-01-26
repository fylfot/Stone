# Roadmap: Stone v1.0

**Created:** 2026-01-26
**Phases:** 5
**Requirements:** 35 total

## Overview

Stone's roadmap follows a dependency-driven path from foundation to polish. Phase 1 establishes the app architecture and core time tracking with accurate timer behavior across sleep/wake cycles. Phase 2 builds project organization features (folders, tags, colors) on the stable foundation. Phase 3 adds reporting and visualization once time data exists. Phase 4 integrates CloudKit sync after the data model is proven stable. Phase 5 adds final polish and convenience features.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Foundation + Core Tracking** - App structure, timer, persistence
- [ ] **Phase 2: Project Organization** - Projects, folders, tags, colors
- [ ] **Phase 3: Reporting** - Time summaries, charts, export
- [ ] **Phase 4: CloudKit Sync** - iCloud sync, conflict resolution
- [ ] **Phase 5: Polish** - Launch at login, final refinements

## Phase Details

### Phase 1: Foundation + Core Tracking

**Goal**: User can track time for projects with accurate timer that persists across sleep/wake cycles and app restarts.

**Depends on**: Nothing (first phase)

**Requirements**: UI-01, UI-04, UI-06, TRACK-01, TRACK-02, TRACK-03, TRACK-04, TRACK-05, TRACK-06, TRACK-07, TRACK-08, TRACK-09, TRACK-10

**Success Criteria** (what must be TRUE):
  1. User can start a timer for a project from menu bar with one click
  2. User can see elapsed time updating in menu bar while timer runs
  3. User can stop timer and time entry is saved permanently
  4. Timer automatically pauses when Mac sleeps and resumes on wake without drift
  5. User can switch between projects and previous timer auto-stops
  6. User can manually add time entries for retroactive logging
  7. User can edit existing time entries
  8. User is prompted after idle periods with option to keep or discard idle time
  9. All time data persists across app restarts

**Plans**: TBD

Plans:
- [ ] TBD during phase planning

**Notes:**
- Critical pitfall: Use Date-based calculation, not tick counting, to prevent timer drift (Research PITFALLS.md #1)
- Must use NSWorkspace notifications for sleep/wake events (Research PITFALLS.md #1)
- Set LSUIElement in Info.plist to prevent Dock icon (Research PITFALLS.md #6)
- Use ProcessInfo beginActivity to prevent App Nap throttling (Research PITFALLS.md #3)
- Architecture: MenuBarExtra (.window style), @Observable managers, Core Data persistence
- Use AppDelegate for sleep/wake notifications, not pure SwiftUI

---

### Phase 2: Project Organization

**Goal**: User can organize projects into folders with tags and colors for easy visual identification and filtering.

**Depends on**: Phase 1

**Requirements**: UI-02, PROJ-01, PROJ-02, PROJ-03, PROJ-04, PROJ-05, PROJ-06, PROJ-07, PROJ-08, PROJ-09

**Success Criteria** (what must be TRUE):
  1. User can create new projects with names and colors
  2. User can edit project names inline
  3. User can delete projects with confirmation dialog
  4. User can organize projects into folders (hierarchical structure)
  5. User can create, edit, and delete folders
  6. User can add multiple tags to projects
  7. User can filter project list by tag
  8. User can reorder projects within folders via drag-and-drop
  9. User can open Preferences window to manage projects

**Plans**: TBD

Plans:
- [ ] TBD during phase planning

**Notes:**
- Use SwiftUI for Preferences window (Settings scene or Window with id)
- Core Data relationships for folder hierarchy
- Avoid multiple window instance issues (Research PITFALLS.md #15)

---

### Phase 3: Reporting

**Goal**: User can view time summaries, visualize time distribution, and export data for external use.

**Depends on**: Phase 2

**Requirements**: UI-03, REPORT-01, REPORT-02, REPORT-03, REPORT-04, REPORT-05, REPORT-06, REPORT-07

**Success Criteria** (what must be TRUE):
  1. User can view daily time summary showing hours per project
  2. User can view weekly and monthly time summaries
  3. User can see searchable list of all time entries
  4. User can view pie chart of time distribution by project
  5. User can view bar chart of time by day/week
  6. User can export time data to CSV format
  7. User can open Reports window from menu bar

**Plans**: TBD

Plans:
- [ ] TBD during phase planning

**Notes:**
- Use Swift Charts for native visualizations (macOS 13+)
- FileExporter for CSV export
- Research flag MEDIUM: May need to experiment with chart types for optimal UX
- Use @Query for efficient Core Data fetches in SwiftUI

---

### Phase 4: CloudKit Sync

**Goal**: User's data syncs automatically across all their Macs via iCloud with visible sync status.

**Depends on**: Phase 3

**Requirements**: SYNC-01, SYNC-02, SYNC-03

**Success Criteria** (what must be TRUE):
  1. Time entries and projects sync automatically to iCloud
  2. User can see sync status indicator showing sync progress/errors
  3. Changes on one Mac appear on other Macs within minutes
  4. Conflicts from concurrent edits are resolved automatically without data loss
  5. User sees warning before iCloud account changes that might affect data

**Plans**: TBD

Plans:
- [ ] TBD during phase planning

**Notes:**
- CRITICAL: Deploy CloudKit schema to production before release (Research PITFALLS.md #2)
- Use Core Data + CloudKit, NOT SwiftData (SwiftData lacks shared CloudKit support)
- All Core Data relationships must be optional for CloudKit (Research PITFALLS.md #5)
- Handle CloudKit rate limiting with exponential backoff (Research PITFALLS.md #8)
- Listen for CKAccountChanged notification (Research PITFALLS.md #10)
- Research flag HIGH: Phase-specific research needed for production deployment checklist

---

### Phase 5: Polish

**Goal**: App feels native and polished with convenience features like launch at login.

**Depends on**: Phase 4

**Requirements**: UI-05

**Success Criteria** (what must be TRUE):
  1. User can enable "Launch at Login" in preferences
  2. App automatically launches at login when enabled
  3. Menu bar icon renders correctly in both light and dark mode
  4. No memory leaks detected via Instruments profiling

**Plans**: TBD

Plans:
- [ ] TBD during phase planning

**Notes:**
- Use SMAppService for launch at login (macOS 13+)
- SF Symbols for menu bar icon with template rendering
- Run Instruments memory profiling before release
- Clean up any weak self issues in closures

---

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation + Core Tracking | 0/TBD | Not started | - |
| 2. Project Organization | 0/TBD | Not started | - |
| 3. Reporting | 0/TBD | Not started | - |
| 4. CloudKit Sync | 0/TBD | Not started | - |
| 5. Polish | 0/TBD | Not started | - |

---

*Roadmap created: 2026-01-26*
*Ready for phase planning: Phase 1*
