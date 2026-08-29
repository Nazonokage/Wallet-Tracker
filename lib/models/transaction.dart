import 'wallet.dart';

enum Category { food, commute, bills, shopping, others }

enum TransactionType { income, expense }

class Transaction {
  int? id;
  TransactionType type;
  double amount;
  Category? category; // null for income
  String? remark;
  DateTime date;
  int walletId; // ✅ which wallet (Cash, BDO, GCash, ...) this belongs to

  Transaction({
    this.id,
    required this.type,
    required this.amount,
    this.category,
    this.remark,
    required this.date,
    this.walletId =
        Wallet.cashWalletId, // ✅ defaults to "Cash" for backward compatibility
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'amount': amount,
      'category': category?.index, // store enum index (0..4)
      'remark': remark,
      'date': date.toIso8601String(),
      'wallet_id': walletId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      amount: map['amount'].toDouble(),
      category:
          map['category'] != null ? Category.values[map['category']] : null,
      remark: map['remark'],
      date: DateTime.parse(map['date']),
      // ✅ Old rows created before this column existed fall back to Cash.
      walletId: map['wallet_id'] ?? Wallet.cashWalletId,
    );
  }

  // Helper to get emoji for category
  String get categoryEmoji {
    switch (category) {
      case Category.food:
        return '🍔';
      case Category.commute:
        return '🚌';
      case Category.bills:
        return '📄';
      case Category.shopping:
        return '🛍️';
      case Category.others:
        return '📦';
      default:
        return '📦';
    }
  }
}
