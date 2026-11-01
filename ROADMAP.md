# Wallet Tracker — Feature Roadmap

> Offline-first Flutter expense & savings tracker  
> Last updated: 2026-11-01 (supersedes the 2026-09-26 version)

---

## 0. Instructions for the implementing agent

Read this whole file before writing code.

1. **Inspect the existing code first.** Before each phase, read the relevant files in `lib/` (`db/`, `models/`, `providers/`, `screens/`, `widgets/`, `main.dart`). This roadmap describes intent; where it conflicts with how the code actually works (column names, enum values, provider names), adapt to the code and note the deviation in your PR/commit message.
2. **Work phase by phase, in order.** Phase 0A (build fix) and then Phase 0B (performance) come before any new feature. Each phase must leave the app building, passing `flutter analyze`, and runnable.
3. **Do not redesign what already exists.** Reuse the current themes, wallet cards, badges, typography, and Provider architecture. Do not add new fonts, palettes, or UI libraries.
4. **Every user-facing string goes through l10n.** The app ships 7 languages (en, ja, zh, fr, es, de, pt). Add every new string to all ARB files and run `flutter gen-l10n`. English may be used as a placeholder in non-English files only if flagged in the PR description.
5. **Tick the checkboxes in this file** as items are completed, and add a short note under any item you deviate from.
6. **Ask before guessing** on anything marked **DECISION NEEDED**. Everything else in this file is already decided.

---

## 1. Confirmed Scope

### Debt / IOU System
- Track **Lent** (you gave money) and **Borrowed** (someone gave you money)
- Optional **simple flat percentage interest** (toggle, **off by default**, live total calculation)
- Partial repayments
- Auto-archive when fully paid
- Contact list (frequent people for quick select)
- Quick "IOU" button on Dashboard
- Local notifications for due dates
- Debts appear in the Wallets screen as predefined system wallets (see 3.2)

### Other Features
- Recurring transactions (rent, salary, subscriptions)
- Monthly budget limits per category with progress bars
- Auto-open Help & User Guide on first launch

### UI Decision
- New bottom navigation tab for Debts

```
Dashboard | Wallets | Debts | Analytics | Settings
```

---

## 1.5 Phase 0A — Build blocker: `fl_chart` fails to compile on Windows (fix before anything else)

**Symptom** (`flutter run`, Gradle `assembleDebug`, `Target kernel_snapshot_program failed`):

```
/C:/Users/Bonsi's%20Friend/AppData/Local/Pub/Cache/hosted/pub.dev/fl_chart-0.67.0/lib/...:
Error: The method 'Paint' isn't defined for the type 'RadarChartPainter'.
Error: 'BuildContext' isn't a type.
Error: 'Offset' isn't a type.   (hundreds more: Size, Rect, Axis, TextPainter, Widget...)
```

**Most likely cause:** this is an environment problem, not a bug in the app code or in `fl_chart`. Core Flutter types (`Paint`, `Offset`, `BuildContext`, ...) are reported as undefined across the whole package, which means the compiler could not resolve the package's `dart:ui` / `package:flutter` imports. The default pub cache lives under the Windows user profile, `C:\Users\Bonsi's Friend\AppData\Local\Pub\Cache`, and that path contains **an apostrophe and a space**. Both break URI handling in the Dart/Flutter build tooling (the path appears as `Bonsi's%20Friend` in the errors). Any hosted package that imports Flutter can be hit, `fl_chart` is just the first to fail.

**Fix (machine configuration, nothing to change in app code):**

1. Create a cache folder with a plain path (letters only, no spaces, no apostrophes), for example `C:\pub_cache`.
2. Point pub at it with a user environment variable. In PowerShell:
   ```powershell
   mkdir C:\pub_cache
   setx PUB_CACHE "C:\pub_cache"
   ```
3. **Close and reopen** every terminal and IDE (VS Code / Android Studio) so the variable is picked up, then stop leftover build daemons:
   ```powershell
   cd E:\Documents\projects\flutter\Wallet-Tracker\android
   .\gradlew --stop
   cd ..
   ```
4. Rebuild from clean:
   ```powershell
   flutter clean
   flutter pub get
   flutter run
   ```
