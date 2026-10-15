import 'package:flutter_test/flutter_test.dart';
import 'package:finalproject/models/records.dart';
import 'package:finalproject/state/app_state.dart';

void main() {
  test(
    'transactions update totals and budget spending by category and period',
    () {
      final state = AppState();
      final now = DateTime(2026, 10, 15);
      state.saveBudget(
        name: 'Food monthly',
        category: 'Food',
        limit: 100,
        period: BudgetPeriod.monthly,
      );
      state.saveTransaction(
        type: TransactionType.income,
        amount: 500,
        category: 'Salary',
        description: 'Pay',
        date: now,
      );
      state.saveTransaction(
        type: TransactionType.expense,
        amount: 60,
        category: 'Food',
        description: 'Lunch',
        date: now,
      );
      state.saveTransaction(
        type: TransactionType.expense,
        amount: 40,
        category: 'Food',
        description: 'Old lunch',
        date: DateTime(2026, 9, 30),
      );
      expect(state.income, 500);
      expect(state.expenses, 100);
      expect(state.balance, 400);
      expect(state.spentFor(state.budgets.single, now: now), 60);
      final id = state.transactions
          .firstWhere((r) => r.description == 'Lunch')
          .id;
      state.saveTransaction(
        id: id,
        type: TransactionType.expense,
        amount: 80,
        category: 'Food',
        description: 'Dinner',
        date: now,
      );
      expect(state.spentFor(state.budgets.single, now: now), 80);
      state.deleteTransaction(id);
      expect(state.expenses, 40);
    },
  );

  test('history, budgets and goals update and delete correct records', () {
    final state = AppState();
    state.addCalculation('2+2', 4);
    state.addCalculation('3+3', 6);
    final first = state.calculations.last;
    state.updateCalculation(first.id, 'Two plus two');
    expect(first.note, 'Two plus two');
    expect(state.calculations.first.note, '');
    state.deleteCalculation(first.id);
    expect(state.calculations.single.expression, '3+3');

    state.saveBudget(
      name: 'Overall',
      category: null,
      limit: 1000,
      period: BudgetPeriod.weekly,
    );
    final budgetId = state.budgets.single.id;
    state.saveBudget(
      id: budgetId,
      name: 'Food',
      category: 'Food',
      limit: 200,
      period: BudgetPeriod.monthly,
    );
    expect(state.budgets.single.limit, 200);
    state.deleteBudget(budgetId);
    expect(state.budgets, isEmpty);

    state.saveGoal(name: 'Laptop', target: 1000, saved: 200);
    final goalId = state.goals.single.id;
    state.saveGoal(id: goalId, name: 'Laptop', target: 1000, saved: 1000);
    expect(state.goals.single.saved, 1000);
    state.deleteGoal(goalId);
    expect(state.goals, isEmpty);
  });
}
