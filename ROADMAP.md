# Wallet Tracker — Feature Roadmap

> Offline-first Flutter expense & savings tracker  
> Last updated: 2026-09-26

---

## Confirmed Scope

### Debt / IOU System
- Track both **Lent** (you gave money) and **Borrowed** (someone gave you money)
- Optional **simple percentage interest** (toggle + real-time calculation) (off toggle be default)
- Partial repayments supported
- Auto-archive when fully paid
- Person contact list (frequent people for quick select)
- Quick “IOU” button on Dashboard
- Local notifications for due dates

### Other Features
- Recurring transactions (rent, salary, subscriptions)
- Budget limits per category + progress bars (monthly)
- Force open Help & User Guide on first launch

### UI Decision
- New bottom navigation tab dedicated to **Debts / IOUs**

**New bottom nav structure:**
```
Dashboard | Wallets | Debts | Analytics | Settings
```

---

## Phase 1 – Foundation

- [ ] Bump SQLite database version to **4**
- [ ] Create new tables:
  - `debts`
  - `debt_repayments`
  - `contacts`
  - `budgets`
- [ ] Create models:
  - `Debt`
  - `DebtRepayment`
  - `Contact`
  - `Budget`
- [ ] Create `DebtProvider` with basic CRUD
- [ ] Contact list logic (upsert on debt creation, sort by last used)

### Suggested Schema

```sql
CREATE TABLE debts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  person_name TEXT NOT NULL,
  amount REAL NOT NULL,                -- original principal
  remaining_amount REAL NOT NULL,      -- decreases with repayments
  interest_rate REAL DEFAULT 0,        -- e.g. 5.0 for 5%
  due_date TEXT,                       -- ISO date, nullable
  note TEXT,
  direction TEXT NOT NULL,              -- 'lent' | 'borrowed'
  wallet_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'outstanding'  -- outstanding | partial | paid | archived
);

CREATE TABLE debt_repayments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  debt_id INTEGER NOT NULL,
  amount REAL NOT NULL,
  date TEXT NOT NULL,
  note TEXT,
  FOREIGN KEY (debt_id) REFERENCES debts(id)
);

CREATE TABLE contacts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  last_used TEXT
);

CREATE TABLE budgets (
  category INTEGER PRIMARY KEY,        -- matches Transaction.Category enum
  limit_amount REAL NOT NULL,
  period TEXT DEFAULT 'monthly'
);
```

---

## Phase 2 – Core Debt Features

- [ ] New bottom navigation tab: **Debts / IOUs**
- [ ] Debt list screen with filters:
  - Outstanding
  - Partial
  - Archived
- [ ] Create & Edit Debt form
  - Person (from contacts or add new)
  - Direction (Lent / Borrowed)
  - Amount
  - Interest toggle + **real-time total calculation**
  - Due date (optional)
  - Wallet selection
  - Note
- [ ] On debt creation → automatically create matching transaction:
  - Lent → Expense
  - Borrowed → Income
- [ ] Quick **“IOU”** button on Dashboard (pre-selects “Lent”)
- [ ] Partial repayment flow
  - Record payment amount
  - Reduce `remaining_amount`
  - Create reverse transaction
  - Update status to `partial` or `paid`
- [ ] **Auto-archive** when `remaining_amount <= 0`
- [ ] Archive view / filter

### Interest Real-time Logic (simple)

```dart
double get totalWithInterest {
  if (!useInterest || interestRate <= 0) return principal;
  return principal * (1 + interestRate / 100);
}
```

Show the calculated total live under the amount field while the user types.

---

## Phase 3 – Notifications & Polish

- [ ] Integrate `flutter_local_notifications` + timezone support
- [ ] Schedule local notification when a debt with due date is created/updated
- [ ] Request notification permission only on first debt that has a due date
- [ ] Optional: notify 1 day before due date (configurable later)
- [ ] Confirmation dialogs for Mark as Paid / Archive actions

---

## Phase 4 – Recurring Transactions

- [ ] Add recurrence support to transactions (or dedicated table)
- [ ] Fields: `is_recurring`, `recurrence_rule` (`weekly` | `monthly` | `yearly`), `next_occurrence`, `end_date` (optional)
- [ ] “Make recurring” toggle inside Income / Expense modal
- [ ] Interval picker
- [ ] Allow user to **edit the template** anytime
- [ ] On app open → check for due recurring items, generate the next transaction, and advance `next_occurrence`

---

## Phase 5 – Budgets

- [ ] Budget limits per category (monthly period only for now)
- [ ] UI in Analytics screen: progress bars showing spent vs limit
- [ ] Visual warning when over budget
- [ ] Easy “Set Budget” action per category

---

## Phase 6 – First-run Experience

- [ ] Add `SharedPreferences` flag: `hasSeenHelpGuide` (default `false`)
- [ ] On first app launch → automatically open the existing Help & User Guide modal
- [ ] Add “Show Help Guide Again” button in Settings
- [ ] (Optional) Also trigger if the database is completely empty

---

## Implementation Notes

### Auto-archive behavior
When a repayment brings `remaining_amount` to ≤ 0 → set `status = 'archived'` automatically. User can still view it under the Archived filter.

### Contact list
- Lightweight: name only
- Sorted by `last_used` descending
- Shown as chips / dropdown when creating a debt
- New names are automatically added

### Transaction linking
Every debt creation and every repayment should create a corresponding transaction so wallet balances stay accurate.

### Design
Visual design of the new Debts tab and forms will be discussed later. Functionality first.

---

## Suggested Next Steps

1. Start with **Phase 1** (DB migration + models + DebtProvider)
2. Then implement the Debts tab and basic CRUD (Phase 2)
3. Add interest calculation and partial repayments
4. Layer on notifications, recurring, and budgets

Feel free to turn each checkbox into a GitHub Issue.