5. Confirm `.dart_tool/package_config.json` now lists `fl_chart` under `file:///C:/pub_cache/...` and no longer under the `Bonsi's Friend` path.

**If it still fails:**
- Run `flutter pub cache repair`, delete `.dart_tool/` and `build/`, then repeat step 4.
- If the Gradle output mentions a path under the user profile, also set `GRADLE_USER_HOME` to a plain path (for example `C:\gradle_home`) and reopen the terminal.
- Only then check version compatibility: run `flutter --version`, then `flutter pub upgrade fl_chart`. `fl_chart` 0.67.0 should compile on a current stable Flutter, so a version bump is a last resort, not the first move.
- Last-resort alternative: build from a Windows account whose profile folder has no spaces or special characters.

**Rules for the implementing agent:**
- Do **not** vendor or patch `fl_chart`, and do not remove or replace the charts to work around this.
- Do not commit machine-specific paths (`PUB_CACHE`, `GRADLE_USER_HOME`) into the repo.
- Add a short "Windows setup" note to `README.md` explaining that the Windows user folder must not contain spaces or apostrophes, or `PUB_CACHE` must be set to a plain path such as `C:\pub_cache`.

**Acceptance:** `flutter run` builds and launches the debug app, `flutter build apk --release` succeeds, and the Analytics charts (doughnut and bar) render.

---

## 2. Phase 0B — Startup & runtime performance (do this after 0A)

**Problem:** the app takes noticeably long to load on start. The goal is a fast first frame, and a debt list that stays fast as data grows.

### 2.1 Measure first
- [ ] Profile with `flutter run --profile` (and `--trace-startup`). Debug mode is much slower than release and must not be used to judge startup.
- [ ] Record time-to-first-frame before and after in the PR description.

### 2.2 `main()` ordering
- [x] Only these may block `runApp`: `WidgetsFlutterBinding.ensureInitialized()`, reading `SharedPreferences` (theme, language, currency), and opening the DB handle.
- [x] Run independent initialisation in parallel with `Future.wait` instead of sequential `await`s.
- [x] Load provider data after the first frame (`WidgetsBinding.instance.addPostFrameCallback`) or lazily when a screen is first opened. The Debts tab loads when first opened.
- [ ] Avoid multiple `notifyListeners()` calls during init; batch to one per provider.
- [ ] Add a native splash (`flutter_native_splash`) so there is no white screen before Flutter draws.

### 2.3 Data loading
- [x] Dashboard loads only the latest 30–50 transactions and paginates on scroll (keyset: `WHERE date < ? ORDER BY date DESC LIMIT ?`).
- [x] Wallet balances, weekly summary, and analytics totals come from SQL aggregates (`SUM ... GROUP BY`), not from summing lists in Dart.
- [x] Add indexes (in the v4 migration, see Phase 1):
  ```sql
  CREATE INDEX IF NOT EXISTS idx_tx_date ON transactions(date DESC);
  CREATE INDEX IF NOT EXISTS idx_tx_wallet_date ON transactions(wallet_id, date DESC);
  ```
- [x] Enable WAL: `PRAGMA journal_mode=WAL;` when opening the DB.

### 2.4 Motion & rendering at startup
- [x] Ambient particles start after the first frame, sit inside a `RepaintBoundary`, have a capped particle count, and pause when the app is backgrounded.
- [x] Wallet balance count-up animates only on balance changes, **not on cold start** (show the real number instantly).
- [ ] Staggered entrance animations: first screen only, 30–50 ms between items, never blocking input. Skipped under reduced-motion.
- [ ] Wallet logos: small WebP/PNG assets; `precacheImage` only for visible wallets.
- [ ] `excel` / `csv` parsing runs only on import/export, inside `compute()` (isolate).

### 2.5 List rendering
- [ ] Use `ListView.builder` with `itemExtent` or `prototypeItem` where row height is fixed.
- [ ] Use `Selector` / `context.select` so a change to one row does not rebuild the entire list.

**Acceptance:** release-mode time-to-first-frame measurably lower than baseline; dashboard scrolls smoothly with 5,000+ seeded transactions; no feature regressions.

---

## 3. Key design decisions (already made)

