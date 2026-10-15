import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'screens/calculator_screen.dart';
import 'screens/history_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/budgets_screen.dart';

void main() => runApp(const CalcBudgetApp());

class CalcBudgetApp extends StatefulWidget {
  const CalcBudgetApp({super.key});
  @override
  State<CalcBudgetApp> createState() => _CalcBudgetAppState();
}

class _CalcBudgetAppState extends State<CalcBudgetApp> {
  final state = AppState();
  int selected = 0;
  String? reusedExpression;

  void openCalculator(String expression) => setState(() {
    reusedExpression = expression;
    selected = 0;
  });

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0B1422);
    const card = Color(0xFF142338);
    const accent = Color(0xFF38C9C1);
    return MaterialApp(
      title: 'CalcBudget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          surface: card,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      home: AnimatedBuilder(
        animation: state,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: Text(
              [
                'Scientific Calculator',
                'Calculation History',
                'Budget Dashboard',
                'Transactions',
                'Budgets & Savings',
              ][selected],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: IndexedStack(
            index: selected,
            children: [
              CalculatorScreen(
                state: state,
                reusedExpression: reusedExpression,
                onExpressionUsed: () => reusedExpression = null,
              ),
              HistoryScreen(state: state, onReuse: openCalculator),
              DashboardScreen(
                state: state,
                onOpenTransactions: () => setState(() => selected = 3),
              ),
              TransactionsScreen(state: state),
              BudgetsScreen(state: state),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selected,
            onDestinationSelected: (value) => setState(() => selected = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon: Icon(Icons.calculate),
                label: 'Calculator',
              ),
              NavigationDestination(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                label: 'Activity',
              ),
              NavigationDestination(
                icon: Icon(Icons.savings_outlined),
                label: 'Plans',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
