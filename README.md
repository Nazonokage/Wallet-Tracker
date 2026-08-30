# Expense Tracker

A simple, offline-first personal expense tracker built with Flutter.

**Core promise:** Log a transaction in under 5 seconds, see your balance instantly, and understand your spending at a glance.

No accounts. No cloud. No ads. Just fast entry and clear visibility into where your money goes.

---

## Features

### Dashboard
- Large, clear **balance** at the top
- **Weekly summary** ("This week: +₹X / −₹Y")
- Scrollable transaction list (most recent first)
  - Green for income, red for expense
  - Category emoji + remark + amount + date
- **Swipe left** → Edit
- **Swipe right** → Delete (with undo)
- Floating **+** (Income) and **−** (Expense) buttons placed in the natural thumb zone
- Category + wallet filters

### Income Entry
- Amount (required)
- Optional remark
- Instant save

### Expense Entry
Two modes:
- **Direct** — amount + category + optional remark
- **Change Calculator** — enter cash given and cash received → auto-calculates the actual amount spent

**Fixed categories (v1):**
| Emoji | Category |
|-------|----------|
| 🍔    | Food     |
| 🚌    | Commute  |
| 📄    | Bills    |
| 🛍️    | Shopping |
| 📦    | Others   |

### Analytics
- Pie chart of spending by category
- List with totals and percentages
- All-time view (month filter planned for later)

### Settings
- **Clear all data** (double confirmation)
- **Export** → CSV or Excel (.xlsx)
- **Import** → CSV or Excel (.xlsx)  ← recover data after reinstalls / renames
- Theme selection + Dark mode
- Currency symbol selector

---

## Export / Import format

Both CSV and XLSX use the same columns:

```
Date, Type, Category, Amount, Remark, Wallet
```

- **Date**: ISO-8601 (`2025-08-30T14:22:00.000`)
- **Type**: `Income` or `Expense`
- **Category**: `food`, `commute`, `bills`, `shopping`, `others` (ignored for income)
- **Amount**: number
- **Remark**: free text (optional)
- **Wallet**: wallet name (defaults to `Cash` if missing)

You can open the exported file in Google Sheets / Excel, edit it, and re-import it later.

---

## Tech Stack

| Layer            | Choice              | Notes                          |
|------------------|---------------------|--------------------------------|
| Framework        | Flutter             | Cross-platform                 |
| Database         | SQLite (`sqflite`)  | Fully offline                  |
| State management | Provider            | Simple & sufficient            |
| Charts           | fl_chart            | Lightweight pie charts         |
| Preferences      | shared_preferences  | Theme & settings               |
| CSV              | csv                 | Export / Import                |
| Excel            | excel               | Native .xlsx Export / Import   |

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0+)
- Android Studio / VS Code with Flutter extensions

### Run the app

```bash
git clone https://github.com/Nazonokage/Wallet-Tracker.git
cd Wallet-Tracker
flutter pub get
flutter run
```

---

## Project Structure

```
lib/
├── db/                 # SQLite database layer
├── models/             # Transaction + Wallet models
├── providers/          # TransactionProvider, WalletProvider, SettingsProvider
├── screens/            # Dashboard, Analytics, Settings
├── utils/              # ImportExportHelper (CSV + XLSX)
├── widgets/            # Reusable UI components
└── main.dart
```

---

## Recovering data after the rename

If you previously used the app under the old package name and the database file was lost:

1. If you still have an old CSV export → use **Settings → Import Data**
2. If you only have the old APK installed on a device, you can try pulling the old SQLite file:
   ```bash
   adb shell "run-as <old.package.name> cat databases/wallet_tracker.db" > old.db
   ```
   (Then convert it manually or ask for help.)

The new import feature is the recommended long-term recovery path.

---

## Roadmap / Planned Features

- [ ] Daily expense reminders (local notifications)
- [ ] Date range filters on Dashboard
- [ ] Better empty states & haptic feedback polish

**Explicitly out of scope for MVP:**
- Cloud sync / accounts
- Multiple accounts beyond the simple wallet system
- Custom categories
- Budgets / spending limits
- Recurring transactions

---

## License

This project is currently unlicensed. Feel free to use and modify for personal use.

---

Made with ❤️ using Flutter