### 3.1 Money is stored as integers
- **New tables store money as `INTEGER` minor units** (centavos), never `REAL`. This avoids floating-point drift and sums faster.
- Convert at the boundary only: UI/`Formatter` work in decimal, DB layer stores integers (`(value * 100).round()`).
- Inspect how `transactions.amount` is currently stored. **DECISION NEEDED:** if it is `REAL`, do **not** silently migrate existing data. Keep existing transaction behavior unchanged, convert at the boundary for debt-linked rows, and propose (in the PR) a separate migration of `transactions.amount` to integers.

### 3.2 Debts are system wallets, and debt movements are not income/expense
Lending is not spending and borrowing is not earning. Treating them as expense/income would pollute analytics, budgets, and the weekly summary.

- Add two **system wallets**, shown in the Wallets screen under a new group **"Debts"**:
  - **Receivables** — money owed to you
  - **Payables** — money you owe
- System wallets are flagged `is_system = 1`, are **not editable or deletable**, and cannot be picked as the source wallet of a normal transaction.
- **Their balances are derived, not stored:**
  - Receivables = `SUM(remaining_minor)` of active `lent` debts
  - Payables = `SUM(remaining_minor)` of active `borrowed` debts
  - Where active = `status IN ('outstanding','partial')`.
- Tapping Receivables or Payables opens the Debts tab filtered to that direction.
- Wallet selection on a debt always refers to a **real** wallet (the one the money actually left or entered).

### 3.3 How debt movements hit real wallets
Add a nullable `debt_id` column to `transactions` (and `debt_repayment_id`). A transaction with a non-null `debt_id` is a **debt-linked movement**:

- It **does** change the real wallet's balance.
- It is **excluded** from analytics, budgets, and the weekly income/expense summary (`WHERE debt_id IS NULL` in those queries).
- It is shown in the transaction list with a small "Debt" indication and the person's name as the remark.

| Event | Real wallet | Transaction written |
|---|---|---|
| Lent (create) | decreases by principal | debt-linked outflow |
| Borrowed (create) | increases by principal | debt-linked inflow |
| Repayment on a lent debt | increases | debt-linked inflow (principal portion) |
| Repayment on a borrowed debt | decreases | debt-linked outflow (principal portion) |

**Interest:** the repayment amount is applied to principal first. Any amount beyond the remaining principal is interest. The interest portion is written as a **normal** transaction (income if lent, expense if borrowed, category `others`) so analytics reflect the real gain or cost.

### 3.4 Interest model (flat, simple)
- Stored: `principal_minor`, `interest_rate` (percent, `REAL`, e.g. `5.0`), `total_due_minor`.
- `total_due_minor = principal_minor + round(principal_minor * interest_rate / 100)` when interest is enabled, otherwise `principal_minor`.
- `remaining_minor` starts at `total_due_minor` and decreases with repayments.
- Interest toggle is **off by default**. The form shows the computed total live, under the amount field, as the user types (instant update, no animation).

---

## 4. Phase 1 — Foundation

- [x] Bump SQLite DB version to **4**. The whole v3 → v4 migration runs inside **one transaction** and only when upgrading.
- [x] Create tables, indexes, models, provider, contact logic as below.

### Schema (v4)

