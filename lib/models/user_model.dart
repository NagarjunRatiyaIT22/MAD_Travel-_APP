/// User model for local authentication and profile management.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final int avatarColorIndex;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.avatarColorIndex = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'avatarColorIndex': avatarColorIndex,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'],
        avatarUrl: map['avatarUrl'],
        avatarColorIndex: map['avatarColorIndex'] ?? 0,
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      );

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    int? avatarColorIndex,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        avatarColorIndex: avatarColorIndex ?? this.avatarColorIndex,
        createdAt: createdAt,
      );
}
