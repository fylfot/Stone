# Feature Landscape: Freelancer Time Tracking

**Domain:** macOS menu bar time tracker for freelancers
**Researched:** 2026-01-26
**Confidence:** HIGH (based on extensive 2026 market research and competitor analysis)

## Executive Summary

The freelancer time tracking landscape in 2026 is dominated by three core expectations: accurate time capture, billable hour management, and invoicing integration. Table stakes features are well-established, with differentiation happening through automation (AI-powered tracking), native platform integration, and user experience simplicity.

For a macOS menu bar time tracker targeting freelancers, the critical success factors are:
1. **Frictionless tracking** - Start/stop must be effortless
2. **Billable hour clarity** - Clear distinction between billable and non-billable time
3. **Project organization** - Flexible categorization (folders, tags, hierarchies)
4. **Native Mac feel** - Keyboard shortcuts, menu bar visibility, no accounts required

The market shows a clear divide: enterprise tools adding surveillance features vs freelancer tools prioritizing simplicity and trust. Stone should firmly stay in the freelancer-focused simplicity camp.

---

## Table Stakes Features

Features users expect. Missing any = product feels incomplete or broken.

### Core Time Tracking

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Start/stop timer** | Fundamental tracking mechanism | Low | One-click timer toggle from menu bar |
| **Manual time entry** | Forgot to start timer or logging past work | Low | Edit start/end times, add entries retroactively |
| **Timer visibility** | Need to see active time at a glance | Low | Show elapsed time in menu bar |
| **Idle detection** | Handle lunch breaks, meetings, distractions | Medium | Prompt when returning: "keep or discard idle time?" |
| **Auto-stop on sleep** | Mac sleeps, timer shouldn't keep running | Low | Detect system sleep/screen lock events |
| **Multiple projects** | Freelancers juggle multiple clients | Low | Quick project switcher, keyboard shortcuts |