```sql
CREATE TABLE debts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  person_name TEXT NOT NULL,
  direction TEXT NOT NULL,                 -- 'lent' | 'borrowed'
  principal_minor INTEGER NOT NULL,        -- original principal, centavos
  interest_rate REAL NOT NULL DEFAULT 0,   -- percent, 0 = no interest
  total_due_minor INTEGER NOT NULL,        -- principal + flat interest
  remaining_minor INTEGER NOT NULL,        -- decreases with repayments
  principal_paid_minor INTEGER NOT NULL DEFAULT 0,
  due_date TEXT,                           -- ISO date, nullable
  note TEXT,
  wallet_id INTEGER NOT NULL,              -- REAL wallet only
  created_at TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'outstanding'  -- outstanding | partial | archived
);

CREATE TABLE debt_repayments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  debt_id INTEGER NOT NULL,
  amount_minor INTEGER NOT NULL,
  date TEXT NOT NULL,
  note TEXT,
  FOREIGN KEY (debt_id) REFERENCES debts(id) ON DELETE CASCADE
);

CREATE TABLE contacts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  last_used TEXT
);

CREATE TABLE budgets (
  category INTEGER PRIMARY KEY,            -- matches the Transaction category enum
  limit_minor INTEGER NOT NULL,
  period TEXT NOT NULL DEFAULT 'monthly'
);

ALTER TABLE transactions ADD COLUMN debt_id INTEGER;
ALTER TABLE transactions ADD COLUMN debt_repayment_id INTEGER;
-- wallets: add is_system INTEGER NOT NULL DEFAULT 0 (inspect the existing wallets table first)

-- indexes
CREATE INDEX idx_debts_status_due ON debts(status, due_date);
CREATE INDEX idx_debts_direction_status ON debts(direction, status);
CREATE INDEX idx_debts_person ON debts(person_name);
CREATE INDEX idx_repayments_debt ON debt_repayments(debt_id);
CREATE INDEX idx_contacts_last_used ON contacts(last_used DESC);
CREATE INDEX idx_tx_debt ON transactions(debt_id);
```

Notes:
- `status` has **no separate `paid` value**: a fully repaid debt goes straight to `archived` (auto-archive).
- Insert the Receivables and Payables system wallets in the migration (and in the fresh-install `onCreate` path).
- Enable `PRAGMA foreign_keys = ON`.

### Models and provider
- [x] Models: `Debt`, `DebtRepayment`, `Contact`, `Budget` (money fields in minor units; convenience getters for decimal display).
- [ ] `DebtProvider`:
  - CRUD for debts
  - Loads **active debts only** by default; archived debts load lazily when that filter opens (keyset pagination: `WHERE id < ? ORDER BY id DESC LIMIT 30`)
  - Caches summary totals (total owed to you, total you owe) and updates them incrementally on create/repay/archive; do not recompute on every `notifyListeners()`
  - Header totals come from one aggregate query:
    ```sql
    SELECT direction, SUM(remaining_minor) FROM debts
    WHERE status IN ('outstanding','partial') GROUP BY direction;
    ```
- [x] The **debt list never touches `debt_repayments`.** Repayments load only when a debt's detail view opens. List queries select only the columns the row needs, with no joins.
- [x] Contact logic: upsert on debt creation, update `last_used`, sort by `last_used DESC`.
- [x] Every create / repay / archive writes the debt row, repayment row, and linked transactions in **one DB transaction** (atomic).

---

## 5. Phase 2 — Core debt features

### 5.1 Functionality
- [x] New bottom nav tab: **Debts** (5 tabs total, order as in section 1).
- [x] Debts list screen with filter chips: **Outstanding / Partial / Archived** (Outstanding is the default).
- [x] Create & Edit Debt form:
  - Person (contact chips + add new)
  - Direction (Lent / Borrowed)
  - Amount, with the interest toggle and live total directly beneath it
  - Due date (optional)
  - Wallet (real wallets only)
  - Note
- [x] On creation, write the debt-linked transaction per section 3.3. Editing the amount, direction, or wallet of a debt that already has repayments is **blocked** (show an explanation); other fields remain editable.
- [x] Dashboard quick **"IOU"** button, which opens the form with Lent preselected. It must not crowd the existing + and − buttons.
- [x] Partial repayment flow:
  - Enter amount (cannot exceed `remaining_minor`)
  - Apply principal-first, split interest per section 3.3
  - Reduce `remaining_minor`, set `status = 'partial'` or archive when it reaches 0
- [x] **Auto-archive** when `remaining_minor <= 0`. Archived debts remain viewable under the Archived filter.
- [x] Confirmation for Mark as Paid / Archive actions.
- [x] Wallets screen: new **Debts** group showing Receivables and Payables rows (section 3.2).
- [ ] Analytics, budgets, and the dashboard weekly summary exclude debt-linked transactions (section 3.3).
- [x] **Import/export:** CSV and Excel export/import include debts and repayments so backups are complete. Importing older backups without debts must still work.
- [x] Help & User Guide: add a Debts section to the existing tabbed guide.

### 5.2 Design spec (Debts tab)

