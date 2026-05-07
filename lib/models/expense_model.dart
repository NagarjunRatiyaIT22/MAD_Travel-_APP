/// Expense category enumeration with display properties.
enum ExpenseCategory {
  food('Food', '🍔'),
  hotel('Hotel', '🏨'),
  travel('Travel', '✈️'),
  shopping('Shopping', '🛍️'),
  fuel('Fuel', '⛽'),
  entertainment('Entertainment', '🎬'),
  other('Other', '📦');

  final String label;
  final String emoji;
  const ExpenseCategory(this.label, this.emoji);
}

/// Expense model for shared expense tracking.
class ExpenseModel {
  final String id;
  final String tripId;
  final double amount;
  final String paidById;
  final List<String> splitBetweenIds;
  final ExpenseCategory category;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.tripId,
    required this.amount,
    required this.paidById,
    required this.splitBetweenIds,
    this.category = ExpenseCategory.other,
    this.description = '',
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Per-person share amount
  double get perPersonShare =>
      splitBetweenIds.isNotEmpty ? amount / splitBetweenIds.length : amount;

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'amount': amount,
        'paidById': paidById,
        'splitBetweenIds': splitBetweenIds,
        'category': category.name,
        'description': description,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory ExpenseModel.fromMap(Map<String, dynamic> map) => ExpenseModel(
        id: map['id'] ?? '',
        tripId: map['tripId'] ?? '',
        amount: (map['amount'] ?? 0.0).toDouble(),
        paidById: map['paidById'] ?? '',
        splitBetweenIds: List<String>.from(map['splitBetweenIds'] ?? []),
        category: ExpenseCategory.values.firstWhere(
          (c) => c.name == (map['category'] ?? 'other'),
          orElse: () => ExpenseCategory.other,
        ),
        description: map['description'] ?? '',
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      );

  ExpenseModel copyWith({
    double? amount,
    String? paidById,
    List<String>? splitBetweenIds,
    ExpenseCategory? category,
    String? description,
    DateTime? date,
  }) =>
      ExpenseModel(
        id: id,
        tripId: tripId,
        amount: amount ?? this.amount,
        paidById: paidById ?? this.paidById,
        splitBetweenIds: splitBetweenIds ?? this.splitBetweenIds,
        category: category ?? this.category,
        description: description ?? this.description,
        date: date ?? this.date,
        createdAt: createdAt,
      );
}
