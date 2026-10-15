import 'package:flutter/material.dart';
import '../models/records.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'transactions_screen.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Spending limits',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton.filled(
            tooltip: 'Add budget',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => BudgetForm(state: state),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      const Text(
        'Weekly periods start Monday. Monthly periods start on the 1st.',
      ),
      const SizedBox(height: 8),
      if (state.budgets.isEmpty)
        const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No budgets yet. Add a limit to track expenses.'),
          ),
        ),
      for (final b in state.budgets) _budgetCard(context, b),
      const SizedBox(height: 18),
      Row(
        children: [
          const Expanded(
            child: Text(
              'Savings goals',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton.filled(
            tooltip: 'Add savings goal',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => GoalForm(state: state),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      const Text(
        'Saved amounts are tracking only and do not change your balance.',
      ),
      const SizedBox(height: 8),
      if (state.goals.isEmpty)
        const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('No savings goals yet. Add one to track progress.'),
          ),
        ),
      for (final goal in state.goals) _goalCard(context, goal),
    ],
  );

  Widget _budgetCard(BuildContext context, BudgetLimit b) {
    final spent = state.spentFor(b);
    final warning = spent >= b.limit;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    b.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit budget',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => BudgetForm(state: state, record: b),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete budget',
                  onPressed: () async {
                    if (await confirmDelete(context, 'budget')) {
                      state.deleteBudget(b.id);
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            Text(
              '${b.period.name.toUpperCase()} • ${b.category ?? 'All expenses'}',
            ),
            const SizedBox(height: 8),
            Text('${money(spent)} / ${money(b.limit)}'),
            const SizedBox(height: 8),
            progress(spent / b.limit, warning: warning),
            if (warning)
              const Text(
                'Limit reached or exceeded',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _goalCard(BuildContext context, SavingsGoal goal) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit savings goal',
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => GoalForm(state: state, record: goal),
                ),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete savings goal',
                onPressed: () async {
                  if (await confirmDelete(context, 'savings goal')) {
                    state.deleteGoal(goal.id);
                  }
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          Text('${money(goal.saved)} / ${money(goal.target)}'),
          const SizedBox(height: 8),
          progress(goal.saved / goal.target),
          if (goal.saved >= goal.target)
            const Text(
              'Goal reached!',
              style: TextStyle(
                color: Colors.tealAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    ),
  );
}

class BudgetForm extends StatefulWidget {
  const BudgetForm({super.key, required this.state, this.record});
  final AppState state;
  final BudgetLimit? record;
  @override
  State<BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final key = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController limit;
  late String? category;
  late BudgetPeriod period;
  @override
  void initState() {
    super.initState();
    final r = widget.record;
    name = TextEditingController(text: r?.name ?? '');
    limit = TextEditingController(text: r?.limit.toString() ?? '');
    category = r?.category;
    period = r?.period ?? BudgetPeriod.monthly;
  }

  @override
  void dispose() {
    name.dispose();
    limit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.record == null ? 'Add budget' : 'Edit budget'),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'Budget name'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: limit,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Spending limit (₱)',
                ),
                validator: (v) => positiveAmount(v ?? '') == null
                    ? 'Enter a limit greater than zero'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Scope'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Overall')),
                  for (final c in expenseCategories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => category = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<BudgetPeriod>(
                initialValue: period,
                decoration: const InputDecoration(labelText: 'Period'),
                items: const [
                  DropdownMenuItem(
                    value: BudgetPeriod.weekly,
                    child: Text('Weekly'),
                  ),
                  DropdownMenuItem(
                    value: BudgetPeriod.monthly,
                    child: Text('Monthly'),
                  ),
                ],
                onChanged: (v) => setState(() => period = v!),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!key.currentState!.validate()) return;
          widget.state.saveBudget(
            id: widget.record?.id,
            name: name.text,
            category: category,
            limit: positiveAmount(limit.text)!,
            period: period,
          );
          Navigator.pop(context);
        },
        child: const Text('Save'),
      ),
    ],
  );
}

class GoalForm extends StatefulWidget {
  const GoalForm({super.key, required this.state, this.record});
  final AppState state;
  final SavingsGoal? record;
  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final key = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController target;
  late final TextEditingController saved;
  @override
  void initState() {
    super.initState();
    final r = widget.record;
    name = TextEditingController(text: r?.name ?? '');
    target = TextEditingController(text: r?.target.toString() ?? '');
    saved = TextEditingController(text: r?.saved.toString() ?? '0');
  }

  @override
  void dispose() {
    name.dispose();
    target.dispose();
    saved.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.record == null ? 'Add savings goal' : 'Edit savings goal',
    ),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'Goal name'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: target,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Target amount (₱)',
                ),
                validator: (v) => positiveAmount(v ?? '') == null
                    ? 'Enter a target greater than zero'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: saved,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Current saved (₱)',
                ),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim());
                  return n == null || !n.isFinite || n < 0
                      ? 'Enter zero or a positive amount'
                      : null;
                },
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!key.currentState!.validate()) return;
          widget.state.saveGoal(
            id: widget.record?.id,
            name: name.text,
            target: positiveAmount(target.text)!,
            saved: double.parse(saved.text.trim()),
          );
          Navigator.pop(context);
        },
        child: const Text('Save'),
      ),
    ],
  );
}
