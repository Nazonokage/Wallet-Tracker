# Wallet Tracker (v1.8)

A fast, customizable, offline-first personal expense and savings tracker built with Flutter.

**Core promise:** Log transactions in seconds, manage customizable wallets with brand logos, view interactive analytics with calendar pickers, and enjoy smooth ambient UI motion.

No cloud sync. No accounts. No ads. Just pure speed, privacy, and full visibility over your money.

---

## 🌟 Key Features

### 💳 1. Customizable Wallets & Savings
- **1-Column Customizable Wallet Cards**: Grouped into Savings, Digital Wallets, Bank Accounts, Cards, and Cash.
- **Brand Logo Badges & Color Swatches**: Authentic presets for **GCash**, **Maya**, **BPI**, **BDO**, **Wise**, **GoTyme**, **SeaBank**, **PayPal**, **UnionBank**, and **Cash**.
- **Custom Subtitles & Categories**: Add personal subtitles like *"Emergency Fund"* or *"Salary Savings"*.
- **Default Cash Selection**: Configured to launch with Cash wallet selected as default.

### 📱 2. Dashboard & Quick Actions
- **Instant Balance Counter**: Dynamic numerical count-up animations for wallet balances.
- **Swipe Gestures**:
  - **Swipe Left** → Delete transaction (with instant Undo snackbar).
  - **Swipe Right** → Edit transaction details.
- **Fast Transaction Logging**:
  - Green **+ Income** and Crimson Red **− Expense** buttons.
  - Custom category picker (Food 🍔, Commute 🚌, Bills 📄, Shopping 🛍️, Others 📦).
  - **Change Calculator Mode**: Enter cash given and cash returned to auto-compute spent amounts.
- **Search & Filters**: Instant search by remarks or filter by wallet.

### 📊 3. Interactive Analytics & Calendar Filters
- **Calendar Filter Bar**:
  - Filter spending by **All Time**, **Today**, **This Month**, or select **Specific Days** and **Custom Date Ranges** via the interactive calendar picker.
- **Chart Toggle**: Switch between **Interactive Doughnut Charts** (with slice touch feedback and center totals) and **Bar Charts**.
- **Category Progress Cards**: Detailed percentage breakdowns with category progress bars.

### 🎨 4. Dynamic Visual Theme & Motion Design
- **Ambient Floating Particles**: GPU-accelerated background particles flowing gently across screens.
- **Staggered Animations**: Smooth fade and slide-up entrance transitions for cards and lists.
- **Multiple Color Themes**: Emerald Green, Dark Slate, Sapphire Blue, Sunset Gold, and Midnight Purple.
- **Dark Mode**: 1-tap Dark Mode switch with full contrast support.

### ❓ 5. Help & User Guide Modal
- **Tabbed Interactive User Guide**:
  - **Gestures & Spends**: Swipe gesture instructions & transaction entry guides.
  - **Wallets & Savings**: Presets, subtitles, and wallet category grouping.
  - **Analytics**: Calendar date range selection & chart controls.
  - **Data & Backup**: CSV / Excel backup guide and theme configuration.
- **System Safe Area Support**: Fits comfortably above soft Android navigation buttons (`= o <`).

### 🌐 6. Multi-language & Regional Settings
- **7 Languages Supported**: English, Japanese (日本語), Chinese (中文), French (Français), Spanish (Español), German (Deutsch), and Portuguese (Português).
- **Multi-Currency Region Presets**: Instant formatting for **₱ PHP**, **$ USD**, **€ EUR**, **¥ JPY**, **£ GBP**, **₹ INR**, and more.
- **Data Import / Export**:
  - Export all transaction logs to **CSV** or **Excel (.xlsx)**.
  - Restore or import transactions from backup files safely.

---

## 🛠️ Tech Stack

| Layer | Choice | Notes |
|---|---|---|
| **Framework** | Flutter 3.27+ | Cross-platform (Android, iOS, Windows, Desktop) |
| **Database** | SQLite (`sqflite`) | Fully offline storage with v3 migration logic |
| **State Management** | Provider | Reactive state for transactions, wallets, and settings |
| **Charts** | `fl_chart` | Interactive pie & bar charts |
| **Localization** | `flutter_localizations` & `intl` | ARB-based 7-language l10n with `flutter gen-l10n` |
| **Export / Import** | `csv` & `excel` | Native .csv and .xlsx parsing & generation |
| **Animations** | Custom Shaders / CurvedAnimation | Ambient particles, count-ups, staggered entrance |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0.0)
- Android Studio / VS Code with Flutter extensions

### Run the App

```bash
# Clone the repository
git clone https://github.com/Nazonokage/Wallet-Tracker.git
cd Wallet-Tracker

# Install dependencies and generate l10n files
flutter pub get
flutter gen-l10n

# Run the app
flutter run
```

---

## 📂 Project Structure

```
lib/
├── db/                 # SQLite Database helper & migrations
├── l10n/               # ARB translation files (en, ja, zh, es, fr, de, pt)
├── models/             # Transaction, Wallet, and WalletPreset models
├── providers/          # TransactionProvider, WalletProvider, SettingsProvider
├── screens/            # DashboardScreen, WalletsScreen, AnalyticsScreen, SettingsScreen
├── utils/              # ImportExportHelper (CSV & XLSX) and Formatter
├── widgets/            # HelpGuideModal, ParticleBackground, AnimatedCountText,
│                       # FadeInSlide, WalletLogoWidget, ExpenseModal, IncomeModal
└── main.dart
```

---

## 📄 License

This project is open-source. Feel free to use, customize, and build upon it!

---

Made with ❤️ using Flutter
