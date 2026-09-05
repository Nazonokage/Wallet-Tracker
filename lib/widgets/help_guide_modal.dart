import 'package:flutter/material.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';

class HelpGuideModal extends StatefulWidget {
  const HelpGuideModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const HelpGuideModal(),
    );
  }

  @override
  State<HelpGuideModal> createState() => _HelpGuideModalState();
}

class _HelpGuideModalState extends State<HelpGuideModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final l10n = AppLocalizations.of(context);

    return Container(
      height: size.height * 0.78,
      padding: EdgeInsets.only(bottom: bottomPadding + 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle & Header
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.helpAndUserGuide,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.helpSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
            tabs: [
              const Tab(icon: Icon(Icons.swipe_outlined, size: 20), text: 'Gestures & Spends'),
              Tab(icon: const Icon(Icons.account_balance_wallet_outlined, size: 20), text: l10n.walletsAndSavings),
              Tab(icon: const Icon(Icons.analytics_outlined, size: 20), text: l10n.analytics),
              Tab(icon: const Icon(Icons.settings_suggest_outlined, size: 20), text: '${l10n.settings} & Themes'),
            ],
          ),

          const Divider(height: 1),

          // Tab View Body
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGesturesTab(theme),
                _buildWalletsTab(theme),
                _buildAnalyticsTab(theme),
                _buildDataThemesTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- GESTURES & SPENDS TAB ----------------
  Widget _buildGesturesTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader(
          theme,
          icon: Icons.touch_app_rounded,
          title: 'Quick Gestures',
          color: Colors.orange,
        ),
        const SizedBox(height: 12),

        // Swipe Left to Delete Card
        _buildGuideCard(
          theme,
          leadingIcon: Icons.swipe_left_rounded,
          iconColor: Colors.redAccent,
          title: 'Swipe Left to Delete',
          description:
              'Swipe any transaction card from right to left to immediately delete it.',
          badge: 'Swipe Gesture',
          badgeColor: Colors.redAccent.withValues(alpha: 0.15),
        ),

        const SizedBox(height: 12),

        // Swipe Right to Edit Card
        _buildGuideCard(
          theme,
          leadingIcon: Icons.swipe_right_rounded,
          iconColor: Colors.blueAccent,
          title: 'Swipe Right to Edit',
          description:
              'Swipe any transaction card from left to right to open the edit modal and adjust amount, date, or category.',
          badge: 'Swipe Gesture',
          badgeColor: Colors.blueAccent.withValues(alpha: 0.15),
        ),

        const SizedBox(height: 20),

        _buildSectionHeader(
          theme,
          icon: Icons.add_circle_outline_rounded,
          title: 'Adding Income & Expenses',
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),

        _buildGuideCard(
          theme,
          leadingIcon: Icons.arrow_upward_rounded,
          iconColor: Colors.green,
          title: 'Logging Income',
          description:
              'Tap the green + Income button on the dashboard. Income adds funds to your selected active wallet.',
        ),

        const SizedBox(height: 12),

        _buildGuideCard(
          theme,
          leadingIcon: Icons.arrow_downward_rounded,
          iconColor: const Color(0xFFD32F2F),
          title: 'Logging Expense',
          description:
              'Tap the red - Expense button. Spends feature custom category picking and full numeric keypads.',
        ),
      ],
    );
  }

  // ---------------- WALLETS TAB ----------------
  Widget _buildWalletsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader(
          theme,
          icon: Icons.account_balance_wallet_rounded,
          title: 'Custom Wallets & Presets',
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),

        _buildGuideCard(
          theme,
          leadingIcon: Icons.wallet_giftcard_rounded,
          iconColor: Colors.deepPurpleAccent,
          title: 'Brand Logos & Presets',
          description:
              'Easily add GCash, Maya, BPI, BDO, Wise, GoTyme, SeaBank, PayPal, UnionBank, or Cash with authentic logos & color swatches.',
        ),

        const SizedBox(height: 12),

        _buildGuideCard(
          theme,
          leadingIcon: Icons.category_rounded,
          iconColor: Colors.teal,
          title: 'Categories & Subtitles',
          description:
              'Group your wallets into Savings, Digital Wallets, Bank Accounts, Cards, or Cash, and add personal subtitles like "Emergency Fund".',
        ),

        const SizedBox(height: 12),

        _buildGuideCard(
          theme,
          leadingIcon: Icons.star_rounded,
          iconColor: Colors.amber,
          title: 'Default Active Wallet',
          description:
              'Select any wallet from the top navbar. "Cash" is configured as default on app launch, or you can pick "All Wallets" for aggregate totals.',
        ),
      ],
    );
  }

  // ---------------- ANALYTICS TAB ----------------
  Widget _buildAnalyticsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader(
          theme,
          icon: Icons.pie_chart_rounded,
          title: 'Analytics & Calendar Filters',
          color: Colors.indigoAccent,
        ),
        const SizedBox(height: 12),

        _buildGuideCard(
          theme,
          leadingIcon: Icons.calendar_today_rounded,
          iconColor: Colors.orangeAccent,
          title: 'Calendar & Custom Dates',
          description:
              'Filter expenses by Today, This Month, All Time, or pick specific single days and custom date ranges using the built-in calendar picker.',
        ),

        const SizedBox(height: 12),

        _buildGuideCard(
          theme,
          leadingIcon: Icons.bar_chart_rounded,
          iconColor: theme.colorScheme.primary,
          title: 'Doughnut vs Bar Charts',
          description:
              'Tap the chart toggle button in the top bar to switch between interactive category doughnut slices and comparative bar charts.',
        ),

        const SizedBox(height: 12),

        _buildGuideCard(
          theme,
          leadingIcon: Icons.show_chart_rounded,
          iconColor: Colors.lightGreen,
          title: 'Category Breakdown Cards',
          description:
              'Inspect total spending and percentage progress bars per category (Food, Commute, Bills, Shopping, Others).',
        ),
      ],
    );
  }

  // ---------------- DATA & THEMES TAB ----------------
  Widget _buildDataThemesTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader(
          theme,
          icon: Icons.palette_rounded,
          title: 'Themes & Regional Settings',
          color: Colors.pinkAccent,
        ),
        const SizedBox(height: 12),

        _buildGuideCard(
          theme,
          leadingIcon: Icons.color_lens_rounded,
          iconColor: Colors.purple,
          title: 'App Color Themes & Dark Mode',
          description:
              'Choose between Emerald, Dark Slate, Sapphire, Sunset Gold, and Midnight Purple themes, and toggle Dark Mode anytime.',
        ),

        const SizedBox(height: 12),

        _buildGuideCard(
          theme,
          leadingIcon: Icons.language_rounded,
          iconColor: Colors.blue,
          title: 'Currency & Language Regions',
          description:
              'Switch region presets (₱ PHP, \$ USD, € EUR, ¥ JPY, etc.) to immediately customize your currency symbol and localization.',
        ),

        const SizedBox(height: 20),

        _buildSectionHeader(
          theme,
          icon: Icons.cloud_download_rounded,
          title: 'Data Backup & Import/Export',
          color: Colors.teal,
        ),
        const SizedBox(height: 12),

        _buildGuideCard(
          theme,
          leadingIcon: Icons.upload_file_rounded,
          iconColor: Colors.green,
          title: 'Export to CSV or Excel',
          description:
              'Export all transaction logs and wallet metadata into native .csv or .xlsx formats for backup or Google Sheets editing.',
        ),

        const SizedBox(height: 12),

        _buildGuideCard(
          theme,
          leadingIcon: Icons.download_rounded,
          iconColor: Colors.amber.shade800,
          title: 'Import CSV or Excel Files',
          description:
              'Restore or import transaction logs safely from previous backups with 1-tap parsing.',
        ),
      ],
    );
  }

  // ---------------- HELPER WIDGETS ----------------
  Widget _buildSectionHeader(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildGuideCard(
    ThemeData theme, {
    required IconData leadingIcon,
    required Color iconColor,
    required String title,
    required String description,
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(leadingIcon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor ?? theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
