import 'package:flutter/material.dart';
import '../logic/expression_evaluator.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.state, required this.onReuse});
  final AppState state;
  final ValueChanged<String> onReuse;

  Future<void> editNote(BuildContext context, int id, String current) async {
    final controller = TextEditingController(text: current);
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit title or note'),
        content: TextField(
          controller: controller,
          maxLength: 100,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Note'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note != null) state.updateCalculation(id, note);
  }

  @override
  Widget build(BuildContext context) => state.calculations.isEmpty
      ? const EmptyState(
          icon: Icons.history,
          message: 'Your completed calculations will appear here.',
        )
      : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.calculations.length,
          itemBuilder: (context, index) {
            final record = state.calculations[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (record.note.isNotEmpty)
                      Text(
                        record.note,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    Text(
                      record.expression,
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '= ${formatResult(record.result)}',
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${shortDate(record.createdAt)} • ${TimeOfDay.fromDateTime(record.createdAt).format(context)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => onReuse(record.expression),
                          icon: const Icon(Icons.replay),
                          label: const Text('Reuse'),
                        ),
                        IconButton(
                          tooltip: 'Edit note',
                          onPressed: () =>
                              editNote(context, record.id, record.note),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Delete calculation',
                          onPressed: () async {
                            if (await confirmDelete(context, 'calculation')) {
                              state.deleteCalculation(record.id);
                            }
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
}
