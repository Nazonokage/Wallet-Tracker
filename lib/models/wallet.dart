class Wallet {
  /// ✅ The original untracked balance always lives in this wallet, so
  /// existing data (and code) that doesn't know about wallets yet still
  /// works — it just all belongs to "Cash".
  static const int cashWalletId = 1;

  int? id;
  bool isSystem;
  String name;
  String icon; // emoji, e.g. '🏦', '💳'
  double initialBalance;
  DateTime createdAt;
  String
  category; // e.g. 'Bank Accounts', 'E-wallets', 'Savings & Investments', 'Cash', 'Other'
  int colorValue; // ARGB int, e.g. 0xFF1976D2
  String? subtitle; // e.g. 'Debit • PHP', '1.25% yearly'

  Wallet({
    this.id,
    this.isSystem = false,
    required this.name,
    this.icon = '👛',
    this.initialBalance = 0,
    DateTime? createdAt,
    this.category = 'Bank Accounts',
    this.colorValue = 0xFF1976D2,
    this.subtitle,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isDefault => id == cashWalletId;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'is_system': isSystem ? 1 : 0,
      'name': name,
      'icon': icon,
      'initialBalance': initialBalance,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'colorValue': colorValue,
      'subtitle': subtitle,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'],
      isSystem: map['is_system'] == 1,
      name: map['name'],
      icon: map['icon'] ?? '👛',
      initialBalance: (map['initialBalance'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      category: map['category'] ?? 'Bank Accounts',
      colorValue: map['colorValue'] != null
          ? (map['colorValue'] as int)
          : 0xFF1976D2,
      subtitle: map['subtitle'],
    );
  }
}
