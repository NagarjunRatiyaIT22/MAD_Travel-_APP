/// Itinerary item model for day-wise planning.
class ItineraryModel {
  final String id;
  final String tripId;
  final DateTime date;
  final String? time;
  final String title;
  final String description;
  final String? location;
  final String? notes;
  final bool isCompleted;
  final int order;

  ItineraryModel({
    required this.id,
    required this.tripId,
    required this.date,
    this.time,
    required this.title,
    this.description = '',
    this.location,
    this.notes,
    this.isCompleted = false,
    this.order = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'tripId': tripId,
        'date': date.toIso8601String(),
        'time': time,
        'title': title,
        'description': description,
        'location': location,
        'notes': notes,
        'isCompleted': isCompleted,
        'order': order,
      };

  factory ItineraryModel.fromMap(Map<String, dynamic> map) => ItineraryModel(
        id: map['id'] ?? '',
        tripId: map['tripId'] ?? '',
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        time: map['time'],
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        location: map['location'],
        notes: map['notes'],
        isCompleted: map['isCompleted'] ?? false,
        order: map['order'] ?? 0,
      );

  ItineraryModel copyWith({
    DateTime? date,
    String? time,
    String? title,
    String? description,
    String? location,
    String? notes,
    bool? isCompleted,
    int? order,
  }) =>
      ItineraryModel(
        id: id,
        tripId: tripId,
        date: date ?? this.date,
        time: time ?? this.time,
        title: title ?? this.title,
        description: description ?? this.description,
        location: location ?? this.location,
        notes: notes ?? this.notes,
        isCompleted: isCompleted ?? this.isCompleted,
        order: order ?? this.order,
      );
}
