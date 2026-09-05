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

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
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
            home: const MainScreen(),
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
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

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
      WalletsScreen(onWalletSelected: _navigateToDashboardWithWallet),
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallets',
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
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
