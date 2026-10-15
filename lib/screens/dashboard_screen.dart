import 'package:flutter/material.dart';
import '../models/records.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.state,
    required this.onOpenTransactions,
  });
  final AppState state;
  final VoidCallback onOpenTransactions;

  @override
  Widget build(BuildContext context) {
    final recent = [...state.transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    final monthly = state.budgets
        .where((b) => b.category == null && b.period == BudgetPeriod.monthly)
        .toList();
    final budget = monthly.isEmpty ? null : monthly.first;
    final spent = budget == null ? 0.0 : state.spentFor(budget);
    final saved = state.goals.fold<double>(0, (sum, goal) => sum + goal.saved);
    final target = state.goals.fold<double>(
      0,
      (sum, goal) => sum + goal.target,
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Your money at a glance',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Remaining balance'),
                const SizedBox(height: 8),
                Text(
                  money(state.balance),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _stat(
                        'Total income',
                        state.income,
                        Icons.arrow_downward,
                        Colors.tealAccent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _stat(
                        'Total expenses',
                        state.expenses,
                        Icons.arrow_upward,
                        Colors.orangeAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly spending plan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(height: 8),
                if (budget == null)
                  const Text(
                    'Create an overall monthly budget in Plans to track utilization.',
                  )
                else ...[
                  Text('${money(spent)} of ${money(budget.limit)} spent'),
                  const SizedBox(height: 8),
                  progress(
                    spent / budget.limit,
                    warning: spent >= budget.limit,
                  ),
                  if (spent >= budget.limit)
                    const Text(
                      'Budget limit reached',
                      style: TextStyle(color: Colors.orangeAccent),
                    ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Savings goals',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(height: 8),
                if (state.goals.isEmpty)
                  const Text('Add a savings goal in Plans to track progress.')
                else ...[
                  Text('${money(saved)} of ${money(target)} saved'),
                  const SizedBox(height: 8),
                  progress(saved / target),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recent transactions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: onOpenTransactions,
              child: const Text('View all'),
            ),
          ],
        ),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('No transactions yet. Add one to see your activity.'),
          ),
        for (final r in recent.take(5))
          Card(
            child: ListTile(
              leading: Icon(
                r.type == TransactionType.income
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
              ),
              title: Text(r.description),
              subtitle: Text('${r.category} • ${shortDate(r.date)}'),
              trailing: Text(
                '${r.type == TransactionType.income ? '+' : '−'}${money(r.amount)}',
              ),
            ),
          ),
      ],
    );
  }

  Widget _stat(String label, double amount, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
            FittedBox(
              child: Text(
                money(amount),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      );
}