**Visual thesis:** a ledger of people, not another transaction list. The person's name is the focal point, the amount sits right-aligned, and status is carried by hierarchy rather than extra labels.

**Rules**
- Use the existing theme tokens, fonts, and wallet-card language. No new palette, no new fonts.
- One accent only: **overdue**. Everything else stays quiet.
- Lent vs Borrowed is always carried by **text plus sign (+/−)**, never by color alone. The existing income green / expense red may reinforce it.
- No nested cards. Rows are separated by spacing and hairline dividers.
- Avatars are initials in a theme-tinted circle. No stock icons, no icon tiles.
- No ALL-CAPS eyebrow labels, no gradients, no decorative shadows.
- A progress bar appears **only** on partially paid debts.

**Wireframe**

```
+------------------------------+
| Owed to you      P 4,200.00  |   <- focal number
| You owe            P 800.00  |   <- secondary, smaller
+------------------------------+
| [Outstanding]  Partial  Archived |
+------------------------------+
| (JD) Juan Dela Cruz          |
|      Lent · due Nov 12       |
|                  P 1,500.00  |
| =====-----  paid P 500       |   <- only if partial
+------------------------------+
| (MS) Maria Santos            |
|      Borrowed · overdue 3 days |
|                    P 800.00  |
+------------------------------+
                   [ + IOU ]
```

**Type roles (reuse app font):** totals 28 semibold, person name 16 semibold, status line 13 regular, amount 16 semibold right-aligned.

**Copy (sentence case, same verb in button, toast, and history)**
- Empty state: "No debts yet. Tap + IOU to record one."
- Actions: "Record repayment", "Mark as paid", "Archive"; toasts: "Repayment recorded", "Marked as paid", "Archived".
- Overdue: "Overdue 3 days". Errors state what went wrong and how to fix it, with no apology or vague wording.

**States required:** empty, loading, error, overdue, partial, archived, and a disabled "Save" until the form is valid.

### 5.3 Motion rules
| Where | Decision |
|---|---|
| Tab switch, filter chips, list scroll | No animation (used dozens of times daily) |
| Row press | 100–150 ms scale to 0.98, ease-out |
| Repayment / debt form sheet | Standard bottom sheet, under 250 ms, ease-out |
| Debt becoming archived | One ~200 ms fade-and-collapse, shows what changed |
| Interest total under amount | Updates instantly, no count-up |
| First-screen stagger | 30–50 ms between rows, first load only |

Use `ease-out` curves only for entering elements; never `ease-in` for UI. Respect `MediaQuery.disableAnimations` / reduced motion everywhere.

---

## 6. Phase 3 — Notifications & polish

- [ ] Integrate `flutter_local_notifications` + `timezone`.
- [ ] Schedule a notification when a debt with a due date is created or updated; cancel it when the debt is archived or deleted; reschedule on edit.
- [ ] Use **inexact** scheduling for debt reminders so `SCHEDULE_EXACT_ALARM` is not required. (Exact alarms are only needed if a later feature requires them.)
- [ ] Request notification permission (Android 13+ `POST_NOTIFICATIONS`) **only** when the first debt with a due date is saved.
- [ ] Optional: also notify 1 day before the due date.
- [ ] Re-schedule pending notifications on app start if needed (they can be cleared by reboot).
- [ ] Localised notification text in all 7 languages.

---

## 7. Phase 4 — Recurring transactions

- [ ] Add recurrence to transactions (or a dedicated `recurring_templates` table; prefer the dedicated table so the template can be edited without touching history).
- [ ] Fields: `is_recurring`, `recurrence_rule` (`weekly` | `monthly` | `yearly`), `next_occurrence`, `end_date` (optional).
- [ ] "Make recurring" toggle in the Income / Expense modals, plus an interval picker.
- [ ] The user can edit or stop the template at any time.
- [ ] On app open **after the first frame** (never before), generate all due occurrences, including missed ones, and advance `next_occurrence`. Monthly rules handle month-end (e.g. the 31st).
- [ ] Generated transactions are normal transactions (they count in analytics and budgets).

---

## 8. Phase 5 — Budgets

