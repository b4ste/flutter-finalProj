enum TransactionType { income, expense }

enum BudgetPeriod { weekly, monthly }

class CalculationRecord {
  CalculationRecord({
    required this.id,
    required this.expression,
    required this.result,
    required this.createdAt,
    this.note = '',
  });
  final int id;
  final String expression;
  final double result;
  final DateTime createdAt;
  String note;
}

class MoneyTransaction {
  MoneyTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });
  final int id;
  TransactionType type;
  double amount;
  String category;
  String description;
  DateTime date;
}

class BudgetLimit {
  BudgetLimit({
    required this.id,
    required this.name,
    required this.category,
    required this.limit,
    required this.period,
  });
  final int id;
  String name;
  String? category; // null means all expense categories.
  double limit;
  BudgetPeriod period;
}

class SavingsGoal {
  SavingsGoal({
    required this.id,
    required this.name,
    required this.target,
    required this.saved,
  });
  final int id;
  String name;
  double target;
  double saved;
}
