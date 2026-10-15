import 'package:flutter/foundation.dart';
import '../models/records.dart';

class AppState extends ChangeNotifier {
  int _nextId = 1;
  final calculations = <CalculationRecord>[];
  final transactions = <MoneyTransaction>[];
  final budgets = <BudgetLimit>[];
  final goals = <SavingsGoal>[];
  bool degrees = true;
  double memory = 0;

  int _id() => _nextId++;

  void setDegrees(bool value) {
    degrees = value;
    notifyListeners();
  }

  void setMemory(double value) {
    memory = value;
    notifyListeners();
  }

  void addCalculation(String expression, double result) {
    calculations.insert(
      0,
      CalculationRecord(
        id: _id(),
        expression: expression,
        result: result,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void updateCalculation(int id, String note) {
    calculations.firstWhere((r) => r.id == id).note = note;
    notifyListeners();
  }

  void deleteCalculation(int id) {
    calculations.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void saveTransaction({
    int? id,
    required TransactionType type,
    required double amount,
    required String category,
    required String description,
    required DateTime date,
  }) {
    if (!amount.isFinite ||
        amount <= 0 ||
        category.trim().isEmpty ||
        description.trim().isEmpty) {
      throw ArgumentError('Invalid transaction');
    }
    if (id == null) {
      transactions.insert(
        0,
        MoneyTransaction(
          id: _id(),
          type: type,
          amount: amount,
          category: category,
          description: description.trim(),
          date: date,
        ),
      );
    } else {
      final record = transactions.firstWhere((r) => r.id == id);
      record.type = type;
      record.amount = amount;
      record.category = category;
      record.description = description.trim();
      record.date = date;
    }
    notifyListeners();
  }

  void deleteTransaction(int id) {
    transactions.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void saveBudget({
    int? id,
    required String name,
    required String? category,
    required double limit,
    required BudgetPeriod period,
  }) {
    if (name.trim().isEmpty || !limit.isFinite || limit <= 0) {
      throw ArgumentError('Invalid budget');
    }
    if (id == null) {
      budgets.add(
        BudgetLimit(
          id: _id(),
          name: name.trim(),
          category: category,
          limit: limit,
          period: period,
        ),
      );
    } else {
      final record = budgets.firstWhere((r) => r.id == id);
      record.name = name.trim();
      record.category = category;
      record.limit = limit;
      record.period = period;
    }
    notifyListeners();
  }

  void deleteBudget(int id) {
    budgets.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void saveGoal({
    int? id,
    required String name,
    required double target,
    required double saved,
  }) {
    if (name.trim().isEmpty ||
        !target.isFinite ||
        target <= 0 ||
        !saved.isFinite ||
        saved < 0) {
      throw ArgumentError('Invalid goal');
    }
    if (id == null) {
      goals.add(
        SavingsGoal(id: _id(), name: name.trim(), target: target, saved: saved),
      );
    } else {
      final record = goals.firstWhere((r) => r.id == id);
      record.name = name.trim();
      record.target = target;
      record.saved = saved;
    }
    notifyListeners();
  }

  void deleteGoal(int id) {
    goals.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  double get income => transactions
      .where((r) => r.type == TransactionType.income)
      .fold(0, (sum, r) => sum + r.amount);
  double get expenses => transactions
      .where((r) => r.type == TransactionType.expense)
      .fold(0, (sum, r) => sum + r.amount);
  double get balance => income - expenses;

  double spentFor(BudgetLimit budget, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final start = budget.period == BudgetPeriod.weekly
        ? DateTime(
            today.year,
            today.month,
            today.day,
          ).subtract(Duration(days: today.weekday - 1))
        : DateTime(today.year, today.month);
    final end = budget.period == BudgetPeriod.weekly
        ? start.add(const Duration(days: 7))
        : DateTime(start.year, start.month + 1);
    return transactions
        .where(
          (r) =>
              r.type == TransactionType.expense &&
              (budget.category == null || budget.category == r.category) &&
              !r.date.isBefore(start) &&
              r.date.isBefore(end),
        )
        .fold(0, (sum, r) => sum + r.amount);
  }
}
