# Wallet Tracker (v1.9)

See [CHANGELOG.md](CHANGELOG.md) for changes and known limitations.

A fast, customizable, offline-first personal expense and savings tracker built with Flutter.

**Core promise:** Log transactions in seconds, manage customizable wallets with brand logos, view interactive analytics with calendar pickers, and see balances and lists immediately.

No cloud sync. No accounts. No ads. Just pure speed, privacy, and full visibility over your money.

---

## 🌟 Key Features

### 💳 1. Customizable Wallets & Savings
- **1-Column Customizable Wallet Cards**: Grouped into Savings, Digital Wallets, Bank Accounts, Cards, and Cash.
- **Brand Logo Badges & Color Swatches**: Authentic presets for **GCash**, **Maya**, **BPI**, **BDO**, **Wise**, **GoTyme**, **SeaBank**, **PayPal**, **UnionBank**, and **Cash**.
- **Custom Subtitles & Categories**: Add personal subtitles like *"Emergency Fund"* or *"Salary Savings"*.
- **Default Cash Selection**: Configured to launch with Cash wallet selected as default.

### 📱 2. Dashboard & Quick Actions
- **Instant Balance Counter**: Wallet balances display immediately without count-up animations.
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
- **Static Backgrounds**: No decorative particle animation or background tickers.
- **Immediate Content**: Cards and lists appear without entrance fades, slides, or delays.
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
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.38.1; this project is checked with Flutter 3.44.4 stable)
- Android Studio / VS Code with Flutter extensions

### Run the App

```bash
# Clone the repository
git clone https://github.com/Nazonokage/Wallet-Tracker.git
cd Wallet-Tracker

# Install dependencies and generate l10n files
flutter pub get
flutter gen-l10n

# Install an Android update while retaining existing app data (PowerShell)
.\scripts\install-android.ps1
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

## Windows build setup

If package resolution fails under a Windows profile containing spaces or apostrophes,
set the user environment variable `PUB_CACHE` to a plain path such as `C:\pub_cache`.
Restart terminals and the IDE, then run `flutter clean` and `flutter pub get`.
Keep machine-specific cache paths out of the repository. Inspect the first build
error before assuming the cache path is responsible.



## Debts and first-install help

The Debts tab records lent and borrowed money, optional flat interest, and partial
repayments. Principal movements change the selected real wallet and stay out of
income/expense analytics; interest counts normally. Fully paid debts archive
automatically. Receivables and Payables show active balances in Wallets.
The Help & User Guide opens once on the first launch and is available in Settings.

The dashboard reads 50 transactions at a time, with SQL-based wallet and weekly
totals. Analytics reads category totals on demand. Decorative motion stays disabled.
CSV and Excel exports contain a complete versioned backup, including starting
balances, debts and repayments. Import adds data; importing twice creates duplicates.
Existing transaction-only backups remain accepted. Due-date notifications are pending.
New debt translations currently use English placeholders outside English.


## Keep data when updating or moving phones

Updates use the existing SQLite file and additive versioned migrations. Startup,
analytics filters, and APK installation do not call Clear all data. Only the
explicit Settings reset, after two confirmations, clears the financial database;
individual Delete actions still require the confirmations described in the guide.

For Android development updates, use the PowerShell installer above. It builds an
APK and uses adb install -r, stops on a signing mismatch, and never uninstalls or
clears app storage. Keep the package ID and signing key unchanged between releases.
The current project still uses the developer debug signing key for release builds;
keep that key safe and consistent until a planned signing migration. Flutter run
may offer to uninstall an incompatible installed package; do not use that fallback
to resolve a signing mismatch if you need to keep the app's local data.

Android cloud backup and device-to-device transfer explicitly include app_flutter
(the database plus WAL sidecars) and preferences. Restoration depends on Android's
backup settings, available backup, transport limits, and matching application identity.
Installing an APK on a different phone alone does not transfer data. Export CSV or
Excel in Settings, save the backup outside app storage, copy it to the new phone,
and use Import Data there if Android restore is unavailable. Import adds records;
importing twice creates duplicates. Uninstalling or clearing storage in Android can
remove local data independently of the app, so keep an exported backup.

Analytics opens with Today selected; This week uses Monday through Sunday.

## Startup performance testing

Preferences and wallet/history reads start concurrently. Rendering waits only for
saved preferences, preserving the selected theme, while database results can arrive
after the first frame. Records stay paginated and other tabs load on demand.

For everyday phone use, build/install the optimized APK from PowerShell:

```powershell
.\scripts\install-android.ps1 -Release
```

This retains the same application ID/signing configuration and uses install -r.
If installation is rejected, stop and preserve the installed app; never uninstall
as a workaround. Compare launching from the phone icon with comparable saved data.
Gradle build duration is separate from app startup. Phone timings for the latest
changes remain pending: the agent environment currently hits a Gradle loopback
connection failure and has no attached ADB device.
