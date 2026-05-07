/// Participant model for trip members.
class ParticipantModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final int avatarColorIndex;
  final String tripId;

  ParticipantModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatarColorIndex = 0,
    required this.tripId,
  });

  /// Get initials for avatar display
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatarColorIndex': avatarColorIndex,
        'tripId': tripId,
      };

  factory ParticipantModel.fromMap(Map<String, dynamic> map) =>
      ParticipantModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        email: map['email'],
        phone: map['phone'],
        avatarColorIndex: map['avatarColorIndex'] ?? 0,
        tripId: map['tripId'] ?? '',
      );

  ParticipantModel copyWith({
    String? name,
    String? email,
    String? phone,
    int? avatarColorIndex,
  }) =>
      ParticipantModel(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        avatarColorIndex: avatarColorIndex ?? this.avatarColorIndex,
        tripId: tripId,
      );
}
