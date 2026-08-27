# Expense Tracker — MVP Plan

## 1. Overview

A simple, offline-first personal expense tracker for Android, built in Flutter with a local SQLite database. No accounts, no cloud sync, no ads — just fast entry and clear visibility into where money goes.

**Core promise:** Log a transaction in under 5 seconds, see your balance instantly, understand your spending at a glance.

---

## 2. Tech Stack

| Layer | Choice | Why |
|---|---|---|
| Framework | Flutter | Single codebase, good Android performance |
| Database | SQLite (`sqflite`) | Offline-first, no backend needed |
| State management | `Provider` or `Riverpod` (pick one, keep it simple) | Avoid overengineering for v1 |
| Charts | `fl_chart` | Lightweight, good pie/bar support for Analytics |

---

## 3. Screens & Features

### 3.1 Dashboard (Home)
- Balance shown at top (large, clear)
- **Weekly summary** below balance — "This week: +₹X / −₹Y" — calculated live from DB (current calendar week), no separate screen needed
- Search/filter bar above the list — filter visible transactions by category
- Scrollable transaction list, most recent first
  - Green for income, red for expense
  - Shows category icon, remark (if any), amount, date
  - **Swipe left → Edit** (opens modal pre-filled with existing values)
  - **Swipe right → Delete** (see Edit/Delete section for confirm + undo flow)
- Floating **+** and **−** buttons, **middle-right** of screen (portrait) — sits in the thumb's natural reach zone, pinned there regardless of scroll position
  - **+** → Income modal
  - **−** → Expense modal
  - Both give a short haptic tap on press, confirming the action registered without needing to look at the screen
- **Undo control**: appears just below the +/− buttons (small floating pill/snackbar-style) for a few seconds after a delete, tap to restore — see 3.4 for details
- Optional (v1.5): date filter chips — Today / This Week / This Month / All (works alongside category filter)

### 3.2 Income Modal
- Amount (required)
- Remark (optional, free text)
- Save → inserts into DB, closes modal, list refreshes

### 3.3 Expense Modal
Two tabs:
- **Direct** — amount, category (dropdown/chips), optional remark
- **Change Calculator** — enter cash given + cash received back → auto-computes actual amount spent, then same category + remark fields
  - Keep this tab scoped to just that one calculation — don't let it grow into a general calculator

Categories (fixed for v1, defined as an **enum**): `food`, `commute`, `bills`, `shopping`, `others`
- `others` is the default fallback category — used whenever nothing more specific fits
- Using an enum (not free text or a DB-driven list) keeps categories type-safe in code and prevents typo'd/duplicate categories from ever landing in the DB

### 3.4 Edit / Delete
- **Edit**: swipe left on a transaction → opens the same modal pre-filled (income or expense, matching type). Tap-to-open still works too, as a fallback for anyone who doesn't swipe.
- **Delete**: swipe right on a transaction → removes it immediately from the list (no confirm dialog — keeps it fast) and shows the **Undo control** near the +/− buttons for a few seconds
  - Tap Undo → transaction restored, no data actually lost yet
  - If the timer runs out without Undo, the delete is committed to the DB
  - This "soft delete + undo" pattern is safer than a confirm dialog for routine transactions, since it doesn't interrupt the flow — the strict double-confirm stays reserved for the full data wipe in Settings

### 3.5 Analytics
- Separate tab
- Pie chart: spending breakdown by category (expenses only)
  - Each category gets a distinct color; **"Others" uses a neutral/grey tone** — since it's a catch-all, giving it a muted color (rather than a vivid one competing with the real categories) keeps the chart visually honest about what's actually being tracked specifically vs. lumped together
- Simple list below: category name, total spent, % of total
- Time range: start with **all-time**; add month filter later if needed
- Don't build multi-chart dashboards for v1 — one pie chart + a total is enough

### 3.6 Settings
- New tab or accessible via drawer/icon
- **Clear all data**
  - Tap → Confirmation dialog 1: "This will permanently delete all transactions. Continue?"
  - Confirm → Confirmation dialog 2: "Are you absolutely sure? This cannot be undone." (second tap, or require typing "DELETE")
  - Confirm → wipes all rows from SQLite tables, resets balance to 0
- **Export data (CSV)**
  - Button → exports all transactions to a `.csv` file (date, type, category, amount, remark)
  - Save to device storage / share sheet (so it can go to Drive, email, etc.)
  - No filtering needed for v1 — export everything; date-range export can come later
- **Reminders (notifications)**
  - Off by default — user has to explicitly turn this on
  - Works like an alarm: user picks a specific time (e.g. 9:00 PM daily) to get a "log your expenses" notification
  - Not a generic "remind me every X hours" toggle — a real time picker, same mental model as setting an alarm clock
  - Needs local notification scheduling (`flutter_local_notifications` + exact alarm permission handling on Android 12+)
