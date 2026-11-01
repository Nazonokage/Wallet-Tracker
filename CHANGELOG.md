# Changelog

## v1.9 — 2026-11-02

App version: `1.9.0+7`.

### Added

- Debts tab for money lent and borrowed, optional flat interest, partial repayments,
  repayment history, and automatic archiving when fully paid.
- Receivables and Payables summaries in Wallets, plus a dashboard IOU shortcut.
- First-launch Help & User Guide, also available from Settings.
- Tap a transaction to see its timestamp and details, with Edit/Delete actions.
  Debt-managed records open their debt to protect linked repayment history.
- This week analytics filter, with Today selected by default.
- Complete CSV/Excel backups covering wallets, starting balances, transactions,
  debts, repayments and contacts. Legacy transaction-only backups remain supported.

### Changed

- Alternating record row colors and automatic numeric keyboard focus for new
  income/expense entries; improved forms on narrow screens with the keyboard open.
- Removed decorative motion and chart transitions.
- Paginated dashboard history and debt lists, SQL-based totals, lazy analytics,
  debounced search, and background backup encoding/decoding.
- Concurrent startup reads, reusable immutable list snapshots, cached number
  formatters, and fewer reloads during brief focus changes.
- Updated sharing/file-picker dependencies and Android build configuration.

### Data safety

- Database upgrades retain existing records and roll back on failure. Older
  binaries refuse newer database schemas instead of resetting storage.
- Added a PowerShell update installer using `adb install -r`, with no automatic
  uninstall or data-clearing fallback after a build/signing failure.
- Added Android backup/device-transfer rules for app data and preferences.
  A new-device install still needs an available Android restore or manual import.
- Full imports are atomic and additive. Importing the same backup twice can create
  duplicates; existing data is not replaced automatically.
- Clear all data requires two confirmations and resets financial records and
  starting balances. Individual deletions remain explicit user actions.

### Validation and known limitations

- 29 automated tests pass; Flutter analysis reports no issues. Tests cover debt
  accounting, backups, migration rollback, data retention, pagination, startup,
  record interactions and small-screen keyboard layouts.
- Android release build and on-phone startup timings remain unverified: the agent
  environment encounters Gradle's `Unable to establish loopback connection` error,
  and no ADB device was attached during the latest check.
- Release signing still uses the existing developer debug key. Preserve the same
  key and application ID for updates; do not uninstall to resolve a mismatch.
- New debt strings still use English placeholders in non-English locales.
- Debt reminders, recurring entries and budget UI remain planned work.