- [ ] Monthly budget limit per category (money stored in minor units).
- [ ] Analytics screen shows progress bars for spent vs limit; spent is calculated with a SQL aggregate and excludes debt-linked transactions.
- [ ] Visual warning when over budget (reuse the existing red; do not add a new color).
- [ ] Easy "Set budget" action per category.

---

## 9. Phase 6 — First-run experience

- [x] `SharedPreferences` flag `hasSeenHelpGuide` (default `false`).
- [x] On first launch, open the existing Help & User Guide modal once the first frame is rendered.
- [x] "Show Help Guide again" button in Settings.
- [ ] Optional: also trigger when the database is completely empty.

---

## 10. Testing & quality gates

- [x] Unit tests: interest calculation, principal-first repayment split, auto-archive, contact upsert/order, minor-unit conversion (including `0.1 + 0.2` style cases).
- [x] Migration test: a v3 database upgrades to v4 with all existing data intact and balances unchanged.
- [ ] Verify analytics, budgets, and the weekly summary ignore debt-linked transactions, while wallet balances still include them.
- [x] Verify Receivables/Payables totals equal the sum of active debts after create, repay, edit, archive, and import.
- [x] `flutter analyze` clean; no new warnings.
- [ ] Manually check light/dark and at least two themes, and a small-screen Android device.

---

## 11. Do not

- Do not store new money values as `REAL`.
- Do not record lending/borrowing as normal income/expense.
- Do not join `debt_repayments` in the list query.
- Do not run recurring checks, debt loading, or particles before the first frame.
- Do not add new fonts, palettes, packages for UI, nested cards, ALL-CAPS eyebrow labels, or gradient decoration to the Debts UI.
- Do not hard-code user-facing strings.
- Do not silently migrate existing transaction amounts; propose it first.
- Do not patch, vendor, or remove `fl_chart` to work around the Windows build error, and do not commit machine-specific paths (`PUB_CACHE`, `GRADLE_USER_HOME`).

---

## 12. Suggested order of work

1. **Phase 0A:** fix the `fl_chart` build failure (move the pub cache to a path without spaces or apostrophes).
2. **Phase 0B:** measure, fix `main()` ordering, pagination, indexes, WAL, particles/count-up.
3. **Phase 1:** v4 migration, models, `DebtProvider`, contacts.
4. **Phase 2:** Debts tab, form, repayments, system wallets, import/export, help guide.
5. **Phase 3:** notifications.
6. **Phases 4–6:** recurring, budgets, first-run guide.

Each checkbox can become a GitHub Issue.
### Implementation notes (2026-11-01)
- Read the full roadmap and inspected the existing v3 database/providers/widgets.
- Shared concurrent database-open requests; balances show their actual value on mount;
  particles start after the first frame, remain capped at 15, pause in background,
  respect reduced motion, and have a repaint boundary. Entrance fades also respect reduced motion.
- Added the Windows cache setup note to README. No cache paths or chart patches committed.
- Phone detected: Infinix X6880, Android 15. Profile/startup measurement is blocked
  before Dart compilation by Java/Gradle `Unable to establish loopback connection`
  (`UnixDomainSockets.connect`, `Invalid argument: connect`). IPv4 and Windows selector
  overrides did not resolve it. The fl_chart failure has not been reproduced.
- Phase 0A acceptance and later phases remain pending; no startup improvement is claimed.
- Existing transaction amounts are REAL; retained unchanged. A separate, explicitly
  approved migration would be needed to convert historical amounts to minor units.

### User scope override: remove decorative motion (2026-11-01)
Particles, staggered entrance fades/slides, and balance count-ups are removed at
user request. Their existing wrappers now render static content immediately,
without controllers, delayed callbacks, painters, or tickers. This supersedes the
motion requirements and earlier particle lifecycle implementation notes above.

### Stable dependency compatibility (2026-11-02)
- Installed SDK verified: Flutter 3.44.4 stable / Dart 3.12.2.
- Upgraded share_plus 7.2.2 -> 13.3.1 (built-in Kotlin support) and migrated
  sharing to SharePlus.instance.share with ShareParams.
- Upgraded file_picker 8.x -> 13.3.1 to resolve win32 dependency incompatibility;
  migrated directory selection and single-file import to its static API.
