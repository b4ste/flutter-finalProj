import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

List<TextInputFormatter> get moneyInputFormatters => [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  TextInputFormatter.withFunction(
    (oldValue, newValue) =>
        RegExp(r'^\d*(\.\d*)?$').hasMatch(newValue.text) ? newValue : oldValue,
  ),
];

String money(double value) {
  final negative = value < 0 ? '-' : '';
  final parts = value.abs().toStringAsFixed(2).split('.');
  final grouped = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$negative₱$grouped.${parts[1]}';
}

String shortDate(DateTime date) => '${date.month}/${date.day}/${date.year}';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message});
  final IconData icon;
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    ),
  );
}

Future<bool> confirmDelete(BuildContext context, String item) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $item?'),
        content: const Text(
          'This action cannot be undone during this session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ??
    false;

Widget progress(double value, {bool warning = false}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    LinearProgressIndicator(
      value: value.clamp(0, 1).toDouble(),
      minHeight: 8,
      borderRadius: BorderRadius.circular(8),
      color: warning ? Colors.orangeAccent : null,
    ),
    const SizedBox(height: 5),
    Text(
      '${(value * 100).toStringAsFixed(0)}%',
      style: const TextStyle(fontSize: 12),
    ),
  ],
);

double? positiveAmount(String input) {
  final value = double.tryParse(input.trim());
  return value != null && value.isFinite && value > 0 ? value : null;
}