- Optional, nice-to-have (not blocking v1):
  - Currency symbol selector
  - Default category for expenses
  - Light/dark theme toggle

---

## 4. Visual Design & Theme

Beyond a plain light/dark toggle, give the app a bit of personality:

- **Theme options (Settings):** offer a couple of named color themes, not just light/dark — e.g. **"Mint"** (calm green/teal, good default), **"Sunset"** (warm orange/coral), **"Ocean"** (blue-based). Each theme should still respect light/dark mode underneath it (so 6 total combos, but the user only picks 2 settings: theme + mode).
- **Emoji as category icons** — instead of (or alongside) generic icons, use emoji per category. They're instantly recognizable, need no icon asset/library, and add warmth:
  - 🍔 Food
  - 🚌 Commute
  - 📄 Bills
  - 🛍️ Shopping
  - 📦 Others
  - Emoji shows in the transaction list next to each row, in the Expense modal category picker, and in the Analytics pie chart legend
- **Emoji in feedback moments** — small, optional touches that reinforce actions without extra UI:
  - Income saved → brief ✅ or 🎉 flash near the + button
  - Expense saved → brief 💸 flash near the − button
  - Empty state (no transactions yet) → a friendly emoji + short text instead of a blank screen (e.g. "📭 No transactions yet — tap + or − to add one")
- **Keep it tasteful, not gimmicky:** emojis should replace/support icons, not clutter every line of text. One emoji per category/action is enough — avoid emoji soup in remarks or headers.
- **Balance color:** keep red/green for expense/income as-is (that's a strong, universal convention) — the theme color should apply to buttons, backgrounds, and accents, not override the transaction red/green.

---

## 5. Data Model (conceptual, no code yet)

**Transaction**
- id
- type (income / expense)
- amount
- category (**enum**: food, commute, bills, shopping, others — null/unused for income rows)
- remark (nullable)
- date/time created

Single table is enough for v1 — no need to split income/expense into separate tables.

---

## 6. Build Order (Phases)

| Phase | Deliverable |
|---|---|
| 1 | Project setup + SQLite DB layer (schema, CRUD functions) |
| 2 | Dashboard screen (balance + list, static/mock data first) |
| 3 | Income & Expense modals (wire up to DB) |
| 4 | Edit / Delete flow |
| 5 | Analytics screen |
| 6 | Settings (clear data w/ double confirm, optional prefs) |
| 7 | CSV export + reminder notifications |

Each phase should be functionally testable on its own before moving to the next — e.g. Phase 1 ends with you able to manually insert/query rows and see them printed, before any UI depends on it.

---

## 7. Suggestions / Things to Watch

- **Don't add custom categories in v1.** Fixed list keeps the DB and UI simple. Add category management as a clear v2 feature if you actually miss it.
- **Date filtering on Dashboard** will matter fast — even a week of daily use makes the list long. Cheap to add, big usability win. Fine to slot in as v1.5 rather than blocking launch.
- **Change Calculator tab**: resist scope creep. It should do exactly one thing (compute spent amount from cash given/received) and hand off to the same fields as Direct entry.
- **Analytics v1 = one chart + one list.** Trend lines, multi-month comparisons, exportable reports — all good ideas, all v2+.
- **Clear data is destructive and irreversible** — the double confirmation is the right call. Consider also disabling the second confirm button for ~1 second after it appears, so a fast double-tap can't accidentally confirm both dialogs in a row.
- **Backups**: not in scope for MVP, but worth noting — since this is local-only SQLite, uninstalling the app loses all data. Could flag this to the user once in Settings ("Your data is stored only on this device") so it's not a surprise later. CSV export actually doubles as a manual backup, which is a nice side benefit.
- **Exact alarm permission on Android 12+**: Android restricts apps from scheduling exact-time alarms without a special permission (`SCHEDULE_EXACT_ALARM`). Since you want alarm-clock-style precision for reminders, budget time for this — it's a bit more setup than a basic notification.
- **CSV export scope**: keep the file format dead simple (one row per transaction, flat columns) so it opens cleanly in Excel/Sheets without cleanup.
- **Named themes**: start with just 2–3 (Mint, Sunset, Ocean) rather than a full custom color picker — a picker sounds nice but adds real UI/state complexity for a v1. Can expand the theme list later without any architecture change if colors are defined as a simple map from the start.

---

## 8. Explicitly Out of Scope for MVP
- Cloud sync / accounts / login
- Multiple wallets or accounts
- Recurring transactions
- Budgets / spending limits
- Custom categories
- PDF export (CSV only for v1)
- Full custom color picker (fixed named themes only for v1)

These are all reasonable v2 ideas — just not needed to have a usable, shippable app.