- Raised Android Gradle Plugin 8.11.1 -> 8.12.1 per share_plus requirements;
  retained Gradle 8.14.2 and Kotlin 2.2.20. Minimum Flutter/Dart constraints now
  reflect the new plugin requirements. Did not migrate the Android project to AGP 9.
- Dependency resolution succeeded. Agent-side phone build still stops before
  compilation with the Java loopback error. The user's terminal output showed
  warnings followed by manual cancellation, not an actual compiler failure.
- Device import/export/share smoke tests remain pending a successful Android build.
- Final validation after API migration: flutter analyze clean; flutter test passed. Phone launch and backup import/export/share still require device verification.


### Debt, onboarding and runtime work (2026-11-02)
- User requested debt features and first-install help, with performance retained as a priority.
  Proceeded with these requested features while agent-side Android builds remain blocked;
  device profiling, native splash, recurring transactions, budgets UI, and debt reminders
  remain unchecked. No measured phone startup or build-speed improvement is claimed.
- The supplied terminal log establishes a successful APK build (353.7 seconds), followed
  by install and launch. That time is Gradle compilation, not time-to-first-frame.
  Its signing mismatch caused Flutter to uninstall the previous version. Agent verification
  uses build-only commands and does not uninstall the app. The original pub-cache path
  alone is not an established cause of the build delay.
- DB v4 uses sqflite's existing onCreate/onUpgrade transaction (no nested transaction).
  Preserved historical REAL amounts exactly; debt amounts use integer centavos and convert
  at the transaction boundary. A historical-money migration remains a separate proposal.
- Enabled foreign keys and WAL; added compound date/id and wallet/date/id indexes.
  Dashboard uses 50-row keyset pages with an ID tie-breaker, literal remark search and a
  200ms debounce. Totals use one SQL aggregate, cached across search and wallet changes.
  Analytics loads SQL category aggregates only when opened or its query changes. Provider
  data loads after the first frame; theme/language/currency preferences load before it.
- Debts load 30-row pages after opening the tab. Repayment history loads only in details.
  Cached summary totals are refreshed with one aggregate after mutations (rather than
  incrementally adjusted in memory); this also avoids drift after backup imports.
- Implemented debt creation/editing, optional flat interest off by default, contacts,
  principal-first repayments, full-payment confirmation, auto-archive, manual archive,
  and confirmed deletion that reverses its recorded movements. Editing financial fields
  after repayment is blocked. Debt-linked principal is excluded from analytics/weekly
  totals; interest is an ordinary transaction. Managed movements cannot be individually
  edited or deleted. Wallets referenced by debt history cannot be deleted.
- Receivables/Payables system rows display active debt sums separately from real-wallet
  balances, are read-only, and navigate to a direction-filtered Debts tab. SQL inserts
  the system wallets, while WalletProvider returns real wallets for all money pickers.
- Backups now use a versioned RecordType/Payload CSV or WalletBackup Excel worksheet:
  wallets (including starting balances), transactions, debts, repayments and contacts.
  Import remaps IDs atomically and adds to existing data. Matching wallet names reuse the
  wallet and add its backed-up starting balance; importing twice duplicates the data,
  explained in the confirmation. Legacy transaction-only CSV/Excel remains accepted.
  Encoding/decoding runs in compute isolates. New-format backups target this version of
  the app; older app versions do not understand their record format.
- hasSeenHelpGuide opens the existing guide after the first frame/data load only once;
  Settings retains its existing manual guide entry. Added the debt guide tab.
- New strings are in all seven ARBs and generated l10n. Translation limitation:
  new debt/backup strings in ja/zh/fr/es/de/pt are flagged English placeholders.
- Automated verification includes real SQLite migration, payment atomicity, principal/
  interest splits, contact ordering, archive/delete balances, 5,001-row pagination,
  CSV/Excel round trips (including starting balance), malformed-backup rollback,
  legacy CSV compatibility, and the first-run flag. Device startup timing and real-device
  chart/share/import/notification checks remain pending.

- Final automated validation: flutter analyze clean; all 16 tests pass, including
  320px debt list/detail layout checks in light and dark with two theme seeds.
  Budget-related combined checklist entries remain pending their future UI/query phase;
  analytics and weekly-summary exclusion are implemented and tested now.