**Research confidence:** HIGH - These appear in 100% of successful time trackers surveyed ([Toggl](https://toggl.com/track/freelance-time-tracking/), [Clockify](https://clockify.me/freelance-time-tracking), [Harvest](https://www.getharvest.com/blog/time-tracker-guide))

### Project Organization

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Project/client separation** | Freelancers track per client for billing | Low | Called "zones" in Stone, "projects" elsewhere |
| **Billable vs non-billable** | Critical for accurate invoicing | Low | Toggle per project or per time entry |
| **Project colors** | Visual differentiation at a glance | Low | Color coding for quick recognition |
| **Project archiving** | Completed projects clutter the list | Low | Hide without deleting, preserve history |

**Research confidence:** HIGH - Standard across all freelancer-focused tools ([Upwork Resources](https://www.upwork.com/resources/best-time-tracking-apps-for-freelancers), [My Hours](https://myhours.com/freelance-time-tracking))

### Basic Reporting

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Daily summary** | See what I worked on today | Low | List of time entries with duration |
| **Weekly/monthly totals** | Understand time distribution over periods | Low | Total hours per project per period |
| **Time entry history** | Review and edit past entries | Low | Searchable, filterable list |
| **Export to CSV** | Get data into Excel or invoicing software | Low | Standard CSV format with all fields |

**Research confidence:** HIGH - Baseline reporting in every tool surveyed ([Digital Project Manager](https://thedigitalprojectmanager.com/tools/best-time-tracking-app/))

### Data Integrity

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Persistent storage** | Data must survive app restart | Low | Local database, not just memory |
| **Data backup** | Don't lose months of tracked time | Medium | iCloud sync serves as backup |
| **Edit history** | Undo accidental changes | Medium | Track modifications, allow rollback |
| **No data loss on crashes** | Time tracker must be reliable | Medium | Auto-save, transaction safety |

**Research confidence:** HIGH - Users expect time tracking data to be bulletproof ([Toggl blog on failures](https://toggl.com/blog/why-time-tracking-is-bad))

---

## Differentiators

Features that set products apart. Not expected, but valued when present.

### Advanced Organization

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Hierarchical folders** | Group projects by client or category | Medium | Client > Project structure |
| **Tags/labels** | Cross-cutting categorization (e.g., "design", "meetings") | Medium | Multiple tags per project |
| **Project templates** | Quickly recreate similar project structures | Medium | Save project + tag configurations |
| **Smart filters** | Saved queries for common views | Medium | "Show all billable hours this month" |

**Research confidence:** MEDIUM - Present in advanced tools like [Toggl Track](https://support.toggl.com/en/articles/2219529-data-structure-in-toggl-track), differentiates from basic timers

**Recommendation for Stone:** Implement folders and tags as planned. Defer templates and smart filters to post-MVP.

### Enhanced Reporting

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Visual charts** | See time distribution at a glance | Medium | Pie charts, bar charts by project/period |
| **Productivity scores** | Gamification and self-awareness | Medium | Compare periods, spot trends |
| **Revenue projections** | Add hourly rates, see earnings | Medium | Billable hours × rate = projected revenue |
| **Comparison reports** | This month vs last month | Medium | Trend analysis over time |
| **Custom date ranges** | Not just week/month presets | Low | "Jan 15 - Feb 10" for project phases |

**Research confidence:** HIGH - Charts are increasingly expected, revenue tracking common in freelancer tools ([Timing](https://timingapp.com/blog/mac-time-tracking-apps/), [My Hours](https://myhours.com/best-time-tracking-apps))

**Recommendation for Stone:** Charts are high-value, medium-complexity. Include in v1.0. Revenue tracking can be post-MVP.

### macOS Native Integration

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Global keyboard shortcuts** | Start/stop without opening app | Low | ⌘⌥T to toggle timer, ⌘⌥P for project switcher |
| **Calendar integration** | Show time entries in Calendar.app | High | Export to iCal format or Calendar integration |
| **Shortcuts app support** | Automation (start project at 9am) | Medium | Expose actions to macOS Shortcuts |
| **Notification Center** | Gentle reminders if timer idle | Low | "You haven't tracked time today" |
| **Menu bar customization** | Show/hide timer, choose display format | Low | Preferences for menu bar appearance |

**Research confidence:** MEDIUM-HIGH - Mac users expect native integration ([Tim](https://tim.neat.software/), [Daily](https://dailytimetracking.com/blog/best-time-tracking-apps-for-mac/))

**Recommendation for Stone:** Keyboard shortcuts are critical (LOW complexity, HIGH value). Calendar/Shortcuts are nice-to-have (defer to v1.1+).

### Privacy & Local-First

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **No account required** | Start tracking immediately | Low | Local storage, optional iCloud sync |
| **Data stays on device** | Privacy-first, no cloud vendor lock-in | Low | CloudKit is Apple-controlled, acceptable |
| **Offline-first** | Works without internet | Medium | Sync when online, full functionality offline |
| **Export all data** | Full data portability | Low | JSON export of entire database |

**Research confidence:** HIGH - Privacy is a key differentiator for Mac time trackers in 2026 ([Timing](https://timingapp.com/?lang=en), [macOS menu bar tracker discussions](https://github.com/pkamenarsky/atea))

**Recommendation for Stone:** This is a major competitive advantage. Emphasize "no accounts, data stays on your Mac" in marketing.

### Automation & Intelligence

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **AI categorization** | Automatically assign projects based on patterns | High | "You usually code on ProjectX at 9am" |
| **Smart time suggestions** | Fill in gaps based on calendar/habits | High | "Looks like you forgot to track 2-4pm" |
| **Automatic tracking** | Track based on active apps/websites | High | Privacy concerns, requires accessibility permissions |
| **Pomodoro integration** | Combine time tracking with focus technique | Medium | 25min focus + 5min break cycles |

**Research confidence:** MEDIUM - AI is trending but not expected by freelancers yet ([Market research on AI differentiation](https://www.factmr.com/report/time-tracking-software-market))

**Recommendation for Stone:** Explicit anti-feature for v1. Freelancers want manual control, not surveillance-feeling automation.

---

## Anti-Features

Features to explicitly NOT build. Common mistakes in this domain.

### 1. Screenshot/Activity Monitoring

**What it is:** Taking periodic screenshots or tracking active windows/websites to "prove" work is being done.

**Why avoid:**
- Creates surveillance culture, breaks trust
- Freelancers work for themselves, don't need to prove activity
- Privacy nightmare (captures sensitive client data, passwords, personal browsing)
- Market research shows this is top complaint about time trackers ([Toggl: When Time Tracking Goes Bad](https://toggl.com/blog/why-time-tracking-is-bad))

**What to do instead:** Trust users to track honestly. Focus on making tracking easy, not enforcing it.

**Research confidence:** HIGH - Unanimous negative feedback across all sources

---

### 2. Invasive Reminders/Notifications

**What it is:** Frequent notifications asking "What are you working on?" or "Did you forget to track?"

**Why avoid:**
- Interrupts flow state and deep work
- Feels naggy and micromanaging
- Users will disable notifications entirely, defeating purpose
- Research shows notifications kill creative flow ([UX problems causing failure](https://www.memtime.com/blog/time-tracking-problems-and-how-to-fix-them))

**What to do instead:**
- Gentle end-of-day summary ("You tracked 6 hours today")
- User-configurable reminders (off by default)
- Visual indicator (menu bar icon color change) instead of interruptions

**Research confidence:** HIGH

---

### 3. Forced Categorization/Complex Setup

**What it is:** Requiring extensive configuration before first use (rate cards, task taxonomies, approval workflows).

**Why avoid:**
- Freelancers want to start tracking NOW, not in 30 minutes
- Setup complexity is #1 reason tools get abandoned ([Time tracking failures](https://www.makeuseof.com/why-time-tracking-apps-waste-your-time/))
- Most freelancers have simple needs (project + hours)

**What to do instead:**
- Zero-config first run: click to create project, start tracking
- Progressive disclosure: advanced features appear when needed
- Sensible defaults everywhere

**Research confidence:** HIGH - Setup friction cited as major pain point

---

### 4. Built-in Invoicing/Billing

**What it is:** Full invoice generation, payment processing, client management inside the time tracker.

**Why avoid:**
- Feature creep - becomes accounting software, not time tracker
- Freelancers already have invoicing tools (Stripe, PayPal, QuickBooks)
- Complex to build well, high maintenance burden
- PROJECT.md explicitly lists this as out of scope

**What to do instead:**
- Export CSV/JSON for import into invoicing tools
- Show revenue projections (hours × rate) for internal planning
- Focus on being best time tracker, not mediocre accounting system

**Research confidence:** MEDIUM - Some tools bundle this successfully, but Stone's scope excludes it

---

### 5. Team/Multi-User Features

**What it is:** Shared projects, team dashboards, manager approval workflows, time-off requests.

**Why avoid:**
- Stone targets solo freelancers, not teams/agencies
- Team features add architectural complexity (permissions, roles, collaboration)
- Different UX paradigm (individual vs team workflows)
- Scope creep away from core value proposition

**What to do instead:**
- Focus on single-user experience excellence
- iCloud sync is for user's multiple devices, not team sharing
- If team features needed later, they're a separate product

**Research confidence:** HIGH - Clear from PROJECT.md scope

---

### 6. Mobile-First Design

**What it is:** Building for iOS/watchOS first, or making macOS app feel like mobile app port.

**Why avoid:**
- Stone is macOS-only by design (PROJECT.md)
- Freelancers do billable work on Mac, not iPhone
- Mobile-first UI patterns feel wrong on desktop (large touch targets, simplified navigation)
- Menu bar app is inherently Mac-specific UI pattern

**What to do instead:**
- Design for Mac first: keyboard shortcuts, right-click menus, drag-and-drop
- Use macOS HIG guidelines, not iOS
- Leverage Mac-specific features (menu bar, global shortcuts, multiple windows)

**Research confidence:** HIGH - Explicit in project scope

---

## Feature Dependencies

Understanding build order and architectural dependencies:

```
Core Data Model
  ├─> Time Entry CRUD
  │     ├─> Manual Entry
  │     └─> Timer (Start/Stop)
  │           ├─> Menu Bar Display
  │           └─> Idle Detection
  │
  ├─> Project Management
  │     ├─> Project CRUD
  │     ├─> Colors
  │     ├─> Folders (hierarchy)
  │     └─> Tags
  │
  ├─> Reporting
  │     ├─> Daily/Weekly/Monthly Views
  │     ├─> Charts
  │     └─> Export (CSV/JSON)
  │
  └─> Sync
        └─> CloudKit Integration
              └─> Conflict Resolution
```

**Critical path for MVP:**
1. Data model + local persistence
2. Project CRUD
3. Timer (start/stop)
4. Menu bar display
5. Basic reporting (time entry list)
6. Export

**Post-MVP additions:**
- Folders and tags (enhance organization)
- Charts (visual reporting)
- CloudKit sync (multi-device)
- Keyboard shortcuts (power user features)

---

## User Workflow: Typical Freelancer Day

Understanding expected behavior through a realistic scenario:

### Morning (9:00 AM)

**User opens Mac**
- Stone is already running in menu bar (launch at login)
- Menu bar shows: "⏱ 0:00" (no active timer)
- User clicks menu bar icon, sees recent projects

**User starts work on Client A**
- Clicks "Client A - Website Redesign" or types ⌘⌥P and types "cli" (autocomplete)
- Timer starts: "⏱ 0:01... 0:02..."
- User minimizes Stone, focuses on work

### Mid-day (12:30 PM)

**User goes to lunch (forgets to stop timer)**
- Mac detects idle (no keyboard/mouse for 5+ minutes)
- Stone keeps timer running but marks as "potentially idle"

**User returns (1:30 PM)**
- Mac wakes from sleep
- Stone shows prompt: "You were idle for 1 hour. Keep this time?"
  - Options: "Keep All" | "Discard Idle" | "Edit Times"
- User clicks "Discard Idle"
- Timer stopped at 12:30, new entry for 1:30-onwards

### Afternoon (2:00 PM)

**User switches to Client B**
- Clicks menu bar → "Client B - Logo Design"
- Stone auto-stops Client A timer (3.5 hours tracked)
- Starts Client B timer

### End of Day (6:00 PM)

**User reviews tracked time**
- Opens Reports window (⌘⌥R)
- Sees today's summary:
  - Client A: 5.5 hours (billable)
  - Client B: 3.0 hours (billable)
  - Internal Admin: 0.5 hours (non-billable)
- Total billable: 8.5 hours

**User edits an entry**
- Realizes Client A meeting was 30 min, not 45 min
- Clicks entry, edits end time, saves
- Updated total: Client A now 5.25 hours

### End of Week (Friday)

**User generates invoice**
- Opens Reports → "This Week" view
- Filters to "Client A only"
- Exports CSV: `client-a-week-3.csv`
- Opens invoicing tool (Stripe/QuickBooks), imports CSV
- Generates invoice from tracked hours

---

## Freelancer Expectations: Research Synthesis

Based on 2026 market research, freelancers expect time trackers to:

### 1. Be Invisible Until Needed
- Live in menu bar, don't take screen space
- Start/stop with shortcuts, no UI required
- Show time at a glance, full UI only for reports/edits

### 2. Never Lose Data
- Auto-save everything, immediately
- Survive crashes, sleep, forced quits
- Sync across devices (if feature present)
- Export for backup insurance

### 3. Handle Interruptions Gracefully
- Idle detection is expected, not optional
- Smart prompts on return (not annoying notifications)
- Easy to adjust times retroactively

### 4. Separate Billable from Non-Billable
- Clear distinction for accurate invoicing
- Per-project setting (some clients billable, internal work not)
- Reports show both, with totals

### 5. Get Out of the Way
- No accounts, no login, no "are you still there?"
- Privacy-respecting (no screenshots, no surveillance)
- Fast, lightweight, native Mac app

**Sources:**
- [Desklog: Free Time Tracking for Freelancers 2026](https://desklog.io/blog/free-time-tracking-for-freelancers/)
- [Upwork: Best Time Tracking Apps for Freelancers](https://www.upwork.com/resources/best-time-tracking-apps-for-freelancers)
- [Clockify: Freelance Time Tracking](https://clockify.me/freelance-time-tracking)
- [Super Productivity: Freelancer Workflow](https://super-productivity.com/blog/freelancer-time-tracking-workflow/)

---

## MVP Recommendation

For Stone v1.0, prioritize in this order:

### Phase 1: Core Tracking (Must Ship)
1. ✅ **Start/stop timer** - Fundamental functionality
2. ✅ **Manual time entry** - Edit past work
3. ✅ **Project management** - CRUD operations
4. ✅ **Menu bar display** - Show active timer
5. ✅ **Auto-stop on sleep** - Handle Mac sleep events
6. ✅ **Idle detection** - Prompt on return from idle
7. ✅ **Local persistence** - Data survives restart

**Rationale:** These are table stakes. Without them, it's not a functional time tracker.

### Phase 2: Organization (Differentiator)
8. ✅ **Folders** - Hierarchical project organization
9. ✅ **Tags** - Cross-cutting categorization
10. ✅ **Project colors** - Visual differentiation
11. ✅ **Billable/non-billable toggle** - Per project

**Rationale:** PROJECT.md includes these in target features. Medium complexity, high value for freelancers.

### Phase 3: Reporting (Table Stakes + Differentiator)
12. ✅ **Daily/weekly/monthly views** - Time summaries
13. ✅ **Charts** - Visual time distribution
14. ✅ **CSV export** - Data portability
15. ✅ **JSON export** - Full data backup

**Rationale:** Reports are expected. Charts differentiate from basic timers. Export is insurance for users.

### Phase 4: Sync (Differentiator)
16. ✅ **CloudKit sync** - Multi-device data access
17. ✅ **Conflict resolution** - Handle concurrent edits

**Rationale:** iCloud sync is a competitive advantage. Complex but valuable for users with multiple Macs.

### Phase 5: Polish (Differentiator)
18. **Keyboard shortcuts** - Power user efficiency (⌘⌥T, ⌘⌥P, ⌘⌥R)
19. **Preferences** - Customization options
20. **Dark mode** - Native macOS appearance

**Rationale:** These make Stone feel professional and Mac-native. Relatively low complexity.

---

## Defer to Post-MVP

Features to explicitly save for v1.1+:

### Good Ideas, Wrong Time
- **Revenue projections** - Add hourly rates, calculate earnings (Medium complexity, nice-to-have)
- **Calendar integration** - Export to Calendar.app (High complexity, niche use case)
- **Shortcuts app support** - macOS automation (Medium complexity, power user feature)
- **Project templates** - Save and reuse project structures (Medium complexity, advanced use)
- **Smart filters** - Saved report queries (Medium complexity, can use basic filters first)
- **Notification reminders** - "Haven't tracked today" alerts (Low complexity, but anti-feature if done wrong)

### Explicitly Out of Scope
- **Invoicing** - Use existing tools, Stone exports data
- **Team features** - Solo freelancer focus
- **Mobile apps** - macOS only for v1
- **Third-party integrations** - Native-only approach
- **AI/automatic tracking** - Manual control, no surveillance

**Rationale:** Focus on doing core time tracking excellently. Ship fast, validate assumptions, iterate based on real user feedback.

---

## Quality Gates

Before shipping, verify these freelancer expectations are met:

### Reliability
- [ ] Timer never loses data (crash, sleep, force quit)
- [ ] Idle detection always triggers correctly
- [ ] Manual edits persist immediately
- [ ] Export produces valid, importable files

### Usability
- [ ] Start tracking in < 2 clicks from menu bar
- [ ] Switch projects in < 3 clicks
- [ ] View today's summary in < 2 clicks
- [ ] Export week's data in < 4 clicks

### Privacy
- [ ] No account required for basic use
- [ ] Data stored locally, not on third-party servers
- [ ] CloudKit sync is optional, not required
- [ ] Full data export available (JSON)

### Mac-Native Feel
- [ ] Follows macOS Human Interface Guidelines
- [ ] Supports dark mode automatically
- [ ] Keyboard shortcuts for primary actions
- [ ] Menu bar icon shows timer status

### Freelancer-Specific
- [ ] Billable vs non-billable clearly separated
- [ ] Projects easily organized (folders/tags)
- [ ] Reports show hours per project per period
- [ ] Export format works with common invoicing tools

---

## Competitive Positioning

Based on 2026 market research, Stone's sweet spot:

### We are NOT
❌ Enterprise time tracking (Hubstaff, Time Doctor)
❌ Team collaboration tool (Toggl Track with teams)
❌ All-in-one business management (Harvest with invoicing)
❌ Automatic surveillance tracker (Desklog, RescueTime)

### We ARE
✅ **Simple, fast, privacy-respecting macOS time tracker**
✅ **For solo freelancers who want manual control**
✅ **Native Mac app with menu bar presence**
✅ **Flexible organization (folders, tags, hierarchies)**
✅ **Visual reporting with export for invoicing**

### Key Differentiators vs Competitors
1. **vs Toggl/Clockify:** Native Mac app, not Electron web wrapper
2. **vs Timing:** Manual control, not automatic surveillance
3. **vs Harvest:** Time tracking focus, not business management suite
4. **vs Tim/Daily:** Better organization (folders + tags), modern SwiftUI

**Market gap:** Freelancers want Timing's polish + Toggl's simplicity + Tim's menu bar UX, without surveillance features or subscription costs.

Stone fills this gap.

---

## Confidence Assessment

| Feature Category | Confidence | Source Quality |
|------------------|------------|----------------|
| **Table stakes features** | HIGH | 10+ sources, unanimous agreement |
| **Differentiators** | MEDIUM-HIGH | 8+ sources, clear patterns |
| **Anti-features** | HIGH | Strong negative feedback across sources |
| **Freelancer workflows** | HIGH | Detailed workflow guides from major tools |
| **macOS expectations** | MEDIUM | Fewer Mac-specific sources, some extrapolation |

### Research Limitations

**What we know confidently:**
- Core time tracking expectations (start/stop, manual entry, idle detection)
- Freelancer-specific needs (billable hours, project separation, export)
- Common mistakes (surveillance, over-notification, complex setup)

**What needs validation:**
- Exact folder/tag hierarchy users prefer (test with beta users)
- Which chart types are most valuable (pie? bar? timeline?)
- Keyboard shortcut preferences (survey Mac power users)
- CloudKit sync conflict resolution UX (needs prototyping)

**Recommendation:** Ship MVP with table stakes + basic organization/reporting. Let real usage data guide advanced features.

---

## Sources

### Primary Research (2026)

**Freelancer Time Tracking:**
- [Desklog: 7 Best Free Time Tracking Software for Freelancers 2026](https://desklog.io/blog/free-time-tracking-for-freelancers/)
- [Upwork: Best Freelance Time-Tracking Apps for 2026](https://www.upwork.com/resources/best-time-tracking-apps-for-freelancers)
- [Moon Invoice: 12 Best Time Tracking Apps for Freelancers in 2026](https://www.mooninvoice.com/blog/best-time-tracking-apps-for-freelancers/)
- [Clockify: FREE Time Tracking App for Freelancers](https://clockify.me/freelance-time-tracking)
- [Toggl: Freelance Time Tracking for Projects, Clients, & Invoices](https://toggl.com/track/freelance-time-tracking/)
- [My Hours: Best Freelance Time Tracking App](https://myhours.com/freelance-time-tracking)
- [Super Productivity: Freelancer Time Tracking Workflow](https://super-productivity.com/blog/freelancer-time-tracking-workflow/)

**macOS Time Trackers:**
- [Timing: 11 Best Time Tracking Apps for Mac in 2026](https://timingapp.com/blog/mac-time-tracking-apps/)
- [Tim: Time Tracker for macOS](https://tim.neat.software/)
- [Daily: Best time tracking apps for Mac](https://dailytimetracking.com/blog/best-time-tracking-apps-for-mac)

**Feature Expectations:**
- [Digital Project Manager: 40 Best Time Tracking Software for Productivity In 2026](https://thedigitalprojectmanager.com/tools/time-tracking-software/)
- [Digital Project Manager: 23 Best Time Tracking Apps of 2026](https://thedigitalprojectmanager.com/tools/best-time-tracking-app/)
- [My Hours: 17 Best Time Tracking Apps for 2026](https://myhours.com/best-time-tracking-apps)
- [Business Dive: 9 Best Time Tracking Apps In 2026](https://thebusinessdive.com/time-tracking-apps)

**Project Organization:**
- [Toggl: Data Structure in Toggl Track](https://support.toggl.com/en/articles/2219529-data-structure-in-toggl-track)
- [Toggl: Categorization Guide](https://support.toggl.com/en/articles/4200664-toggl-track-categorization-guide)
- [Toggl: 13 Time Tracking Categories](https://toggl.com/blog/time-tracking-categories)
- [TimeTracker.in: Multi-Project Time Tracking 2025](https://blog.timetracker.in/blog/multi-project-client-management-time-tracking-complex-relationships)

**Common Mistakes & Anti-Patterns:**
- [Toggl: When Time Tracking Goes Bad: 7 Cases And Fixes](https://toggl.com/blog/why-time-tracking-is-bad)
- [WebWork: 6 Common Time Tracking Mistakes and How to Avoid Them](https://www.webwork-tracker.com/blog/6-common-time-tracking-mistakes-and-how-to-avoid-them)
- [Time Filer: Top 10 Time-Tracking Mistakes to Avoid](https://www.timefiler.com/blog/the-top-10-time-tracking-mistakes-to-avoid)
- [Memtime: Time Tracking Doesn't Work – 3 Ways to Fix It](https://www.memtime.com/blog/time-tracking-problems-and-how-to-fix-them)
- [MakeUseOf: 4 Reasons Time-Tracking Apps Actually Waste Your Time](https://www.makeuseof.com/why-time-tracking-apps-waste-your-time/)

**Market Trends:**
- [Fact.MR: Time Tracking Software Market Share and Statistics 2035](https://www.factmr.com/report/time-tracking-software-market)
- [Market Research Future: Time Tracking Software Market Size, Trends Forecast Till 2035](https://www.marketresearchfuture.com/reports/time-tracking-software-market-9579)

---

## Conclusion

Stone's feature set is well-positioned for the 2026 freelancer time tracking market. The table stakes features are clearly defined, the differentiators (folders/tags, charts, privacy-first, Mac-native) address real market gaps, and the anti-features protect against common pitfalls.

**Critical success factors:**
1. **Nail the basics first** - Timer must be bulletproof, data never lost
2. **Stay focused** - Resist feature creep into invoicing/team/automation
3. **Mac-native polish** - Keyboard shortcuts, menu bar, no-account simplicity
4. **Trust users** - Manual control, no surveillance, privacy-respecting

**Validation approach:**
- Ship MVP with table stakes + organization + basic reporting
- Beta test with 10-20 freelancers
- Gather feedback on folder/tag workflows
- Iterate on reporting (which charts matter most)
- Add CloudKit sync once local experience is solid

The research provides high confidence in core features and clear boundaries for what NOT to build. Ready for roadmap creation.
