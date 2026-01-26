# Requirements: Stone

**Defined:** 2026-01-26
**Core Value:** Users can accurately track and understand where their time goes across projects with minimal friction.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Core Tracking

- [ ] **TRACK-01**: User can start timer from menu bar with one click
- [ ] **TRACK-02**: User can stop active timer from menu bar
- [ ] **TRACK-03**: User can see elapsed time in menu bar while tracking
- [ ] **TRACK-04**: User can switch between projects (auto-stops previous timer)
- [ ] **TRACK-05**: User can add time entry manually (retroactive logging)
- [ ] **TRACK-06**: User can edit existing time entries (start/end times)
- [ ] **TRACK-07**: User is prompted when returning from idle with options to keep/discard idle time
- [ ] **TRACK-08**: Timer auto-stops when Mac sleeps or screen locks
- [ ] **TRACK-09**: Timer auto-stops when Mac powers off
- [ ] **TRACK-10**: Timer data persists across app restarts

### Project Organization

- [ ] **PROJ-01**: User can create new project (zone)
- [ ] **PROJ-02**: User can edit project name inline
- [ ] **PROJ-03**: User can delete project (with confirmation)
- [ ] **PROJ-04**: User can assign color to project
- [ ] **PROJ-05**: User can organize projects into folders (hierarchy)
- [ ] **PROJ-06**: User can create/edit/delete folders
- [ ] **PROJ-07**: User can add tags to projects
- [ ] **PROJ-08**: User can filter projects by tag
- [ ] **PROJ-09**: User can reorder projects within folder

### Reporting

- [ ] **REPORT-01**: User can view daily time summary (hours per project)
- [ ] **REPORT-02**: User can view weekly time summary
- [ ] **REPORT-03**: User can view monthly time summary
- [ ] **REPORT-04**: User can see time entry history (searchable list)
- [ ] **REPORT-05**: User can view pie chart of time distribution by project
- [ ] **REPORT-06**: User can view bar chart of time by day/week
- [ ] **REPORT-07**: User can export time data to CSV

### Sync

- [ ] **SYNC-01**: User's data syncs automatically via iCloud
- [ ] **SYNC-02**: User can see sync status indicator
- [ ] **SYNC-03**: Conflicts from concurrent edits are resolved automatically

### UI/UX

- [ ] **UI-01**: App runs in menu bar (not Dock)
- [ ] **UI-02**: User can open Preferences window
- [ ] **UI-03**: User can open Reports window
- [ ] **UI-04**: App follows system dark/light mode
- [ ] **UI-05**: App launches at login (optional setting)
- [ ] **UI-06**: User can configure menu bar display format

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Enhanced Tracking

- **TRACK-11**: User can set hourly rate per project (revenue projection)
- **TRACK-12**: User can mark projects as billable/non-billable
- **TRACK-13**: User can archive completed projects

### Advanced Reporting

- **REPORT-08**: User can export to JSON (full data backup)
- **REPORT-09**: User can view revenue projections (hours x rate)
- **REPORT-10**: User can set custom date ranges for reports
- **REPORT-11**: User can compare periods (this month vs last)

### macOS Integration

- **UI-07**: User can use keyboard shortcuts (global hotkeys)
- **UI-08**: User can trigger actions via macOS Shortcuts app
- **UI-09**: User receives gentle end-of-day summary notification

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Screenshot/activity monitoring | Surveillance anti-pattern, breaks trust |
| Built-in invoicing | Use existing tools, export CSV instead |
| Team/multi-user features | Solo freelancer focus |
| iOS/watchOS apps | macOS only for v1 |
| Automatic time tracking | Manual control preferred, no surveillance |
| Third-party integrations | Native-only approach |
| Pomodoro timer | Different use case, separate app |
| Calendar integration | High complexity, defer to v2+ |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| TRACK-01 | TBD | Pending |
| TRACK-02 | TBD | Pending |
| TRACK-03 | TBD | Pending |
| TRACK-04 | TBD | Pending |
| TRACK-05 | TBD | Pending |
| TRACK-06 | TBD | Pending |
| TRACK-07 | TBD | Pending |
| TRACK-08 | TBD | Pending |
| TRACK-09 | TBD | Pending |
| TRACK-10 | TBD | Pending |
| PROJ-01 | TBD | Pending |
| PROJ-02 | TBD | Pending |
| PROJ-03 | TBD | Pending |
| PROJ-04 | TBD | Pending |
| PROJ-05 | TBD | Pending |
| PROJ-06 | TBD | Pending |
| PROJ-07 | TBD | Pending |
| PROJ-08 | TBD | Pending |
| PROJ-09 | TBD | Pending |
| REPORT-01 | TBD | Pending |
| REPORT-02 | TBD | Pending |
| REPORT-03 | TBD | Pending |
| REPORT-04 | TBD | Pending |
| REPORT-05 | TBD | Pending |
| REPORT-06 | TBD | Pending |
| REPORT-07 | TBD | Pending |
| SYNC-01 | TBD | Pending |
| SYNC-02 | TBD | Pending |
| SYNC-03 | TBD | Pending |
| UI-01 | TBD | Pending |
| UI-02 | TBD | Pending |
| UI-03 | TBD | Pending |
| UI-04 | TBD | Pending |
| UI-05 | TBD | Pending |
| UI-06 | TBD | Pending |

**Coverage:**
- v1 requirements: 35 total
- Mapped to phases: 0
- Unmapped: 35

---
*Requirements defined: 2026-01-26*
*Last updated: 2026-01-26 after initial definition*
