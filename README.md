# Wallet Tracker

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
- Category filter

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
- **Export to CSV**
- Theme selection: **Mint**, **Sunset**, **Ocean**
- (Reminders planned)

---

## Tech Stack

| Layer            | Choice              | Notes                          |
|------------------|---------------------|--------------------------------|
| Framework        | Flutter             | Cross-platform                 |
| Database         | SQLite (`sqflite`)  | Fully offline                  |
| State management | Provider            | Simple & sufficient            |
| Charts           | fl_chart            | Lightweight pie charts         |
| Preferences      | shared_preferences  | Theme & settings               |
| CSV              | csv                 | Export                         |

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
├── models/             # Transaction model
├── providers/          # TransactionProvider & SettingsProvider
├── screens/            # Dashboard, Analytics, Settings
├── widgets/            # Reusable UI components
└── main.dart
```

---

## Roadmap / Planned Features

- [ ] Daily expense reminders (local notifications)
- [ ] Date range filters on Dashboard
- [ ] Currency symbol selector
- [ ] Light / Dark mode toggle per theme
- [ ] Better empty states & haptic feedback polish

**Explicitly out of scope for MVP:**
- Cloud sync / accounts
- Multiple wallets
- Custom categories
- Budgets / spending limits
- Recurring transactions

---

## License

This project is currently unlicensed. Feel free to use and modify for personal use.

---

Made with ❤️ using Flutter
