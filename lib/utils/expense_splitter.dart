import '../models/expense_model.dart';
import '../models/participant_model.dart';
import '../models/settlement_model.dart';

/// Implements the expense splitting algorithm.
/// Calculates balances and generates optimized settlement suggestions.
class ExpenseSplitter {
  ExpenseSplitter._();

  /// Calculate how much each participant paid in total.
  static Map<String, double> totalPaidByEach(
      List<ExpenseModel> expenses, List<ParticipantModel> participants) {
    final map = <String, double>{};
    for (final p in participants) {
      map[p.id] = 0;
    }
    for (final e in expenses) {
      map[e.paidById] = (map[e.paidById] ?? 0) + e.amount;
    }
    return map;
  }

  /// Calculate each participant's fair share of total expenses.
  static Map<String, double> fairShareByEach(
      List<ExpenseModel> expenses, List<ParticipantModel> participants) {
    final map = <String, double>{};
    for (final p in participants) {
      map[p.id] = 0;
    }
    for (final e in expenses) {
      final share = e.amount / e.splitBetweenIds.length;
      for (final pid in e.splitBetweenIds) {
        map[pid] = (map[pid] ?? 0) + share;
      }
    }
    return map;
  }

  /// Net balance = totalPaid - fairShare
  /// Positive = others owe them; Negative = they owe others.
  static Map<String, double> netBalances(
      List<ExpenseModel> expenses, List<ParticipantModel> participants) {
    final paid = totalPaidByEach(expenses, participants);
    final share = fairShareByEach(expenses, participants);
    final balances = <String, double>{};
    for (final p in participants) {
      balances[p.id] = (paid[p.id] ?? 0) - (share[p.id] ?? 0);
    }
    return balances;
  }

  /// Generate optimized list of settlements using greedy algorithm.
  static List<SettlementModel> generateSettlements(
      List<ExpenseModel> expenses, List<ParticipantModel> participants) {
    if (expenses.isEmpty || participants.isEmpty) return [];

    final balances = netBalances(expenses, participants);
    final nameMap = {for (final p in participants) p.id: p.name};

    // Separate creditors and debtors
    final debtors = <MapEntry<String, double>>[];
    final creditors = <MapEntry<String, double>>[];

    for (final entry in balances.entries) {
      if (entry.value < -0.01) {
        debtors.add(MapEntry(entry.key, -entry.value)); // make positive
      } else if (entry.value > 0.01) {
        creditors.add(MapEntry(entry.key, entry.value));
      }
    }

    // Sort descending by amount
    debtors.sort((a, b) => b.value.compareTo(a.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    final settlements = <SettlementModel>[];
    int i = 0, j = 0;
    final debtAmounts = debtors.map((e) => e.value).toList();
    final creditAmounts = creditors.map((e) => e.value).toList();

    while (i < debtors.length && j < creditors.length) {
      final amount =
          debtAmounts[i] < creditAmounts[j] ? debtAmounts[i] : creditAmounts[j];
      settlements.add(SettlementModel(
        fromId: debtors[i].key,
        fromName: nameMap[debtors[i].key] ?? 'Unknown',
        toId: creditors[j].key,
        toName: nameMap[creditors[j].key] ?? 'Unknown',
        amount: double.parse(amount.toStringAsFixed(2)),
      ));
      debtAmounts[i] -= amount;
      creditAmounts[j] -= amount;
      if (debtAmounts[i] < 0.01) i++;
      if (creditAmounts[j] < 0.01) j++;
    }

    return settlements;
  }

  /// Total trip expenses.
  static double totalExpenses(List<ExpenseModel> expenses) {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Expenses grouped by category.
  static Map<ExpenseCategory, double> expensesByCategory(
      List<ExpenseModel> expenses) {
    final map = <ExpenseCategory, double>{};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }
}
