import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/wallets_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/wallet_provider.dart';
import 'providers/debt_provider.dart';
import 'screens/debts_screen.dart';
import 'widgets/help_guide_modal.dart';
import 'utils/first_run_guide.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = SettingsProvider();
  final transactions = TransactionProvider();
  final wallets = WalletProvider();
  // Start independent disk reads together, before rendering the first frame.
  // Only preferences block runApp, so the saved theme never flashes incorrectly.
  final preferencesReady = settings.loadSettings();
  final dataReady = Future.wait([
    transactions.loadTransactions(),
    wallets.loadWallets(),
  ]);
  await preferencesReady;
  runApp(
    MyApp(
      settings: settings,
      transactions: transactions,
      wallets: wallets,
      dataReady: dataReady,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SettingsProvider? settings;
  final TransactionProvider? transactions;
  final WalletProvider? wallets;
  final Future<void>? dataReady;
  const MyApp({
    super.key,
    this.settings,
    this.transactions,
    this.wallets,
    this.dataReady,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => transactions ?? TransactionProvider(),
        ),
        ChangeNotifierProvider(create: (_) => settings ?? SettingsProvider()),
        ChangeNotifierProvider(create: (_) => DebtProvider()),
        ChangeNotifierProvider(create: (_) => wallets ?? WalletProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Wallet Tracker',
            theme: _buildTheme(settings.currentTheme, settings.isDarkMode),
            locale: settings.locale,
            supportedLocales: SettingsProvider.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: MainScreen(dataReady: dataReady),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(AppTheme theme, bool isDark) {
    Color seed;
    switch (theme) {
      case AppTheme.mint:
        seed = const Color(0xFF00897B); // Emerald Mint
        break;
      case AppTheme.sunset:
        seed = const Color(0xFFF57C00); // Amber Sunset
        break;
      case AppTheme.ocean:
        seed = const Color(0xFF1976D2); // Ocean Blue
        break;
      case AppTheme.lavender:
        seed = const Color(0xFF7B1FA2); // Royal Lavender
        break;
      case AppTheme.rose:
        seed = const Color(0xFFE91E63); // Rose Pink
        break;
    }

    final brightness = isDark ? Brightness.dark : Brightness.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final Future<void>? dataReady;
  const MainScreen({super.key, this.dataReady});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  DebtDirectionFilter? _debtFilter;
  bool _wasBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await (widget.dataReady ??
          Future.wait([
            context.read<TransactionProvider>().loadTransactions(),
            context.read<WalletProvider>().loadWallets(),
          ]));
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      await FirstRunGuide.showOnce(prefs, () => HelpGuideModal.show(context));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _wasBackgrounded = true;
    if (state == AppLifecycleState.resumed && _wasBackgrounded) {
      _wasBackgrounded = false;
      context.read<TransactionProvider>().loadTransactions();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _navigateToDashboardWithWallet(int? walletId) {
    context.read<WalletProvider>().selectWallet(walletId);
    context.read<TransactionProvider>().walletFilter = walletId;
    setState(() => _selectedIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final List<Widget> screens = [
      const DashboardScreen(),
      WalletsScreen(
        onWalletSelected: _navigateToDashboardWithWallet,
        onDebtSelected: (filter) {
          setState(() {
            _debtFilter = filter;
            _selectedIndex = 2;
          });
        },
      ),
      DebtsScreen(directionFilter: _debtFilter),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            label: l10n.walletsAndSavings,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.handshake_outlined),
            label: l10n.debts,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.pie_chart),
            label: l10n.analytics,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() {
          _selectedIndex = index;
          _debtFilter = null;
        }),
      ),
    );
  }
}
