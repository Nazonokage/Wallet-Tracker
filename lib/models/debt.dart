int toMinor(double value) {
  if (!value.isFinite || value < 0) throw ArgumentError.value(value);
  return (value * 100).round();
}

enum DebtDirection { lent, borrowed }

enum DebtStatus { outstanding, partial, archived }

class Debt {
  final int? id;
  final String personName;
  final DebtDirection direction;
  final int principalMinor;
  final double interestRate;
  final int totalDueMinor;
  final int remainingMinor;
  final int principalPaidMinor;
  final DateTime? dueDate;
  final String? note;
  final int walletId;
  final DateTime createdAt;
  final DebtStatus status;

  const Debt({
    this.id,
    required this.personName,
    required this.direction,
    required this.principalMinor,
    this.interestRate = 0,
    required this.totalDueMinor,
    required this.remainingMinor,
    this.principalPaidMinor = 0,
    this.dueDate,
    this.note,
    required this.walletId,
    required this.createdAt,
    this.status = DebtStatus.outstanding,
  });

  static int totalDue(int principal, double rate) {
    if (principal <= 0 || !rate.isFinite || rate < 0) {
      throw ArgumentError('Invalid debt');
    }
    return principal + (principal * rate / 100).round();
  }

  double get remaining => remainingMinor / 100;
  double get principal => principalMinor / 100;
  bool get active => status != DebtStatus.archived;
  int overdueDays(DateTime now) => dueDate == null || !active
      ? 0
      : DateTime(now.year, now.month, now.day)
            .difference(DateTime(dueDate!.year, dueDate!.month, dueDate!.day))
            .inDays;

  ({int principal, int interest}) splitRepayment(int amount) {
    if (!active || amount <= 0 || amount > remainingMinor) {
      throw ArgumentError('Invalid repayment');
    }
    final outstandingPrincipal = principalMinor - principalPaidMinor;
    final principal = amount < outstandingPrincipal
        ? amount
        : outstandingPrincipal;
    return (principal: principal, interest: amount - principal);
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'person_name': personName.trim(),
    'direction': direction.name,
    'principal_minor': principalMinor,
    'interest_rate': interestRate,
    'total_due_minor': totalDueMinor,
    'remaining_minor': remainingMinor,
    'principal_paid_minor': principalPaidMinor,
    'due_date': dueDate?.toIso8601String(),
    'note': note,
    'wallet_id': walletId,
    'created_at': createdAt.toIso8601String(),
    'status': status.name,
  };
  factory Debt.fromMap(Map<String, Object?> m) => Debt(
    id: m['id'] as int,
    personName: m['person_name'] as String,
    direction: DebtDirection.values.byName(m['direction'] as String),
    principalMinor: m['principal_minor'] as int,
    interestRate: (m['interest_rate'] as num).toDouble(),
    totalDueMinor: m['total_due_minor'] as int,
    remainingMinor: m['remaining_minor'] as int,
    principalPaidMinor: m['principal_paid_minor'] as int,
    dueDate: m['due_date'] == null
        ? null
        : DateTime.parse(m['due_date'] as String),
    note: m['note'] as String?,
    walletId: m['wallet_id'] as int,
    createdAt: DateTime.parse(m['created_at'] as String),
    status: DebtStatus.values.byName(m['status'] as String),
  );
}

class DebtRepayment {
  final int id, debtId, amountMinor;
  final DateTime date;
  final String? note;
  const DebtRepayment({
    required this.id,
    required this.debtId,
    required this.amountMinor,
    required this.date,
    this.note,
  });
  double get amount => amountMinor / 100;
  factory DebtRepayment.fromMap(Map<String, Object?> m) => DebtRepayment(
    id: m['id'] as int,
    debtId: m['debt_id'] as int,
    amountMinor: m['amount_minor'] as int,
    date: DateTime.parse(m['date'] as String),
    note: m['note'] as String?,
  );
}

class Contact {
  final int id;
  final String name;
  final DateTime? lastUsed;
  const Contact(this.id, this.name, this.lastUsed);
}

class Budget {
  final int category, limitMinor;
  const Budget(this.category, this.limitMinor);
  double get limit => limitMinor / 100;
}
