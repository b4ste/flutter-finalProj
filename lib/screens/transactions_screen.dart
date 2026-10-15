import 'package:flutter/material.dart';
import '../models/records.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

const incomeCategories = ['Allowance', 'Salary', 'Other income'];
const expenseCategories = [
  'Food',
  'Transportation',
  'Education',
  'Bills',
  'Entertainment',
  'Shopping',
  'Other expenses',
];

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key, required this.state});
  final AppState state;
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionType? filter;
  String? categoryFilter;

  @override
  Widget build(BuildContext context) {
    final records =
        widget.state.transactions
            .where(
              (r) =>
                  (filter == null || r.type == filter) &&
                  (categoryFilter == null || r.category == categoryFilter),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final categories = filter == TransactionType.income
        ? incomeCategories
        : filter == TransactionType.expense
        ? expenseCategories
        : [...incomeCategories, ...expenseCategories];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<TransactionType?>(
                  isExpanded: true,
                  initialValue: filter,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All types')),
                    DropdownMenuItem(
                      value: TransactionType.income,
                      child: Text('Income'),
                    ),
                    DropdownMenuItem(
                      value: TransactionType.expense,
                      child: Text('Expense'),
                    ),
                  ],
                  onChanged: (v) => setState(() {
                    filter = v;
                    categoryFilter = null;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  isExpanded: true,
                  key: ValueKey(filter),
                  initialValue: categoryFilter,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All categories'),
                    ),
                    for (final c in categories)
                      DropdownMenuItem(
                        value: c,
                        child: Text(c, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() => categoryFilter = v),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => TransactionForm(state: widget.state),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add transaction'),
            ),
          ),
        ),
        Expanded(
          child: records.isEmpty
              ? const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  message:
                      'No transactions yet. Add income or an expense to get started.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final r = records[index];
                    final income = r.type == TransactionType.income;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            income ? Icons.arrow_downward : Icons.arrow_upward,
                          ),
                        ),
                        title: Text(
                          r.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${income ? 'Income' : 'Expense'} • ${r.category} • ${shortDate(r.date)}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${income ? '+' : '−'}${money(r.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: income
                                    ? Colors.tealAccent
                                    : Colors.orangeAccent,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => showDialog(
                                    context: context,
                                    builder: (_) => TransactionForm(
                                      state: widget.state,
                                      record: r,
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.edit_outlined, size: 18),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    if (await confirmDelete(
                                      context,
                                      'transaction',
                                    )) {
                                      widget.state.deleteTransaction(r.id);
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.delete_outline, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class TransactionForm extends StatefulWidget {
  const TransactionForm({super.key, required this.state, this.record});
  final AppState state;
  final MoneyTransaction? record;
  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController amount;
  late final TextEditingController description;
  late TransactionType type;
  late String category;
  late DateTime date;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    amount = TextEditingController(text: r == null ? '' : r.amount.toString());
    description = TextEditingController(text: r?.description ?? '');
    type = r?.type ?? TransactionType.expense;
    category = r?.category ?? expenseCategories.first;
    date = r?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    amount.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.record == null ? 'Add transaction' : 'Edit transaction'),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<TransactionType>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text('Income'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text('Expense'),
                  ),
                ],
                onChanged: (v) => setState(() {
                  type = v!;
                  category = type == TransactionType.income
                      ? incomeCategories.first
                      : expenseCategories.first;
                }),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Amount (₱)'),
                validator: (v) => positiveAmount(v ?? '') == null
                    ? 'Enter an amount greater than zero'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(type),
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final c
                      in type == TransactionType.income
                          ? incomeCategories
                          : expenseCategories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => category = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: description,
                maxLength: 80,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Enter a description' : null,
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => date = picked);
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(shortDate(date)),
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
          if (!formKey.currentState!.validate()) return;
          widget.state.saveTransaction(
            id: widget.record?.id,
            type: type,
            amount: positiveAmount(amount.text)!,
            category: category,
            description: description.text,
            date: date,
          );
          Navigator.pop(context);
        },
        child: const Text('Save'),
      ),
    ],
  );
}
