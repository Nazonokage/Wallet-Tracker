class WalletPreset {
  final String id;
  final String name;
  final String category; // 'E-wallets', 'Bank Accounts', 'Savings & Investments', 'Cash'
  final String icon;
  final int colorValue;
  final String defaultSubtitle;

  const WalletPreset({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.colorValue,
    required this.defaultSubtitle,
  });

  static const List<WalletPreset> presets = [
    WalletPreset(
      id: 'gcash',
      name: 'GCash',
      category: 'E-wallets',
      icon: '📱',
      colorValue: 0xFF007DFF, // Vibrant Blue
      defaultSubtitle: 'Debit • PHP',
    ),
    WalletPreset(
      id: 'maya',
      name: 'Maya',
      category: 'E-wallets',
      icon: '🟢',
      colorValue: 0xFF00D632, // Emerald Green
      defaultSubtitle: 'Debit • PHP',
    ),
    WalletPreset(
      id: 'bpi',
      name: 'BPI Savings',
      category: 'Bank Accounts',
      icon: '🏛️',
      colorValue: 0xFFD32F2F, // Vibrant Red
      defaultSubtitle: 'Debit • PHP • 1.25% yearly',
    ),
    WalletPreset(
      id: 'bdo',
      name: 'BDO',
      category: 'Bank Accounts',
      icon: '🏦',
      colorValue: 0xFF0B3C5D, // Deep Navy Blue
      defaultSubtitle: 'Debit • PHP',
    ),
    WalletPreset(
      id: 'wise',
      name: 'Wise USD',
      category: 'Bank Accounts',
      icon: '⚡',
      colorValue: 0xFF8EDE27, // Wise Bright Lime
      defaultSubtitle: 'Debit • USD',
    ),
    WalletPreset(
      id: 'gotyme',
      name: 'GoTyme Bank',
      category: 'Bank Accounts',
      icon: '💎',
      colorValue: 0xFF00B4D8, // Cyan Blue
      defaultSubtitle: 'Savings • 4.0% APY',
    ),
    WalletPreset(
      id: 'seabank',
      name: 'SeaBank',
      category: 'Bank Accounts',
      icon: '🌊',
      colorValue: 0xFFF57C00, // Vibrant Orange
      defaultSubtitle: 'Savings • 4.5% APY',
    ),
    WalletPreset(
      id: 'paypal',
      name: 'PayPal',
      category: 'E-wallets',
      icon: '💳',
      colorValue: 0xFF003087, // PayPal Blue
      defaultSubtitle: 'Debit • USD',
    ),
    WalletPreset(
      id: 'unionbank',
      name: 'UnionBank',
      category: 'Bank Accounts',
      icon: '🟠',
      colorValue: 0xFFE65100, // Deep Orange
      defaultSubtitle: 'Debit • PHP',
    ),
    WalletPreset(
      id: 'cash',
      name: 'Cash',
      category: 'Cash',
      icon: '💵',
      colorValue: 0xFF388E3C, // Cash Green
      defaultSubtitle: 'Physical Cash',
    ),
  ];
}
