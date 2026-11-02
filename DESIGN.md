# Wallet Tracker UI

Version 2.1 (`2.1.0+9`). Navigation: Wallets, Dashboard, Analytics, Settings.
Dashboard opens by default. Debts is reached from its neutral outlined dashboard
action or the debt card in Wallets; IOU opens the entry form below the balance.

The app is a compact personal ledger: identify the wallet, read the balance, record
money movement, and inspect history. Debt principal stays visually and financially
separate from spendable balances. Existing region, currency and theme choices stay.

## Shared system

- Keep the platform font. Titles use 24px bold; record names use 16px; supporting
  text uses the Material body scale. Amounts take precedence over decorative labels.
- Mint seed: #00897B. The other user-selectable seeds remain sunset #F57C00,
  ocean #1976D2, lavender #7B1FA2, and rose #E91E63. Surfaces, outlines and text
  derive from ColorScheme in both brightness modes; avoid fixed light text on
  generated light surfaces.
- Use 8/12/16/20 spacing. Inputs, chips and buttons use 12px corners; neutral cards
  use 16px; wallet cards and sheets use 20px. Tap targets are at least 48px where
  controls permit; text and amounts may wrap rather than clip.
- Quiet flat surfaces carry ordinary content. Wallet colors identify wallets.
  Debts uses the same neutral outlined action style as Add wallet. Filled chip
  backgrounds identify the selected wallet only; the handshake identifies Debts.
- Dashboard history begins with a lighter row. No decorative entrance effects,
  particles, gradients, glows or new animation dependencies.

## Screen decisions

- Dashboard: one horizontal wallet-choice strip, balance, IOU shortcut, search,
  lazy history and income/expense buttons. Debts opens the full debt screen.
- Wallets: real-wallet cards followed by a debt card. Receivables and Payables
  are explicit outlined buttons with amounts and directional navigation.
- Debts: people and amounts are primary, status filters remain visible, repayment
  history opens on demand. Existing light/dark and small-screen behavior is kept.
- Analytics: existing charts, period choices and totals inherit shared controls;
  Today remains the default and charts do not animate.
- Settings: selectors sit below their labels and expand within the available
  width. Help, backup and destructive actions retain their existing confirmations.
- Forms and details: consistent input surfaces and dialog/sheet shapes, existing
  keyboard focus and scrolling, and localised labels.

## Validation

Existing 29 tests passed after the shared-theme and debt-button changes. Two added
320px tests exercise Dashboard and Settings in light and dark mode; rendered
Settings captures are under ignored build/ui-review. Widget-test captures use test
fonts, so they verify geometry and colors rather than final device typography.
On-phone review remains necessary; Android builds in the agent environment have
previously been blocked by Gradle's loopback connection error.
