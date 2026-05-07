/// Trip model representing a travel trip with all metadata.
class TripModel {
  final String id;
  final String name;
  final String destination;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final int coverImageIndex;
  final List<String> participantIds;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  TripModel({
    required this.id,
    required this.name,
    required this.destination,
    this.description = '',
    required this.startDate,
    required this.endDate,
    this.budget = 0.0,
    this.coverImageIndex = 0,
    this.participantIds = const [],
    required this.createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSynced = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Check if trip is upcoming
  bool get isUpcoming => startDate.isAfter(DateTime.now());

  /// Check if trip is ongoing
  bool get isOngoing =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  /// Check if trip is completed
  bool get isCompleted => endDate.isBefore(DateTime.now());

  /// Get trip status label
  String get statusLabel {
    if (isUpcoming) return 'Upcoming';
    if (isOngoing) return 'Ongoing';
    return 'Completed';
  }

  /// Total number of days
  int get totalDays => endDate.difference(startDate).inDays + 1;

  /// Days remaining until trip starts
  int get daysUntilStart => startDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'destination': destination,
        'description': description,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'budget': budget,
        'coverImageIndex': coverImageIndex,
        'participantIds': participantIds,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isSynced': isSynced,
      };

  factory TripModel.fromMap(Map<String, dynamic> map) => TripModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        destination: map['destination'] ?? '',
        description: map['description'] ?? '',
        startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
        endDate: DateTime.tryParse(map['endDate'] ?? '') ?? DateTime.now(),
        budget: (map['budget'] ?? 0.0).toDouble(),
        coverImageIndex: map['coverImageIndex'] ?? 0,
        participantIds: List<String>.from(map['participantIds'] ?? []),
        createdBy: map['createdBy'] ?? '',
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
        isSynced: map['isSynced'] ?? false,
      );

  TripModel copyWith({
    String? name,
    String? destination,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    int? coverImageIndex,
    List<String>? participantIds,
    bool? isSynced,
  }) =>
      TripModel(
        id: id,
        name: name ?? this.name,
        destination: destination ?? this.destination,
        description: description ?? this.description,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        budget: budget ?? this.budget,
        coverImageIndex: coverImageIndex ?? this.coverImageIndex,
        participantIds: participantIds ?? this.participantIds,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        isSynced: isSynced ?? this.isSynced,
      );
}
