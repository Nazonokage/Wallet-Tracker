class Wallet {
  /// ✅ The original untracked balance always lives in this wallet, so
  /// existing data (and code) that doesn't know about wallets yet still
  /// works — it just all belongs to "Cash".
  static const int cashWalletId = 1;

  int? id;
  String name;
  String icon; // emoji, e.g. '🏦', '💳'
  double initialBalance;
  DateTime createdAt;

  Wallet({
    this.id,
    required this.name,
    this.icon = '👛',
    this.initialBalance = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isDefault => id == cashWalletId;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'initialBalance': initialBalance,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'],
      name: map['name'],
      icon: map['icon'] ?? '👛',
      initialBalance: (map['initialBalance'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
