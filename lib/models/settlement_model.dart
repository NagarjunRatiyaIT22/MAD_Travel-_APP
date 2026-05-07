/// Settlement model representing who owes whom.
class SettlementModel {
  final String fromId;
  final String fromName;
  final String toId;
  final String toName;
  final double amount;
  final bool isPaid;

  SettlementModel({
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.amount,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() => {
        'fromId': fromId,
        'fromName': fromName,
        'toId': toId,
        'toName': toName,
        'amount': amount,
        'isPaid': isPaid,
      };

  factory SettlementModel.fromMap(Map<String, dynamic> map) => SettlementModel(
        fromId: map['fromId'] ?? '',
        fromName: map['fromName'] ?? '',
        toId: map['toId'] ?? '',
        toName: map['toName'] ?? '',
        amount: (map['amount'] ?? 0.0).toDouble(),
        isPaid: map['isPaid'] ?? false,
      );
}