### Row readability and record actions (2026-11-02)
- User requested alternating rows, tap-to-view details, edit/delete in details,
  and automatic keyboard focus for the dashboard income/expense actions.
- Transaction and debt rows alternate existing surface theme tones with no animation.
  Transaction details show the full stored event timestamp (seconds and local UTC
  offset), type, wallet, category, remark and amount. Details are built only on tap.
- Ordinary transactions offer Edit and Delete in details; deletion retains confirmation
  and Undo. Debt-managed principal/interest movements offer Open debt, keeping their
  edits/deletion inside the atomic debt workflow. Debt details show creation time.
- New income/expense forms autofocus their numeric amount field. Income content scrolls
  with the keyboard; removed duplicate keyboard padding from the expense dialog and
  made narrow-screen headers/dropdowns flexible. New detail labels are translated in
  all seven ARBs; earlier debt-placeholder translations remain as documented above.
- Automated interaction tests cover alternating colors, timestamp visibility, edit,
  delete/undo, debt-managed action protection, and both auto-focused numeric keyboards
  at 320px with a keyboard inset. All 20 tests pass; Android device verification remains
  subject to the previously documented Gradle loopback build blocker.

### Analytics defaults and data-safe updates (2026-11-02)
- Analytics now opens on Today. Added a local-calendar This week filter (Monday
  through Sunday), aligned with the dashboard. Today/Week/Month/All time/Calendar
  are ordered for quick access. SQL aggregates still exclude debt principal.
- User clarified that update safety is the priority: no automatic record reset,
  database recreation, uninstall, or Clear all data during an update.
- Added scripts/install-android.ps1: builds then uses adb install -r, retains the
  application ID, and stops on build or signing failures with no uninstall fallback.
  Use the same signing certificate across updates. Did not change or generate keys,
  change the package ID, install a build, or clear data on the connected phone.
- SQLite upgrades remain in one transaction; explicit onDowngrade rejects older
  binaries without deleting newer data. Tests verify all original v3 field values,
  same-version reopen retention, complete rollback of a failed migration, and
  refusing a downgrade while preserving the database version and debt records.
- Clear all data remains an explicit Settings action with two confirmations. Its
  wording and transaction now cover debts, repayments, contacts, budgets, custom
  wallets and wallet starting balances, while retaining an empty Cash/system-wallet
  baseline. No startup, filter, migration or installer code calls this reset.
- Android backup/transfer rules explicitly include the Flutter documents database
  directory (including SQLite sidecars) and preferences. This supports an available
  Android restore; manual CSV/Excel import remains the new-device fallback. OS backup
  availability is separate from retaining the local database during an update.
- Validation: all 28 Flutter tests pass; flutter analyze and diff whitespace checks
  clean. Android resources compile with aapt2. Installer WhatIf and a simulated ADB
  signature mismatch/build failure confirm no uninstall/reset fallback (no real
  device operation). Actual app upgrade/device-transfer smoke tests remain pending
  the agent-side Gradle loopback blocker described earlier.

### Startup performance pass (2026-11-02)
- Start preferences, transaction loading and wallet loading concurrently before
  runApp. Only saved preferences gate rendering; the first frame does not wait for
  database results. Reuse the same load future for first-run help, avoiding a second
  startup read. The existing single-flight SQLite open and migrations are unchanged.
- Transaction and wallet lists now create immutable snapshots on changes instead
  of copying their entire loaded contents on every getter call. Cache amount
  formatters by locale; disable the remaining pie/bar chart transition animations.
- Only refresh history after actually returning from the background, not every
  brief inactive/resumed event such as opening the notification shade. Background
  returns still refresh date-dependent totals.
- Reviewed paging, SQL totals/indexes, lazy tabs and background backup encoding;
  these existing optimizations remain. No schema, durability, signing, identity,
  financial calculations or data-retention policy changes in this pass.
- Validation: 29 tests pass including first-frame responsiveness, no duplicate
  startup loads, lifecycle refresh and existing migration/data-safety regressions.
  Flutter analysis and whitespace checks pass. Release build attempted but still
  blocked by Gradle's loopback connection failure. ADB currently lists no device;
  actual startup milliseconds and on-phone improvement are not yet measured.
